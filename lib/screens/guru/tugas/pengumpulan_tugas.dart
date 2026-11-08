import 'package:flutter/material.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

import '../../../models/tugas_model.dart';

class PengumpulanTugasPage extends StatefulWidget {
  final int minggu;
  final String kelas;
  final TugasGuru tugas;

  const PengumpulanTugasPage({
    super.key,
    required this.minggu,
    required this.kelas,
    required this.tugas,
  });

  @override
  State<PengumpulanTugasPage> createState() => _PengumpulanTugasPageState();
}

class _PengumpulanTugasPageState extends State<PengumpulanTugasPage> {
  static const Color _green = Color(0xFF219653);

  // null = Semua
  StatusSiswa? _filter;
  String _query = '';

  // Daftar filter digeser ke samping.
  static const List<(String, StatusSiswa?)> _opsiFilter = [
    ('Semua', null),
    ('Selesai', StatusSiswa.selesai),
    ('Terlambat', StatusSiswa.terlambat),
    ('Belum Mengumpulkan', StatusSiswa.belum),
  ];

  List<SiswaTugas> get _hasil {
    final q = _query.toLowerCase();

    return widget.tugas.siswa.where((s) {
      final cocokNama = q.isEmpty || s.nama.toLowerCase().contains(q);
      final cocokStatus =
          _filter == null || widget.tugas.statusDari(s) == _filter;
      return cocokNama && cocokStatus;
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
              // Header.
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

              // Daftar siswa.
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
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: daftar.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _buildSiswa(daftar[i]),
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