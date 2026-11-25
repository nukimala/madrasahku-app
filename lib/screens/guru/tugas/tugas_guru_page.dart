import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../../../models/materi_model.dart';
import '../../../models/siswa_model.dart';
import '../../../models/tugas_model.dart';
import '../../../services/materi_service.dart';
import '../../../services/tugas_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

import 'pengumpulan_tugas.dart';

class TugasGuruPage extends StatefulWidget {
  final int refreshTick;
  const TugasGuruPage({super.key, this.refreshTick = 0});

  @override
  State<TugasGuruPage> createState() => _TugasGuruPageState();
}

class _TugasGuruPageState extends State<TugasGuruPage> {
  static const Color _topikBg = Color(0xFFF1EDEC);

  // Kelas & mapel yang diampu guru login (dari API).
  List<GuruKelasMapel> _penugasan = [];
  bool _memuat = true;

  String? _kelas;
  String? _mapel;
  String _query = '';

  final List<TopikTugas> _topik = [];
  final Set<TopikTugas> _terbuka = {};

  // Kelas unik yang diajar guru ini.
  List<String> get _kelasList =>
      _penugasan.map((e) => e.className).toSet().toList();

  // Mapel yang diajar guru ini di kelas terpilih.
  List<String> get _mapelList => _penugasan
      .where((e) => e.className == _kelas)
      .map((e) => e.subjectName)
      .toSet()
      .toList();

  @override
  void initState() {
    super.initState();
    _muatAwal();
  }

  @override
  void didUpdateWidget(covariant TugasGuruPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTick != widget.refreshTick && !_memuat) {
      _muatTugasApi();
    }
  }

  Future<void> _muatAwal() async {
    setState(() {
      _memuat = true;
    });

    try {
      final p = await MateriService.instance.ambilKelasMapelGuru();
      if (!mounted) return;
      setState(() {
        _penugasan = p;
        _kelas = _kelasList.isNotEmpty ? _kelasList.first : null;
        _mapel = _mapelList.isNotEmpty ? _mapelList.first : null;
        _memuat = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _memuat = false;
      });
      return;
    }

    await _muatTugasApi();
  }

  void _gantiKelas(String v) {
    setState(() {
      _kelas = v;
      // Mapel harus ikut kelas baru.
      final daftar = _mapelList;
      if (!daftar.contains(_mapel)) {
        _mapel = daftar.isNotEmpty ? daftar.first : null;
      }
    });
    _muatTugasApi();
  }

  void _gantiMapel(String v) {
    setState(() {
      _mapel = v;
    });
    _muatTugasApi();
  }

  Future<void> _muatTugasApi() async {
    if (_kelas == null || _mapel == null) return;
    
    // Debug: log all penugasan
    debugPrint('TugasGuruPage: _penugasan = ${_penugasan.map((p) => '${p.className}|${p.subjectName}|csid=${p.classSubjectId}').toList()}');
    debugPrint('TugasGuruPage: Looking for kelas="$_kelas", mapel="$_mapel"');
    
    // Cari classSubjectId dari penugasan guru (case-insensitive, trim)
    final kelasTrim = _kelas!.trim().toLowerCase();
    final mapelTrim = _mapel!.trim().toLowerCase();
    final penugasan = _penugasan.firstWhere(
      (p) => p.className.trim().toLowerCase() == kelasTrim && p.subjectName.trim().toLowerCase() == mapelTrim,
      orElse: () => GuruKelasMapel(classSubjectId: 0, classId: 0, className: '', subjectId: 0, subjectName: ''),
    );
    
    debugPrint('TugasGuruPage: Found penugasan -> classSubjectId=${penugasan.classSubjectId}, classId=${penugasan.classId}');
    
    if (penugasan.classSubjectId == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kelas/Mapel tidak ditemukan di penugasan (classSubjectId=0): $_kelas / $_mapel. Periksa log untuk detail.')),
        );
      }
      return;
    }
    
    try {
      final topicsData = await MateriService.instance.ambilTopikGuru(penugasan.classSubjectId);
      final items = await TugasService.instance.ambilDaftarTugas(classSubjectId: penugasan.classSubjectId);
      debugPrint('TugasGuruPage: Loaded ${topicsData.length} topics & ${items.length} tugas items from API');
      if (mounted) {
        setState(() {
          _topik.clear();
          final Map<int, TopikTugas> byTopicId = {};

          for (final td in topicsData) {
            final tId = td['id'] is int ? td['id'] as int : int.tryParse(td['id']?.toString() ?? '');
            final minggu = td['minggu'] is int ? td['minggu'] as int : int.tryParse(td['minggu']?.toString() ?? '') ?? 1;
            final topik = TopikTugas(
              minggu: minggu,
              nama: (td['nama'] ?? 'Topik').toString(),
              kelas: penugasan.className,
              mapel: penugasan.subjectName,
              tugas: [],
            );
            _topik.add(topik);
            _terbuka.add(topik);
            if (tId != null) byTopicId[tId] = topik;
          }

          TopikTugas? fallbackTopik;
          for (var i = 0; i < items.length; i++) {
            final t = items[i];
            final deadline = DateTime.tryParse(t.deadline) ??
                DateTime.now().add(const Duration(days: 7));
            final tg = TugasGuru(
              judul: t.title,
              deadline: deadline,
              siswa: [],
              tugasItem: t,
            );

            if (t.topicId != null && byTopicId.containsKey(t.topicId)) {
              byTopicId[t.topicId]!.tugas.add(tg);
            } else if (t.topicId != null) {
              final topik = TopikTugas(
                minggu: t.topicMinggu ?? 1,
                nama: t.topicNama ?? 'Topik',
                kelas: t.className,
                mapel: t.subjectName,
                tugas: [tg],
              );
              _topik.add(topik);
              _terbuka.add(topik);
              byTopicId[t.topicId!] = topik;
            } else {
              if (fallbackTopik == null) {
                fallbackTopik = TopikTugas(
                  minggu: 1,
                  nama: 'Umum',
                  kelas: t.className,
                  mapel: t.subjectName,
                  tugas: [tg],
                );
                _topik.add(fallbackTopik);
                _terbuka.add(fallbackTopik);
              } else {
                fallbackTopik.tugas.add(tg);
              }
            }
          }
        });
      }
    } catch (e) {
      debugPrint('TugasGuruPage: Error loading tugas: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat tugas: $e')),
        );
      }
    }
  }

  List<TopikTugas> get _hasil {
    final q = _query.toLowerCase();
    final kelasLower = _kelas?.toLowerCase() ?? '';
    final mapelLower = _mapel?.toLowerCase() ?? '';

    return _topik.where((t) {
      final matchesKelas = t.kelas.isEmpty ||
          (kelasLower.isNotEmpty && (
            t.kelas.toLowerCase().contains(kelasLower.replaceAll('kelas ', '').trim()) ||
            kelasLower.contains(t.kelas.toLowerCase())
          ));
      final matchesMapel = t.mapel.isEmpty ||
          (mapelLower.isNotEmpty && (
            t.mapel.toLowerCase().contains(mapelLower) ||
            mapelLower.contains(t.mapel.toLowerCase())
          ));

      if (!matchesKelas || !matchesMapel) return false;
      if (q.isEmpty) return true;

      return t.judul.toLowerCase().contains(q) ||
          t.tugas.any((x) => x.judul.toLowerCase().contains(q));
    }).toList();
  }

  // Buka halaman penilaian tugas - fetch detail pengumpulan dulu.
  Future<void> _bukaTugas(TopikTugas topik, TugasGuru tugas) async {
    final tugasItem = tugas.tugasItem;
    if (tugasItem == null) {
      // Fallback: buka tanpa data detail
      await _navKePengumpulan(topik, tugas, null);
      return;
    }

    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Fetch detail pengumpulan dari API
      final detailRes = await TugasService.instance.ambilDetailPengumpulanTugas(tugasItem.id);
      
      // 2. Fetch daftar siswa kelas ini
      final siswaList = tugasItem.classId > 0
          ? await TugasService.instance.ambilSiswaKelas(tugasItem.classId)
          : <SiswaItem>[];

      if (!mounted) return;
      Navigator.pop(context); // tutup loading

      // 3. Parse response & build SiswaTugas list
      final siswaTugas = _parsePengumpulanData(detailRes['data'], siswaList, tugasItem.deadline);
      
      // 4. Update tugas dengan data siswa terbaru
      final tugasUpdated = TugasGuru(
        judul: tugas.judul,
        deadline: tugas.deadline,
        siswa: siswaTugas,
        tugasItem: tugasItem,
      );

      await _navKePengumpulan(topik, tugasUpdated, tugasItem);
    } catch (e) {
      if (mounted) Navigator.pop(context); // tutup loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat detail: $e')),
        );
      }
      await _navKePengumpulan(topik, tugas, tugasItem);
    }
  }

  Future<void> _navKePengumpulan(TopikTugas topik, TugasGuru tugas, TugasItem? tugasItem) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => PengumpulanTugasPage(
          minggu: topik.minggu,
          kelas: topik.kelas,
          tugas: tugas,
          tugasItem: tugasItem, // kirim juga TugasItem untuk refresh nanti
        ),
      ),
    );

    // Refresh setelah kembali (data mungkin berubah).
    if (mounted) setState(() {});
  }

  /// Parse data pengumpulan dari API + gabungkan dengan daftar siswa kelas
  List<SiswaTugas> _parsePengumpulanData(
    dynamic apiData,
    List<SiswaItem> siswaKelas,
    String deadlineStr,
  ) {
    final Map<int, DateTime?> submitMap = {};
    final List<SiswaTugas> dariApi = [];

    if (apiData != null) {
      List<dynamic> submissions = [];
      if (apiData is Map && apiData['submissions'] is List) {
        submissions = apiData['submissions'] as List;
      } else if (apiData is List) {
        submissions = apiData;
      }

      for (final s in submissions) {
        if (s is Map) {
          final rawId = s['student_id'] ?? s['siswa_id'];
          final siswaId = rawId is int
              ? rawId
              : int.tryParse(rawId?.toString() ?? '') ?? 0;
          final nama = (s['student_name'] ?? s['nama'] ?? '').toString();
          final submittedAtStr =
              s['submitted_at']?.toString() ?? s['created_at']?.toString();
          final submittedAt =
              submittedAtStr != null ? DateTime.tryParse(submittedAtStr) : null;

          if (nama.isNotEmpty) {
            dariApi.add(SiswaTugas(nama: nama, waktuKumpul: submittedAt));
          }
          if (siswaId > 0) {
            submitMap[siswaId] = submittedAt;
          }
        }
      }
    }

    if (dariApi.isNotEmpty) {
      return dariApi;
    }

    // Fallback jika API hanya mengembalikan daftar yang sudah mengumpulkan
    return siswaKelas.map((siswa) {
      final waktuKumpul = submitMap[siswa.id];
      return SiswaTugas(
        nama: siswa.nama,
        waktuKumpul: waktuKumpul,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final daftar = _hasil;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tugas',
            style: AppTextStyle.headingSmall.copyWith(fontSize: 16),
          ),

          const SizedBox(height: 14),

          // Filter kelas dan mata pelajaran.
          Row(
            children: [
              Expanded(
                child: _Dropdown(
                  value: _kelas,
                  items: _kelasList,
                  onChanged: _memuat ? null : (v) {
                    if (v != null) _gantiKelas(v);
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _Dropdown(
                  value: _mapel,
                  items: _mapelList,
                  onChanged: _memuat ? null : _gantiMapel,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Kolom cari.
          _Kotak(
            child: TextField(
              onChanged: (v) => setState(() => _query = v.trim()),
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                icon: Icon(Icons.search, size: 20),
                hintText: 'Cari Tugas....',
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: daftar.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada topik.',
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: daftar.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _buildTopik(daftar[i]),
                  ),
          ),
        ],
      ),
    );
  }

  // Card topik berisi daftar tugas minggu itu.
  Widget _buildTopik(TopikTugas t) {
    final terbuka = _terbuka.contains(t) || _query.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _topikBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() {
              terbuka ? _terbuka.remove(t) : _terbuka.add(t);
            }),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Topik',
                        style: AppTextStyle.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        t.judul,
                        style: AppTextStyle.headingSmall.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),

                Icon(
                  terbuka
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),

          if (terbuka) ...[
            const SizedBox(height: 10),

            if (t.tugas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Belum ada tugas di topik ini.',
                  style: AppTextStyle.bodySmall.copyWith(fontSize: 11),
                ),
              ),

            ...t.tugas.map((x) => _buildTugas(t, x)),
          ],
        ],
      ),
    );
  }

  Widget _buildTugas(TopikTugas t, TugasGuru x) {
    return GestureDetector(
      onTap: () => _bukaTugas(t, x),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    x.judul,
                    style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Deadline: ${formatTglJamPanjang(x.deadline)}',
                    style: AppTextStyle.bodySmall.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, size: 22),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// WIDGET KECIL PENDUKUNG
// =========================================================

class _Kotak extends StatelessWidget {
  final Widget child;
  const _Kotak({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String>? onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _Kotak(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          style: const TextStyle(fontSize: 12, color: Colors.black),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged != null
              ? (v) {
                  if (v != null) onChanged!(v);
                }
              : null,
        ),
      ),
    );
  }
}