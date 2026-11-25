import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../../../models/materi_model.dart';
import '../../../services/materi_service.dart';
import '../../../services/tugas_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

import 'tambah_materi_page.dart';
import 'tambah_tugas_page.dart';

import 'edit_materi_page.dart';
import 'edit_tugas_page.dart';

// =====================================================================
// MODEL SEMENTARA
// =====================================================================
class _Item {
  final int? id;
  final String judul;
  final String sub;
  final bool isTugas;

  // Data mentah untuk edit.
  final String deskripsi;
  final String? namaFile;
  final DateTime? mulai;    // hanya tugas
  final DateTime? deadline; // hanya tugas
  final String? jenis;      // hanya tugas

  _Item({
    this.id,
    required this.judul,
    this.sub = '',
    this.isTugas = false,
    this.deskripsi = '',
    this.namaFile,
    this.mulai,
    this.deadline,
    this.jenis,
  });

  _Item copyWith({
    int? id,
    String? judul,
    String? sub,
    bool? isTugas,
    String? deskripsi,
    String? namaFile,
    DateTime? mulai,
    DateTime? deadline,
    String? jenis,
    bool hapusFile = false,
  }) {
    return _Item(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      sub: sub ?? this.sub,
      isTugas: isTugas ?? this.isTugas,
      deskripsi: deskripsi ?? this.deskripsi,
      namaFile: hapusFile ? null : (namaFile ?? this.namaFile),
      mulai: mulai ?? this.mulai,
      deadline: deadline ?? this.deadline,
      jenis: jenis ?? this.jenis,
    );
  }
}

class _Topik {
  final int? id;
  final int minggu;
  final String nama;
  final DateTime waktu;
  final List<_Item> items;

  // Topik ini milik kelas & mapel yang mana (dipakai untuk filter).
  String kelas;
  String mapel;

  _Topik({
    this.id,
    required this.minggu,
    required this.nama,
    required this.waktu,
    this.kelas = '',
    this.mapel = '',
    List<_Item>? items,
  }) : items = items ?? [];

  String get judul => 'Minggu $minggu - $nama';
}

// =====================================================================
// HALAMAN MATERI GURU
// =====================================================================
class MateriGuruPage extends StatefulWidget {
  final int refreshTick;
  const MateriGuruPage({super.key, this.refreshTick = 0});

  @override
  State<MateriGuruPage> createState() => _MateriGuruPageState();
}

class _MateriGuruPageState extends State<MateriGuruPage> {
  static const Color _green = Color(0xFF219653);
  static const Color _topikBg = Color(0xFFF1EDEC);

  // Kelas & mapel yang diampu guru login (dari API).
  List<GuruKelasMapel> _penugasan = [];
  bool _memuat = true;
  String? _error;

  String? _kelas;
  String? _mapel;
  String _query = '';

  final Set<_Topik> _terbuka = {};
  final List<_Topik> _topik = [];

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
  void didUpdateWidget(covariant MateriGuruPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTick != widget.refreshTick && !_memuat) {
      _muatMateriApi();
    }
  }

  Future<void> _muatAwal() async {
    setState(() {
      _memuat = true;
      _error = null;
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
        _error = e.toString().replaceFirst('Exception: ', '');
        _memuat = false;
      });
      return;
    }

    await _muatMateriApi();
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
    _muatMateriApi();
  }

  void _gantiMapel(String v) {
    setState(() {
      _mapel = v;
    });
    _muatMateriApi();
  }

  Future<void> _muatMateriApi() async {
    if (_kelas == null || _mapel == null) return;
    
    // Debug: log all penugasan
    debugPrint('MateriGuruPage: _penugasan = ${_penugasan.map((p) => '${p.className}|${p.subjectName}|csid=${p.classSubjectId}').toList()}');
    debugPrint('MateriGuruPage: Looking for kelas="$_kelas", mapel="$_mapel"');
    
    // Cari classSubjectId dari penugasan guru (case-insensitive, trim)
    final kelasTrim = _kelas!.trim().toLowerCase();
    final mapelTrim = _mapel!.trim().toLowerCase();
    final penugasan = _penugasan.firstWhere(
      (p) => p.className.trim().toLowerCase() == kelasTrim && p.subjectName.trim().toLowerCase() == mapelTrim,
      orElse: () => GuruKelasMapel(classSubjectId: 0, classId: 0, className: '', subjectId: 0, subjectName: ''),
    );
    
    debugPrint('MateriGuruPage: Found penugasan -> classSubjectId=${penugasan.classSubjectId}, classId=${penugasan.classId}');
    
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
      final items = await MateriService.instance.ambilDaftarMateri(classSubjectId: penugasan.classSubjectId);
      final tugasItems = await TugasService.instance.ambilDaftarTugas(classSubjectId: penugasan.classSubjectId);
      debugPrint('MateriGuruPage: Loaded ${topicsData.length} topics, ${items.length} materi, ${tugasItems.length} tugas');
      if (mounted) {
        setState(() {
          _topik.clear();
          final Map<int, _Topik> byTopicId = {};

          for (final td in topicsData) {
            final tId = td['id'] is int ? td['id'] as int : int.tryParse(td['id']?.toString() ?? '');
            final minggu = td['minggu'] is int ? td['minggu'] as int : int.tryParse(td['minggu']?.toString() ?? '') ?? 1;
            final t = _Topik(
              id: tId,
              minggu: minggu,
              nama: (td['nama'] ?? 'Topik').toString(),
              kelas: penugasan.className,
              mapel: penugasan.subjectName,
              waktu: DateTime.tryParse(td['created_at']?.toString() ?? '') ?? DateTime.now(),
              items: [],
            );
            _topik.add(t);
            _terbuka.add(t);
            if (tId != null) byTopicId[tId] = t;
          }

          _Topik? fallbackTopik;
          _Topik getFallback(String clsName, String subjName) {
            if (fallbackTopik != null) return fallbackTopik!;
            final t = _Topik(
              id: null,
              minggu: 1,
              nama: 'Umum',
              kelas: clsName,
              mapel: subjName,
              waktu: DateTime.now(),
              items: [],
            );
            _topik.add(t);
            _terbuka.add(t);
            fallbackTopik = t;
            return t;
          }

          for (var i = 0; i < items.length; i++) {
            final m = items[i];
            final mItem = _Item(
              id: m.id,
              judul: m.title,
              sub: m.description ?? 'Materi ${m.subjectName}',
              deskripsi: m.description ?? '',
              namaFile: m.fileUrl,
            );
            if (m.topicId != null && byTopicId.containsKey(m.topicId)) {
              byTopicId[m.topicId]!.items.add(mItem);
            } else if (m.topicId != null) {
              final t = _Topik(
                id: m.topicId,
                minggu: m.topicMinggu ?? 1,
                nama: m.topicNama ?? 'Topik',
                kelas: m.className,
                mapel: m.subjectName,
                waktu: DateTime.tryParse(m.createdAt) ?? DateTime.now(),
                items: [mItem],
              );
              _topik.add(t);
              _terbuka.add(t);
              byTopicId[m.topicId!] = t;
            } else {
              getFallback(m.className, m.subjectName).items.add(mItem);
            }
          }

          for (var i = 0; i < tugasItems.length; i++) {
            final tg = tugasItems[i];
            final dl = DateTime.tryParse(tg.deadline);
            final tgItem = _Item(
              id: tg.id,
              judul: tg.title,
              sub: dl != null ? 'Deadline: ${dl.day}/${dl.month}/${dl.year}' : (tg.instructions ?? 'Tugas ${tg.subjectName}'),
              isTugas: true,
              deskripsi: tg.instructions ?? '',
              deadline: dl,
            );
            if (tg.topicId != null && byTopicId.containsKey(tg.topicId)) {
              byTopicId[tg.topicId]!.items.add(tgItem);
            } else if (tg.topicId != null) {
              final t = _Topik(
                id: tg.topicId,
                minggu: tg.topicMinggu ?? 1,
                nama: tg.topicNama ?? 'Topik',
                kelas: tg.className,
                mapel: tg.subjectName,
                waktu: DateTime.now(),
                items: [tgItem],
              );
              _topik.add(t);
              _terbuka.add(t);
              byTopicId[tg.topicId!] = t;
            } else {
              getFallback(tg.className, tg.subjectName).items.add(tgItem);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('MateriGuruPage: Error loading materi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat materi: $e')),
        );
      }
    }
  }

  // Filter kelas + mapel terpilih, pencarian.
  List<_Topik> get _hasil {
    final q = _query.toLowerCase();

    return _topik.where((t) {
      if (t.kelas != _kelas || t.mapel != _mapel) return false;
      if (q.isEmpty) return true;

      return t.judul.toLowerCase().contains(q) ||
          t.items.any((i) => i.judul.toLowerCase().contains(q));
    }).toList();
  }

  // -------------------------------------------------------------------
  // TAMBAH TOPIK
  // -------------------------------------------------------------------
  Future<void> _tambahTopik() async {
    if (_kelas == null || _mapel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kelas dan mapel dulu')),
      );
      return;
    }

    final hasil = await showDialog<_Topik>(
      context: context,
      builder: (_) => const _TambahTopikDialog(),
    );

    if (hasil == null || !mounted) return;

    final kelasTrim = _kelas?.trim().toLowerCase() ?? '';
    final mapelTrim = _mapel?.trim().toLowerCase() ?? '';
    final penugasan = _penugasan.firstWhere(
      (p) => p.className.trim().toLowerCase() == kelasTrim && p.subjectName.trim().toLowerCase() == mapelTrim,
      orElse: () => GuruKelasMapel(classSubjectId: 0, classId: 0, className: '', subjectId: 0, subjectName: ''),
    );

    if (penugasan.classSubjectId > 0) {
      final res = await MateriService.instance.buatTopik(
        classSubjectId: penugasan.classSubjectId,
        minggu: hasil.minggu,
        nama: hasil.nama,
      );
      if (!mounted) return;
      if (res['success'] == true) {
        final data = res['data'];
        final serverId = data is Map && data['id'] != null
            ? (data['id'] is int ? data['id'] as int : int.tryParse(data['id'].toString()))
            : null;
        final savedTopik = _Topik(
          id: serverId,
          minggu: hasil.minggu,
          nama: hasil.nama,
          waktu: hasil.waktu,
          kelas: _kelas!,
          mapel: _mapel!,
          items: hasil.items,
        );
        setState(() {
          _topik.add(savedTopik);
          _terbuka.add(savedTopik);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Topik berhasil disimpan ke server')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal menyimpan topik ke server')),
        );
      }
      return;
    }

    hasil.kelas = _kelas!;
    hasil.mapel = _mapel!;

    setState(() {
      _topik.add(hasil);
      _terbuka.add(hasil);
    });
  }

  // -------------------------------------------------------------------
  // CARD KECIL: UPLOAD MATERI / UPLOAD TUGAS
  // -------------------------------------------------------------------
  void _pilihJenisUpload(_Topik topik) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tambah ke ${topik.judul}',
                textAlign: TextAlign.center,
                style: AppTextStyle.headingSmall.copyWith(fontSize: 13),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _PilihanUpload(
                      icon: Icons.description,
                      warna: _green,
                      label: 'Upload Materi',
                      onTap: () {
                        Navigator.pop(ctx);
                        _bukaTambahMateri(topik);
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _PilihanUpload(
                      icon: Icons.assignment,
                      warna: const Color(0xFF2F80ED),
                      label: 'Upload Tugas',
                      onTap: () {
                        Navigator.pop(ctx);
                        _bukaTambahTugas(topik);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // BUKA HALAMAN TAMBAH MATERI
  // -------------------------------------------------------------------
  Future<void> _bukaTambahMateri(_Topik topik) async {
    final kelasTrim = _kelas?.trim().toLowerCase() ?? '';
    final mapelTrim = _mapel?.trim().toLowerCase() ?? '';
    final penugasan = _penugasan.firstWhere(
      (p) => p.className.trim().toLowerCase() == kelasTrim && p.subjectName.trim().toLowerCase() == mapelTrim,
      orElse: () => GuruKelasMapel(classSubjectId: 0, classId: 0, className: '', subjectId: 0, subjectName: ''),
    );

    debugPrint('MateriGuruPage: _bukaTambahMateri -> kelas="$_kelas", mapel="$_mapel", classSubjectId=${penugasan.classSubjectId}');

    if (penugasan.classSubjectId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kelas/Mapel tidak ditemukan di penugasan (classSubjectId=0): $_kelas / $_mapel')),
      );
      return;
    }

    final hasil = await Navigator.push<MateriBaru>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahMateriPage(
          topik: topik.judul,
          kelas: _kelas ?? '',
          mapel: _mapel ?? '',
        ),
      ),
    );

    if (hasil == null || !mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      debugPrint('MateriGuruPage: Calling buatMateri with classSubjectId=${penugasan.classSubjectId}, title=${hasil.judul}');
      final res = await MateriService.instance.buatMateri(
        classSubjectId: penugasan.classSubjectId,
        topikId: topik.id,
        title: hasil.judul,
        description: hasil.deskripsi,
        fileUrl: hasil.namaFile,
        filePath: hasil.filePath,
      );

      debugPrint('MateriGuruPage: buatMateri response: success=${res['success']}, message=${res['message']}, data=${res['data']}');

      if (!mounted) return;
      Navigator.pop(context); // close loading

      if (res['success']) {
        final data = res['data'];
        final newId = data is Map && data['id'] != null
            ? (data['id'] is int ? data['id'] as int : int.tryParse(data['id'].toString()))
            : null;
        
        setState(() {
          topik.items.add(
            _Item(
              id: newId,
              judul: hasil.judul,
              sub: hasil.deskripsi.isNotEmpty
                  ? hasil.deskripsi
                  : (hasil.namaFile ?? ''),
              deskripsi: hasil.deskripsi,
              namaFile: hasil.namaFile,
            ),
          );
          _terbuka.add(topik);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Materi berhasil dibuat')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal membuat materi: ${res['errorCode'] ?? ''}')),
        );
      }
    } catch (e) {
      debugPrint('MateriGuruPage: Exception in buatMateri: $e');
      if (!mounted) return;
      Navigator.pop(context); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // -------------------------------------------------------------------
  // BUKA HALAMAN TAMBAH TUGAS
  // -------------------------------------------------------------------
  Future<void> _bukaTambahTugas(_Topik topik) async {
    final kelasTrim = _kelas?.trim().toLowerCase() ?? '';
    final mapelTrim = _mapel?.trim().toLowerCase() ?? '';
    final penugasan = _penugasan.firstWhere(
      (p) => p.className.trim().toLowerCase() == kelasTrim && p.subjectName.trim().toLowerCase() == mapelTrim,
      orElse: () => GuruKelasMapel(classSubjectId: 0, classId: 0, className: '', subjectId: 0, subjectName: ''),
    );

    debugPrint('MateriGuruPage: _bukaTambahTugas -> kelas="$_kelas", mapel="$_mapel", classSubjectId=${penugasan.classSubjectId}');

    if (penugasan.classSubjectId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kelas/Mapel tidak ditemukan di penugasan (classSubjectId=0): $_kelas / $_mapel')),
      );
      return;
    }

    final hasil = await Navigator.push<TugasBaru>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahTugasPage(
          topik: topik.judul,
          kelas: _kelas ?? '',
          mapel: _mapel ?? '',
        ),
      ),
    );

    if (hasil == null || !mounted) return;

    final d = hasil.deadline;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      debugPrint('MateriGuruPage: Calling buatTugas with classSubjectId=${penugasan.classSubjectId}, title=${hasil.judul}');
      final res = await TugasService.instance.buatTugas(
        classSubjectId: penugasan.classSubjectId,
        topikId: topik.id,
        title: hasil.judul,
        description: hasil.deskripsi,
        deadline: hasil.deadline,
        fileUrl: hasil.namaFile,
        filePath: hasil.filePath,
      );

      debugPrint('MateriGuruPage: buatTugas response: success=${res['success']}, message=${res['message']}, data=${res['data']}');

      if (!mounted) return;
      Navigator.pop(context); // close loading

      if (res['success']) {
        final data = res['data'];
        final newId = data is Map && data['id'] != null
            ? (data['id'] is int ? data['id'] as int : int.tryParse(data['id'].toString()))
            : null;
        setState(() {
          topik.items.add(
            _Item(
              id: newId,
              judul: hasil.judul,
              sub: 'Deadline: ${d.day}/${d.month}/${d.year}, '
                  '${d.hour.toString().padLeft(2, '0')}.'
                  '${d.minute.toString().padLeft(2, '0')}',
              isTugas: true,
              deskripsi: hasil.deskripsi,
              namaFile: hasil.namaFile,
              mulai: hasil.mulai,
              deadline: hasil.deadline,
              jenis: hasil.jenis,
            ),
          );
          _terbuka.add(topik);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Tugas berhasil dibuat')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal membuat tugas: ${res['errorCode'] ?? ''}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // -------------------------------------------------------------------
  // BUKA HALAMAN EDIT MATERI
  // -------------------------------------------------------------------
  Future<void> _bukaEditMateri(_Topik topik, _Item item) async {
    final hasil = await Navigator.push<MateriBaru>(
      context,
      MaterialPageRoute(
        builder: (_) => EditMateriPage(
          topik: topik.judul,
          kelas: _kelas ?? '',
          mapel: _mapel ?? '',
          judulAwal: item.judul,
          deskripsiAwal: item.deskripsi,
          namaFileAwal: item.namaFile,
        ),
      ),
    );

    if (hasil == null || !mounted) return;

    if (item.id != null && item.id! > 0) {
      final res = await MateriService.instance.updateMateri(
        materialId: item.id!,
        title: hasil.judul,
        description: hasil.deskripsi,
        fileUrl: hasil.namaFile,
      );
      if (!mounted) return;
      if (res['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal memperbarui materi')),
        );
        return;
      }
    }

    setState(() {
      final i = topik.items.indexOf(item);
      if (i == -1) return;

      // Tandai kalau user memang menghapus file (dari ada → null).
      final hapusFile = item.namaFile != null && hasil.namaFile == null;

      topik.items[i] = item.copyWith(
        judul: hasil.judul,
        deskripsi: hasil.deskripsi,
        namaFile: hasil.namaFile,
        hapusFile: hapusFile,
        sub: hasil.deskripsi.isNotEmpty
            ? hasil.deskripsi
            : (hasil.namaFile ?? ''),
      );
      _terbuka.add(topik);
    });
  }

  // -------------------------------------------------------------------
  // BUKA HALAMAN EDIT TUGAS
  // -------------------------------------------------------------------
  Future<void> _bukaEditTugas(_Topik topik, _Item item) async {
    // Fallback kalau data mentah belum ada (misal data contoh lama).
    final mulaiAwal = item.mulai ?? DateTime.now();
    final deadlineAwal =
        item.deadline ?? DateTime.now().add(const Duration(days: 1));

    final hasil = await Navigator.push<TugasBaru>(
      context,
      MaterialPageRoute(
        builder: (_) => EditTugasPage(
          topik: topik.judul,
          kelas: _kelas ?? '',
          mapel: _mapel ?? '',
          judulAwal: item.judul,
          deskripsiAwal: item.deskripsi,
          mulaiAwal: mulaiAwal,
          deadlineAwal: deadlineAwal,
          jenisAwal: item.jenis ?? 'Individu',
          namaFileAwal: item.namaFile,
        ),
      ),
    );

    if (hasil == null || !mounted) return;

    if (item.id != null && item.id! > 0) {
      final res = await TugasService.instance.updateTugas(
        assignmentId: item.id!,
        title: hasil.judul,
        description: hasil.deskripsi,
        deadline: hasil.deadline,
      );
      if (!mounted) return;
      if (res['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal memperbarui tugas')),
        );
        return;
      }
    }

    final d = hasil.deadline;

    setState(() {
      final i = topik.items.indexOf(item);
      if (i == -1) return;

      final hapusFile = item.namaFile != null && hasil.namaFile == null;

      topik.items[i] = item.copyWith(
        judul: hasil.judul,
        deskripsi: hasil.deskripsi,
        namaFile: hasil.namaFile,
        hapusFile: hapusFile,
        mulai: hasil.mulai,
        deadline: hasil.deadline,
        jenis: hasil.jenis,
        sub: 'Deadline: ${d.day}/${d.month}/${d.year}, '
            '${d.hour.toString().padLeft(2, '0')}.'
            '${d.minute.toString().padLeft(2, '0')}',
      );
      _terbuka.add(topik);
    });
  }

  // -------------------------------------------------------------------
  // HAPUS ITEM
  // -------------------------------------------------------------------
  Future<void> _hapusTopik(_Topik topik) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Topik?', style: TextStyle(fontSize: 16)),
        content: Text(
          '"${topik.judul}" akan dihapus dari daftar.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    if (topik.id != null && topik.id! > 0) {
      final res = await MateriService.instance.hapusTopik(topik.id!);
      if (!mounted) return;
      if (res['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal menghapus topik')),
        );
        return;
      }
    }

    setState(() {
      _topik.remove(topik);
      _terbuka.remove(topik);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Topik berhasil dihapus')),
    );
  }

  Future<void> _hapusItem(_Topik topik, _Item item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus?', style: TextStyle(fontSize: 16)),
        content: Text(
          '"${item.judul}" akan dihapus.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    if (item.id != null && item.id! > 0) {
      final res = item.isTugas
          ? await TugasService.instance.hapusTugas(item.id!)
          : await MateriService.instance.hapusMateri(item.id!);
      if (!mounted) return;
      if (res['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal menghapus item')),
        );
        return;
      }
    }

    setState(() => topik.items.remove(item));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil dihapus')),
    );
  }

  // -------------------------------------------------------------------
  // ISI AREA DAFTAR TOPIK (loading / kosong / list)
  // -------------------------------------------------------------------
  Widget _buildIsi(List<_Topik> daftar) {
    if (_memuat) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _muatAwal,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_penugasan.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Anda belum memiliki kelas/mapel yang diampu.',
            textAlign: TextAlign.center,
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    if (daftar.isEmpty) {
      return Center(
        child: Text(
          'Belum ada topik.',
          style: AppTextStyle.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: daftar.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildTopik(daftar[i]),
    );
  }

  // -------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final daftar = _hasil;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Materi Pembelajaran',
                style: AppTextStyle.headingSmall.copyWith(fontSize: 16),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _Dropdown(
                      value: _kelas,
                      items: _kelasList,
                      hint: 'Pilih kelas',
                      onChanged: _gantiKelas,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Dropdown(
                      value: _mapel,
                      items: _mapelList,
                      hint: 'Pilih mapel',
                      onChanged: _gantiMapel,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _Kotak(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v.trim()),
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, size: 20),
                    hintText: 'Cari Materi....',
                    hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(child: _buildIsi(daftar)),
            ],
          ),
        ),

        // Tombol tambah topik.
        Positioned(
          right: 20,
          bottom: 16,
          child: ElevatedButton(
            onPressed: _tambahTopik,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              elevation: 3,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              '+ Tambah Topik',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // CARD TOPIK
  // -------------------------------------------------------------------
  Widget _buildTopik(_Topik t) {
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
                if (terbuka) ...[
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 22, color: Colors.redAccent),
                    tooltip: 'Hapus Topik',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _hapusTopik(t),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _pilihJenisUpload(t),
                    child: const Icon(Icons.add, size: 30),
                  ),
                ] else
                  const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),

          if (terbuka) ...[
            const SizedBox(height: 10),

            if (t.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Belum ada materi/tugas. Tekan + untuk menambah.',
                  style: AppTextStyle.bodySmall.copyWith(fontSize: 11),
                ),
              ),

            ...t.items.map((item) => _buildItem(t, item)),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // ITEM MATERI / TUGAS DI DALAM TOPIK
  // -------------------------------------------------------------------
  Widget _buildItem(_Topik t, _Item item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            item.isTugas ? Icons.assignment : Icons.description,
            size: 28,
            color: item.isTugas ? const Color(0xFF2F80ED) : _green,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.judul,
                  style: AppTextStyle.headingSmall.copyWith(fontSize: 13),
                ),
                if (item.sub.isNotEmpty)
                  Text(
                    item.sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodySmall.copyWith(fontSize: 10),
                  ),
              ],
            ),
          ),

          // EDIT
          InkWell(
            onTap: () {
              if (item.isTugas) {
                _bukaEditTugas(t, item);
              } else {
                _bukaEditMateri(t, item);
              }
            },
            child: const Icon(Icons.edit_outlined, size: 20),
          ),

          const SizedBox(width: 10),

          // HAPUS
          InkWell(
            onTap: () => _hapusItem(t, item),
            child: const Icon(Icons.delete_outline, size: 20),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// DIALOG TAMBAH TOPIK
// =====================================================================
class _TambahTopikDialog extends StatefulWidget {
  const _TambahTopikDialog();

  @override
  State<_TambahTopikDialog> createState() => _TambahTopikDialogState();
}

class _TambahTopikDialogState extends State<_TambahTopikDialog> {
  final _minggu = TextEditingController();
  final _nama = TextEditingController();

  DateTime _tanggal = DateTime.now();
  TimeOfDay _jam = TimeOfDay.now();

  @override
  void dispose() {
    _minggu.dispose();
    _nama.dispose();
    super.dispose();
  }

  String _formatTanggal(DateTime d) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (hasil != null) setState(() => _tanggal = hasil);
  }

  Future<void> _pilihJam() async {
    final hasil = await showTimePicker(context: context, initialTime: _jam);
    if (hasil != null) setState(() => _jam = hasil);
  }

  void _simpan() {
    final minggu = int.tryParse(_minggu.text.trim());

    if (minggu == null || _nama.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi minggu ke- dan nama topik dulu')),
      );
      return;
    }

    Navigator.pop(
      context,
      _Topik(
        minggu: minggu,
        nama: _nama.text.trim(),
        waktu: DateTime(
          _tanggal.year,
          _tanggal.month,
          _tanggal.day,
          _jam.hour,
          _jam.minute,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Minggu ke -',
                  style: AppTextStyle.headingSmall.copyWith(fontSize: 16),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 70,
                  child: _Kotak(
                    child: TextField(
                      controller: _minggu,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: '1',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const _Label('Nama Topik'),

            _Kotak(
              child: TextField(
                controller: _nama,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  hintText: 'Contoh: Persamaan Linear',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),

            const _Label('Tanggal dan Waktu'),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: _pilihTanggal,
                    borderRadius: BorderRadius.circular(10),
                    child: _Kotak(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          _formatTanggal(_tanggal),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: _pilihJam,
                    borderRadius: BorderRadius.circular(10),
                    child: _Kotak(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          '${_jam.hour.toString().padLeft(2, '0')}.'
                          '${_jam.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Center(
              child: SizedBox(
                width: 140,
                height: 42,
                child: ElevatedButton(
                  onPressed: _simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF219653),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// WIDGET KECIL PENDUKUNG
// =====================================================================

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        text,
        style: AppTextStyle.bodySmall.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Kotak putih dengan bayangan (dipakai input, dropdown, search).
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
  final String hint;
  final ValueChanged<String> onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint = '',
  });

  @override
  Widget build(BuildContext context) {
    return _Kotak(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text(hint, style: const TextStyle(fontSize: 12)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          style: const TextStyle(fontSize: 12, color: Colors.black),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _PilihanUpload extends StatelessWidget {
  final IconData icon;
  final Color warna;
  final String label;
  final VoidCallback onTap;

  const _PilihanUpload({
    required this.icon,
    required this.warna,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1EDEC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: warna),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}