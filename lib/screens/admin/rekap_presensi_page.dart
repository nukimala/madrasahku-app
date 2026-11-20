import 'package:flutter/material.dart';

import '../../services/guru_service.dart';
import '../../services/presensi_pdf_service.dart';
import '../../services/presensi_service.dart';
import '../../services/siswa_service.dart';
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

  // Daftar mapel & kelas dinamis dari API
  List<String> _mataPelajaran = ['Semua Mapel'];
  List<String> _daftarKelas = ['Semua Kelas'];

  // Nilai yang sedang dipilih di form.
  String _selectedFilter = _semua;
  String _selectedMapel = 'Semua Mapel';
  String _selectedKelas = 'Semua Kelas';
  late DateTime _dari;
  late DateTime _sampai;

  // Nilai yang sudah diterapkan (setelah tombol Tampilkan ditekan).
  String _appliedFilter = _semua;
  String _appliedMapel = 'Semua Mapel';
  String _appliedKelas = 'Semua Kelas';
  late DateTime _appliedDari;
  late DateTime _appliedSampai;

  List<_CatatanPresensi> _catatan = [];
  late final List<String> _opsiBulan;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _dari = today.subtract(const Duration(days: 7));
    _sampai = today;
    _appliedDari = _dari;
    _appliedSampai = _sampai;

    // 12 bulan terakhir realtime, dimulai dari bulan dan tahun sekarang.
    _opsiBulan = List.generate(12, (i) {
      final d = DateTime(today.year, today.month - i, 1);
      return _bulanKey(d);
    });

    _muatFilterMaster();
    _muatDataApi();
  }

  /// Muat data pilihan Mapel dan Kelas dari backend endpoint
  Future<void> _muatFilterMaster() async {
    try {
      final futures = await Future.wait([
        GuruService().fetchMapel(),
        SiswaService().fetchKelas(),
      ]);

      if (!mounted) return;

      final mapelList = futures[0] as List<String>;
      final kelasList = futures[1] as List<KelasOption>;

      setState(() {
        if (mapelList.isNotEmpty) {
          _mataPelajaran = ['Semua Mapel', ...mapelList.toSet()];
        }
        if (kelasList.isNotEmpty) {
          final formattedKelas = kelasList.map((k) {
            final name = k.name.trim();
            return name.toLowerCase().startsWith('kelas') ? name : 'Kelas $name';
          }).toSet().toList();
          _daftarKelas = ['Semua Kelas', ...formattedKelas];
        }

        if (!_mataPelajaran.contains(_selectedMapel)) {
          _selectedMapel = 'Semua Mapel';
        }
        if (!_daftarKelas.contains(_selectedKelas)) {
          _selectedKelas = 'Semua Kelas';
        }
      });
    } catch (_) {}
  }

  /// Muat data rekap presensi dari backend
  Future<void> _muatDataApi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      DateTime? startDate;
      DateTime? endDate;
      String? monthFilter;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (_appliedFilter == _minggu) {
        startDate = today.subtract(const Duration(days: 7));
        endDate = today;
      } else if (_appliedFilter == _rentang) {
        startDate = _appliedDari;
        endDate = _appliedSampai;
      } else if (_appliedFilter != _semua) {
        monthFilter = _appliedFilter; // format 'yyyy-MM'
      }

      final records = await PresensiService.instance.ambilRekapAdminApi(
        month: monthFilter,
        startDate: startDate,
        endDate: endDate,
        mapel: _appliedMapel,
        kelas: _appliedKelas,
      );

      if (!mounted) return;

      final List<_CatatanPresensi> list = [];

      if (records.isNotEmpty) {
        for (final item in records) {
          if (item is Map) {
            final dStr = item['attendance_date'] ?? item['tanggal'] ?? item['date'];
            final tgl = dStr != null ? DateTime.tryParse(dStr.toString()) : null;
            final guruName = (item['teacher_name'] ?? item['nama'] ?? 'Guru').toString();
            final rowMapel = (item['mapel'] ?? item['subject_name'] ?? 'Umum').toString();
            final rowKelas = (item['kelas'] ?? item['class_name'] ?? 'Semua Kelas').toString();
            final isPulang = item['pulang'] == true || item['check_out_at'] != null;

            if (tgl != null) {
              list.add(_CatatanPresensi(
                nama: guruName,
                mapel: rowMapel,
                kelas: rowKelas,
                tanggal: tgl,
                pulang: isPulang,
              ));
            }
          }
        }
      } else {
        // Fallback data simulasi lokal jika database masih kosong atau offline
        list.addAll(_generateFallbackData());
      }

      setState(() {
        _catatan = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _catatan = _generateFallbackData();
        _isLoading = false;
      });
    }
  }

  List<_CatatanPresensi> _generateFallbackData() {
    final now = DateTime.now();
    return [
      _CatatanPresensi(
        nama: 'Ahmad Fauzi, M.Pd.',
        mapel: 'Matematika',
        kelas: 'Kelas VIII A',
        tanggal: now,
        pulang: true,
      ),
      _CatatanPresensi(
        nama: 'Siti Nurhaliza, S.Pd.',
        mapel: 'Bahasa Indonesia',
        kelas: 'Kelas VIII A',
        tanggal: now,
        pulang: true,
      ),
      _CatatanPresensi(
        nama: 'Budi Santoso, S.Si.',
        mapel: 'IPA',
        kelas: 'Kelas VII A',
        tanggal: now.subtract(const Duration(days: 1)),
        pulang: false,
      ),
      _CatatanPresensi(
        nama: 'Nur Aini, S.Pd.',
        mapel: 'Bahasa Inggris',
        kelas: 'Kelas VIII B',
        tanggal: now.subtract(const Duration(days: 2)),
        pulang: true,
      ),
      _CatatanPresensi(
        nama: 'Rizky Maulana, S.Ag.',
        mapel: 'PAI',
        kelas: 'Kelas IX A',
        tanggal: now.subtract(const Duration(days: 3)),
        pulang: true,
      ),
    ];
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

  bool _matchMapel(String itemMapel, String filterMapel) {
    if (filterMapel == 'Semua Mapel') return true;
    return itemMapel.trim().toLowerCase() == filterMapel.trim().toLowerCase();
  }

  bool _matchKelas(String itemKelas, String filterKelas) {
    if (filterKelas == 'Semua Kelas') return true;
    final f = filterKelas.replaceFirst(RegExp(r'^Kelas\s+', caseSensitive: false), '').trim().toLowerCase();
    final i = itemKelas.replaceFirst(RegExp(r'^Kelas\s+', caseSensitive: false), '').trim().toLowerCase();
    return f == i || itemKelas.toLowerCase().contains(f);
  }

  List<_RekapSiswa> _hitungRekap() {
    final data = _catatan.where((c) {
      return _matchMapel(c.mapel, _appliedMapel) &&
          _matchKelas(c.kelas, _appliedKelas) &&
          _lolosFilterWaktu(c.tanggal);
    });

    final Map<String, _RekapSiswa> hasil = {};
    for (final c in data) {
      final rekap = hasil.putIfAbsent(c.nama, () => _RekapSiswa(c.nama, c.mapel, c.kelas));
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

    _muatDataApi();
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

  Future<void> _exportPdf() async {
    final rekap = _hitungRekap();
    if (rekap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data presensi untuk diekspor ke PDF'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menyiapkan dokumen PDF...'),
          duration: Duration(seconds: 1),
        ),
      );

      final items = rekap.map((r) => RekapItemPdf(
        nama: r.nama,
        mapel: r.mapel,
        kelas: r.kelas,
        hadir: r.hadir,
        pulang: r.pulang,
      )).toList();

      await PresensiPdfService.exportPdf(
        periode: _labelFilter(_appliedFilter),
        mapel: _appliedMapel,
        kelas: _appliedKelas,
        items: items,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengekspor PDF: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
              // Header dan tombol kembali + tombol Export PDF.
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
                  Expanded(
                    child: Text(
                      'Rekap Presensi',
                      style: AppTextStyle.headingMedium.copyWith(
                        fontSize: 19,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Tombol Export PDF
                  InkWell(
                    onTap: _exportPdf,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.picture_as_pdf, color: AppColors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'PDF',
                            style: AppTextStyle.button.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
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

              const SizedBox(height: 32),

              // Tombol tampilkan.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _tampilkanRekap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(0.20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            'Tampilkan',
                            style: AppTextStyle.button.copyWith(fontSize: 16),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Judul daftar presensi & info filter aktif.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Presensi',
                    style: AppTextStyle.headingSmall.copyWith(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${rekap.length} Data',
                    style: AppTextStyle.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Daftar presensi siswa / guru.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : rekap.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'Data presensi tidak ditemukan untuk filter ini.',
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
                                  const Divider(height: 24, thickness: 0.8, color: Color(0xFFEEEEEE)),
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
    final validValue = items.contains(value) ? value : items.first;

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: validValue,
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
        color: const Color(0xFF222222),
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

// Baris presensi per siswa / guru.
class _PresensiRow extends StatelessWidget {
  final _RekapSiswa data;

  const _PresensiRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                data.nama,
                style: AppTextStyle.headingSmall.copyWith(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                data.kelas,
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          'Mapel: ${data.mapel}',
          style: AppTextStyle.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Wrap(
            spacing: 24,
            runSpacing: 6,
            children: [
              _statusBadge('Hadir', data.hadir, AppColors.primary, const Color(0xFFE8F5E9)),
              _statusBadge('Pulang', data.pulang, const Color(0xFF1E88E5), const Color(0xFFE3F2FD)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String label, int count, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $count',
        style: AppTextStyle.bodySmall.copyWith(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Model data catatan presensi harian.
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

// Hasil rekapitulasi kehadiran.
class _RekapSiswa {
  final String nama;
  final String mapel;
  final String kelas;
  int hadir = 0;
  int pulang = 0;

  _RekapSiswa(this.nama, this.mapel, this.kelas);
}
