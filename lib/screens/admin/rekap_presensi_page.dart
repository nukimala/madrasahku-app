import 'package:flutter/material.dart';

import '../../services/presensi_service.dart';
import '../../utilis/app_colors.dart';
import '../../utilis/app_text_style.dart';

class RekapPresensiPage extends StatefulWidget {
  const RekapPresensiPage({super.key});

  @override
  State<RekapPresensiPage> createState() => _RekapPresensiPageState();
}

class _RekapPresensiPageState extends State<RekapPresensiPage> {
  // Nilai filter waktu: 'semua', 'minggu', 'rentang', atau 'yyyy-MM'.
  static const String _semua = 'semua';
  static const String _minggu = 'minggu';
  static const String _rentang = 'rentang';

  static const List<String> _namaBulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _mataPelajaran = [
    'Matematika',
    'Bahasa Indonesia',
    'IPA',
  ];

  static const List<String> _daftarKelas = [
    'Kelas VII A',
    'Kelas VII B',
    'Kelas VIII A',
    'Kelas VIII B',
    'Kelas IX A',
    'Kelas IX B',
  ];

  // Nilai yang sedang dipilih di form.
  String _selectedFilter = _semua;
  String _selectedMapel = 'Matematika';
  String _selectedKelas = 'Kelas VIII A';
  late DateTime _dari;
  late DateTime _sampai;

  // Nilai yang sudah diterapkan (setelah tombol Tampilkan ditekan).
  String _appliedFilter = _semua;
  String _appliedMapel = 'Matematika';
  String _appliedKelas = 'Kelas VIII A';
  late DateTime _appliedDari;
  late DateTime _appliedSampai;

  late final List<_CatatanPresensi> _catatan;
  late final List<String> _opsiBulan;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _dari = today.subtract(const Duration(days: 7));
    _sampai = today;
    _appliedDari = _dari;
    _appliedSampai = _sampai;

    // 12 bulan terakhir, dimulai dari bulan sekarang.
    _opsiBulan = List.generate(12, (i) {
      final d = DateTime(today.year, today.month - i, 1);
      return _bulanKey(d);
    });

    _catatan = [];
    _muatDataApi();
  }

  Future<void> _muatDataApi() async {
    try {
      final history = await PresensiService.instance.ambilRiwayatApi();
      if (history.isNotEmpty && mounted) {
        setState(() {
          _catatan.clear();
          for (final item in history) {
            if (item is Map) {
              final dStr = item['date'] ?? item['attendance_date'];
              final tgl = dStr != null ? DateTime.tryParse(dStr.toString()) : null;
              final guruName = item['teacher_name'] ?? item['teacher'] ?? 'Guru';
              if (tgl != null) {
                _catatan.add(_CatatanPresensi(
                  nama: guruName.toString(),
                  mapel: 'Umum',
                  kelas: 'Semua',
                  tanggal: tgl,
                  pulang: item['check_out_at'] != null,
                ));
              }
            }
          }
        });
      }
    } catch (_) {}
  }

  String _bulanKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  String _labelBulan(String key) {
    final parts = key.split('-');
    final tahun = parts[0];
    final bulan = int.parse(parts[1]);
    return '${_namaBulan[bulan - 1]} $tahun';
  }

  String _labelFilter(String value) {
    switch (value) {
      case _semua:
        return 'Semua Bulan';
      case _minggu:
        return 'Seminggu Lalu';
      case _rentang:
        return 'Pilih Rentang Waktu';
      default:
        return _labelBulan(value);
    }
  }

  String _formatTanggal(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  bool _lolosFilterWaktu(DateTime tanggal) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_appliedFilter) {
      case _semua:
        return true;
      case _minggu:
        return !tanggal.isBefore(today.subtract(const Duration(days: 7))) &&
            !tanggal.isAfter(today);
      case _rentang:
        return !tanggal.isBefore(_appliedDari) &&
            !tanggal.isAfter(_appliedSampai);
      default:
        return _bulanKey(tanggal) == _appliedFilter;
    }
  }

  List<_RekapSiswa> _hitungRekap() {
    final data = _catatan.where((c) {
      return c.mapel == _appliedMapel &&
          c.kelas == _appliedKelas &&
          _lolosFilterWaktu(c.tanggal);
    });

    final Map<String, _RekapSiswa> hasil = {};
    for (final c in data) {
      final rekap = hasil.putIfAbsent(c.nama, () => _RekapSiswa(c.nama));
      if (c.pulang) {
        rekap.pulang++;
      } else {
        rekap.hadir++;
      }
    }

    return hasil.values.toList();
  }

  void _tampilkanRekap() {
    FocusScope.of(context).unfocus();

    setState(() {
      _appliedFilter = _selectedFilter;
      _appliedMapel = _selectedMapel;
      _appliedKelas = _selectedKelas;
      _appliedDari = _dari;
      _appliedSampai = _sampai;
    });
  }

  Future<void> _bukaDialogFilter() async {
    final hasil = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) {
        return _FilterDialog(
          selected: _selectedFilter,
          opsiBulan: _opsiBulan,
          labelBulan: _labelBulan,
        );
      },
    );

    if (hasil != null) {
      setState(() {
        _selectedFilter = hasil;
      });
    }
  }

  Future<void> _pilihTanggal({required bool isDari}) async {
    final initial = isDari ? _dari : _sampai;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      if (isDari) {
        _dari = picked;
        if (_sampai.isBefore(_dari)) _sampai = _dari;
      } else {
        _sampai = picked;
        if (_dari.isAfter(_sampai)) _dari = _sampai;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rekap = _hitungRekap();

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
                    icon: const Icon(Icons.arrow_back, size: 27),
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

              // Form filter.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pilih filter', style: _labelStyle),
                    const SizedBox(height: 12),

                    // Dropdown filter waktu (membuka dialog).
                    InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: _bukaDialogFilter,
                      child: _InputSurface(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 34, right: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _labelFilter(_selectedFilter),
                                  style: _valueStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 28,
                                color: Color(0xFF222222),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Dari - Sampai (hanya untuk rentang waktu).
                    if (_selectedFilter == _rentang) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _DateField(
                            label: 'Dari',
                            value: _formatTanggal(_dari),
                            onTap: () => _pilihTanggal(isDari: true),
                          ),
                          const SizedBox(width: 16),
                          _DateField(
                            label: 'Sampai',
                            value: _formatTanggal(_sampai),
                            onTap: () => _pilihTanggal(isDari: false),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    Text('Pilih Mapel', style: _labelStyle),
                    const SizedBox(height: 12),

                    _InputSurface(
                      child: _buildDropdown(
                        value: _selectedMapel,
                        items: _mataPelajaran,
                        onChanged: (v) => setState(() => _selectedMapel = v),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text('Pilih Kelas', style: _labelStyle),
                    const SizedBox(height: 12),

                    _InputSurface(
                      child: _buildDropdown(
                        value: _selectedKelas,
                        items: _daftarKelas,
                        onChanged: (v) => setState(() => _selectedKelas = v),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Tombol tampilkan.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _tampilkanRekap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 7,
                      shadowColor: Colors.black.withOpacity(0.20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                    ),
                    child: Text(
                      'Tampilkan',
                      style: AppTextStyle.button.copyWith(fontSize: 16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Judul daftar presensi.
              Text(
                'Daftar Presensi',
                style: AppTextStyle.headingSmall.copyWith(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 20),

              // Daftar presensi siswa.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 24, 20, 24),
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
                child: rekap.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < rekap.length; i++) ...[
                            _PresensiRow(data: rekap[i]),
                            if (i != rekap.length - 1)
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

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
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
        style: _valueStyle,
        items: items
            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }

  TextStyle get _labelStyle => AppTextStyle.headingSmall.copyWith(
        color: Colors.black,
        fontSize: 15,
      );

  TextStyle get _valueStyle => AppTextStyle.bodyLarge.copyWith(
        color: const Color(0xFF929292),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );
}

// Dialog pilihan filter waktu.
class _FilterDialog extends StatelessWidget {
  final String selected;
  final List<String> opsiBulan;
  final String Function(String) labelBulan;

  const _FilterDialog({
    required this.selected,
    required this.opsiBulan,
    required this.labelBulan,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          children: [
            _opsi(context, 'Semua Bulan', 'semua'),
            _opsi(context, 'Seminggu Lalu', 'minggu'),
            _opsi(
              context,
              'Pilih Rentang Waktu',
              'rentang',
              icon: Icons.access_time,
            ),
            for (final key in opsiBulan) _opsi(context, labelBulan(key), key),
          ],
        ),
      ),
    );
  }

  Widget _opsi(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
  }) {
    final isSelected = selected == value;

    return InkWell(
      onTap: () => Navigator.pop(context, value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE3E3E3), width: 1),
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.black),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                label,
                style: AppTextStyle.bodyLarge.copyWith(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 22,
              color: isSelected ? AppColors.primary : Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

// Field tanggal kecil (Dari / Sampai).
class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.bodyLarge.copyWith(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 112,
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: AppTextStyle.bodyLarge.copyWith(
                      color: const Color(0xFF222222),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: Color(0xFF222222),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
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

// Baris presensi per siswa.
class _PresensiRow extends StatelessWidget {
  final _RekapSiswa data;

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
        Padding(
          padding: const EdgeInsets.only(left: 13),
          child: Wrap(
            spacing: 28,
            runSpacing: 6,
            children: [
              _status('Hadir: ${data.hadir}'),
              _status('Pulang: ${data.pulang}'),
            ],
          ),
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

// Model data contoh (satu catatan per siswa per hari).
class _CatatanPresensi {
  final String nama;
  final String mapel;
  final String kelas;
  final DateTime tanggal;
  final bool pulang;

  const _CatatanPresensi({
    required this.nama,
    required this.mapel,
    required this.kelas,
    required this.tanggal,
    required this.pulang,
  });
}

// Hasil rekap per siswa.
class _RekapSiswa {
  final String nama;
  int hadir = 0;
  int pulang = 0;

  _RekapSiswa(this.nama);
}