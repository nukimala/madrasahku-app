
import 'package:flutter/material.dart';

import '../../utilis/app_colors.dart';
import '../../utilis/app_text_style.dart';

class RekapPresensiPage extends StatefulWidget {
  const RekapPresensiPage({super.key});

  @override
  State<RekapPresensiPage> createState() => _RekapPresensiPageState();
}

class _RekapPresensiPageState extends State<RekapPresensiPage> {
  final TextEditingController _namaController =
      TextEditingController();

  String _selectedMapel = 'Matematika';
  String _appliedNama = '';
  String _appliedMapel = 'Matematika';
  bool _hasShown = false;

  static const List<String> _mataPelajaran = [
    'Matematika',
    'Bahasa Indonesia',
    'IPA',
  ];

  // Data contoh untuk tampilan.
  static const List<_PresensiMapel> _dataPresensi = [
    _PresensiMapel(
      nama: 'Matematika',
      hadir: 25,
      izin: 2,
      sakit: 1,
      alpha: 2,
      namaGuru: 'Guru Matematika',
    ),
    _PresensiMapel(
      nama: 'Bahasa Indonesia',
      hadir: 25,
      izin: 2,
      sakit: 1,
      alpha: 2,
      namaGuru: 'Guru Bahasa Indonesia',
    ),
    _PresensiMapel(
      nama: 'IPA',
      hadir: 25,
      izin: 2,
      sakit: 1,
      alpha: 2,
      namaGuru: 'Guru IPA',
    ),
  ];

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  void _tampilkanRekap() {
    FocusScope.of(context).unfocus();

    setState(() {
      _appliedNama = _namaController.text.trim();
      _appliedMapel = _selectedMapel;
      _hasShown = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _dataPresensi.where((item) {
      final cocokMapel =
          !_hasShown || item.nama == _appliedMapel;

      final query = _appliedNama.toLowerCase();

      final cocokNama = query.isEmpty ||
          item.namaGuru.toLowerCase().contains(query) ||
          item.nama.toLowerCase().contains(query);

      return cocokMapel && cocokNama;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dan tombol kembali.
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 27,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rekap Presensi',
                    style: AppTextStyle.headingMedium.copyWith(
                      fontSize: 19,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Form pencarian.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih nama',
                      style: _labelStyle,
                    ),
                    const SizedBox(height: 12),

                    _InputSurface(
                      child: TextField(
                        controller: _namaController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _tampilkanRekap(),
                        style: AppTextStyle.bodyLarge.copyWith(
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama guru',
                          hintStyle:
                              AppTextStyle.bodyLarge.copyWith(
                            color: const Color(0xFF929292),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 34,
                            vertical: 15,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Pilih mapel yang diampu',
                      style: _labelStyle,
                    ),
                    const SizedBox(height: 8),

                    _InputSurface(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedMapel,
                          isExpanded: true,
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 28,
                              color: Color(0xFF222222),
                            ),
                          ),
                          padding: const EdgeInsets.only(left: 34),
                          borderRadius: BorderRadius.circular(14),
                          style: AppTextStyle.bodyLarge.copyWith(
                            color: const Color(0xFF929292),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          items: _mataPelajaran.map((mapel) {
                            return DropdownMenuItem<String>(
                              value: mapel,
                              child: Text(mapel),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedMapel = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 56),

              // Tombol tampilkan.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 44,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _tampilkanRekap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 7,
                      shadowColor:
                          Colors.black.withOpacity(0.20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                    ),
                    child: Text(
                      'Tampilkan',
                      style: AppTextStyle.button.copyWith(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Kartu statistik presensi.
              Row(
                children: const [
                  Expanded(
                    child: _StatCard(
                      title: 'Hadir',
                      count: '245',
                      background: Color(0xFFD9F6D0),
                      foreground: Color(0xFF159947),
                    ),
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: _StatCard(
                      title: 'Izin',
                      count: '12',
                      background: Color(0xFFFFF0E4),
                      foreground: Color(0xFFFF7A1A),
                    ),
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: _StatCard(
                      title: 'Sakit',
                      count: '8',
                      background: Color(0xFFE1EEFF),
                      foreground: Color(0xFF559AFF),
                    ),
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: _StatCard(
                      title: 'Alpha',
                      count: '5',
                      background: Color(0xFFFFDCDC),
                      foreground: Color(0xFFFF2525),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Judul daftar presensi.
              Text(
                'Daftar Presensi',
                style: AppTextStyle.headingSmall.copyWith(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 24),

              // Daftar mata pelajaran.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  28, 24, 20, 24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.13),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: filteredData.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                        child: Center(
                          child: Text(
                            'Data presensi tidak ditemukan.',
                            textAlign: TextAlign.center,
                            style: AppTextStyle.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          for (int i = 0;
                              i < filteredData.length;
                              i++) ...[
                            _PresensiRow(
                              data: filteredData[i],
                            ),
                            if (i != filteredData.length - 1)
                              const SizedBox(height: 16),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _labelStyle =>
      AppTextStyle.headingSmall.copyWith(
        color: Colors.black,
        fontSize: 15,
      );
}

// Input putih dengan bayangan.
class _InputSurface extends StatelessWidget {
  final Widget child;

  const _InputSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 47,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Kartu statistik.
class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final Color background;
  final Color foreground;

  const _StatCard({
    required this.title,
    required this.count,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(
        vertical: 13,
        horizontal: 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: AppTextStyle.headingSmall.copyWith(
                color: foreground,
                fontSize: 15,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count,
              style: AppTextStyle.headingSmall.copyWith(
                color: foreground,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Baris daftar presensi per mata pelajaran.
class _PresensiRow extends StatelessWidget {
  final _PresensiMapel data;

  const _PresensiRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.nama,
          style: AppTextStyle.headingSmall.copyWith(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            _status('Hadir: ${data.hadir}'),
            _status('Izin: ${data.izin}'),
            _status('Sakit: ${data.sakit}'),
            _status('Alpha: ${data.alpha}'),
          ],
        ),
      ],
    );
  }

  Widget _status(String text) {
    return Text(
      text,
      style: AppTextStyle.bodyLarge.copyWith(
        color: const Color(0xFF929292),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// Model data contoh.
class _PresensiMapel {
  final String nama;
  final int hadir;
  final int izin;
  final int sakit;
  final int alpha;
  final String namaGuru;

  const _PresensiMapel({
    required this.nama,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alpha,
    required this.namaGuru,
  });
}
