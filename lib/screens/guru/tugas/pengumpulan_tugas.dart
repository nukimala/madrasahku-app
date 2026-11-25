import 'package:flutter/material.dart';

import '../../../models/siswa_model.dart';
import '../../../models/tugas_model.dart';
import '../../../services/tugas_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class PengumpulanTugasPage extends StatefulWidget {
  final int minggu;
  final String kelas;
  final TugasGuru tugas;
  final TugasItem? tugasItem; // Opsional: untuk refresh/manual fetch

  const PengumpulanTugasPage({
    super.key,
    required this.minggu,
    required this.kelas,
    required this.tugas,
    this.tugasItem,
  });

  @override
  State<PengumpulanTugasPage> createState() => _PengumpulanTugasPageState();
}

class _PengumpulanTugasPageState extends State<PengumpulanTugasPage> {
  static const Color _green = Color(0xFF219653);

  // null = Semua
  StatusSiswa? _filter;
  String _query = '';
  bool _loading = false;
  
  // Local state untuk list siswa (bisa di-update saat refresh)
  late List<SiswaTugas> _siswaTugas;

  // Daftar filter digeser ke samping.
  static const List<(String, StatusSiswa?)> _opsiFilter = [
    ('Semua', null),
    ('Selesai', StatusSiswa.selesai),
    ('Terlambat', StatusSiswa.terlambat),
    ('Belum Mengumpulkan', StatusSiswa.belum),
  ];

  @override
  void initState() {
    super.initState();
    _siswaTugas = List.from(widget.tugas.siswa);
  }

  @override
  void didUpdateWidget(covariant PengumpulanTugasPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tugas != oldWidget.tugas) {
      _siswaTugas = List.from(widget.tugas.siswa);
    }
  }

  List<SiswaTugas> get _hasil {
    final q = _query.toLowerCase();

    return _siswaTugas.where((s) {
      final cocokNama = q.isEmpty || s.nama.toLowerCase().contains(q);
      final cocokStatus =
          _filter == null || widget.tugas.statusDari(s) == _filter;
      return cocokNama && cocokStatus;
    }).toList();
  }

  /// Refresh data pengumpulan dari server
  Future<void> _refreshData() async {
    final tugasItem = widget.tugasItem;
    if (tugasItem == null) return;

    setState(() => _loading = true);
    try {
      final detailRes = await TugasService.instance.ambilDetailPengumpulanTugas(tugasItem.id);
      final siswaList = tugasItem.classId > 0
          ? await TugasService.instance.ambilSiswaKelas(tugasItem.classId)
          : <SiswaItem>[];

      if (!mounted) return;

      final siswaTugas = _parsePengumpulanData(
        detailRes['data'],
        siswaList,
        tugasItem.deadline,
      );

      setState(() {
        _siswaTugas = siswaTugas;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data diperbarui')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal refresh: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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

    return siswaKelas.map((siswa) {
      final waktuKumpul = siswa.id != null ? submitMap[siswa.id!] : null;
      return SiswaTugas(
        nama: siswa.nama,
        waktuKumpul: waktuKumpul,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tugas;
    final daftar = _hasil;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan tombol refresh.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.arrow_back, size: 22),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.judul,
                          style: AppTextStyle.headingSmall.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Minggu ${widget.minggu} - ${widget.kelas} - '
                          'Deadline ${formatTglJamPendek(t.deadline)}',
                          style: AppTextStyle.bodySmall.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  // Tombol refresh
                  if (widget.tugasItem != null)
                    IconButton(
                      onPressed: _loading ? null : _refreshData,
                      icon: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh, size: 22),
                      tooltip: 'Refresh data pengumpulan',
                    ),
                ],
              ),

              const SizedBox(height: 18),

              // Kolom cari.
              _Kotak(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v.trim()),
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, size: 20),
                    hintText: 'Cari Siswa....',
                    hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Filter status: bisa digeser ke samping.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: _opsiFilter
                      .map((o) => _buildChip(o.$1, o.$2))
                      .toList(),
                ),
              ),

              const SizedBox(height: 14),

              // Daftar siswa dengan pull-to-refresh.
              Expanded(
                child: daftar.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada data.',
                          style: AppTextStyle.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshData,
                        child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: daftar.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _buildSiswa(daftar[i]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, StatusSiswa? status) {
    final aktif = _filter == status;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => _filter = status),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: aktif ? _green : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: aktif ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSiswa(SiswaTugas s) {
    final status = widget.tugas.statusDari(s);

    late final String label;
    late final Color warna;

    switch (status) {
      case StatusSiswa.terlambat:
        label = 'Terlambat';
        warna = const Color(0xFFD64545);
        break;
      case StatusSiswa.selesai:
        label = 'Selesai';
        warna = _green;
        break;
      case StatusSiswa.belum:
        label = 'Belum Mengumpulkan';
        warna = const Color(0xFFF2994A);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.nama,
                  style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  s.waktuKumpul == null
                      ? 'Belum mengumpulkan'
                      : 'Dikumpulkan ${formatTglJamPendek(s.waktuKumpul!)}',
                  style: AppTextStyle.bodySmall.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: warna,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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