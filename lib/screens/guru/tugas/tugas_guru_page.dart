import 'package:flutter/material.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

import 'pengumpulan_tugas.dart';
import '../../../models/tugas_model.dart';

class TugasGuruPage extends StatefulWidget {
  const TugasGuruPage({super.key});

  @override
  State<TugasGuruPage> createState() => _TugasGuruPageState();
}

class _TugasGuruPageState extends State<TugasGuruPage> {
  static const Color _topikBg = Color(0xFFF1EDEC);

  static const _kelasList = [
    'Kelas VII A',
    'Kelas VII B',
    'Kelas VIII A',
    'Kelas VIII B',
    'Kelas IX A',
  ];

  static const _mapelList = [
    'Matematika',
    'Bahasa Indonesia',
    'IPA',
    'IPS',
    'Bahasa Inggris',
  ];

  String _kelas = 'Kelas VIII A';
  String _mapel = 'Matematika';
  String _query = '';

  final List<TopikTugas> _topik = contohTopikTugas();
  final Set<TopikTugas> _terbuka = {};

  @override
  void initState() {
    super.initState();
    // Topik pertama terbuka di awal.
    if (_topik.isNotEmpty) _terbuka.add(_topik.first);
  }

  List<TopikTugas> get _hasil {
    final q = _query.toLowerCase();

    return _topik.where((t) {
      if (t.kelas != _kelas || t.mapel != _mapel) return false;
      if (q.isEmpty) return true;

      return t.judul.toLowerCase().contains(q) ||
          t.tugas.any((x) => x.judul.toLowerCase().contains(q));
    }).toList();
  }

  // Buka halaman penilaian tugas.
  Future<void> _bukaTugas(TopikTugas topik, TugasGuru tugas) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => PengumpulanTugasPage(
          minggu: topik.minggu,
          kelas: topik.kelas,
          tugas: tugas,
        ),
      ),
    );

    // Refresh setelah kembali (nilai mungkin berubah).
    if (mounted) setState(() {});
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
                  onChanged: (v) => setState(() => _kelas = v),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _Dropdown(
                  value: _mapel,
                  items: _mapelList,
                  onChanged: (v) => setState(() => _mapel = v),
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
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
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
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

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
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}