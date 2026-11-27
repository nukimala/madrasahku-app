import 'package:flutter/material.dart';

import '../../../models/jadwal_model.dart';
import '../../../services/jadwal_service.dart';
import '../../../services/master_data_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class TambahJadwalPage extends StatefulWidget {
  final String tahunAjaran;
  final Semester semester;
  final String? kelas;
  final HariSekolah hari;
  final JadwalPelajaran? jadwal;

  const TambahJadwalPage({
    super.key,
    required this.tahunAjaran,
    required this.semester,
    required this.kelas,
    required this.hari,
    this.jadwal,
  });

  @override
  State<TambahJadwalPage> createState() => _TambahJadwalPageState();
}

class _TambahJadwalPageState extends State<TambahJadwalPage> {
  final _formKey = GlobalKey<FormState>();
  late HariSekolah _hari;
  late int _mulaiMenit;
  late int _selesaiMenit;
  late bool _hasClass;
  String? _kelas;
  String? _mapel;
  String? _guru;
  String? _ruang;
  bool _isSaving = false;

  // Daftar kelas dan ruang untuk dropdown.
  // Awalnya diisi data bawaan (fallback) agar langsung siap saat render pertama,
  // lalu diperbarui dari database melalui MasterDataService.
  late List<String> _daftarKelas;
  late List<String> _daftarRuang;

  bool get _isEditing => widget.jadwal != null;

  @override
  void initState() {
    super.initState();
    final jadwal = widget.jadwal;
    _hari = jadwal?.hari ?? widget.hari;
    _mulaiMenit = jadwal?.mulaiMenit ?? 7 * 60;
    _selesaiMenit = jadwal?.selesaiMenit ?? 7 * 60 + 40;
    _kelas = jadwal?.kelas ?? widget.kelas;
    _hasClass = _kelas != null;
    _mapel = jadwal?.mataPelajaran;
    _guru = jadwal?.guru;
    // Saat tambah jadwal baru dengan kelas terpilih, isi ruang otomatis sesuai kelasnya.
    _ruang =
        jadwal?.ruang ??
        (_hasClass && _kelas != null ? 'Ruang Kelas $_kelas' : null);

    _daftarKelas = {...JadwalService.daftarKelas, ?_kelas}.toList();
    _daftarRuang = {...JadwalService.daftarRuang, ?_ruang}.toList();
    _loadKelasDanRuang();
  }

  /// Mengambil daftar kelas terbaru dari API/database agar pilihan kelas dan
  /// ruang di form jadwal selalu sinkron dengan Data Kelas di server.
  Future<void> _loadKelasDanRuang() async {
    try {
      final kelasList = await MasterDataService.instance.fetchKelas();
      if (!mounted || kelasList.isEmpty) return;

      final kelasNames = kelasList
          .map((k) => k.nama.trim())
          .where((nama) => nama.isNotEmpty)
          .toSet();
      final ruangNames = kelasNames
          .map(
            (nama) => nama.startsWith('Kelas ')
                ? 'Ruang $nama'
                : 'Ruang Kelas $nama',
          )
          .toSet();

      setState(() {
        _daftarKelas = <String>{...kelasNames, ?_kelas}.toList();
        _daftarRuang = <String>{...ruangNames, ?_ruang}.toList();
      });
    } catch (_) {
      // Jika offline / gagal memuat dari API, tetap gunakan data fallback awal.
    }
  }

  Future<void> _pilihWaktu({required bool waktuMulai}) async {
    final menitSaatIni = waktuMulai ? _mulaiMenit : _selesaiMenit;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: menitSaatIni ~/ 60,
        minute: menitSaatIni % 60,
      ),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.primary,
            surface: AppColors.white,
            onSurface: AppColors.textPrimary,
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: AppColors.white,
            dialBackgroundColor: const Color(0xFFF9FAFB),
            dialHandColor: AppColors.primary,
            dialTextColor: AppColors.textPrimary,
            hourMinuteColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.primaryLight
                  : const Color(0xFFF3F4F6),
            ),
            hourMinuteTextColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.primaryDark
                  : AppColors.textPrimary,
            ),
            dayPeriodColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.primaryLight
                  : AppColors.white,
            ),
            dayPeriodTextColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.primaryDark
                  : AppColors.textSecondary,
            ),
            dayPeriodBorderSide: const BorderSide(color: AppColors.border),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;

    setState(() {
      final menit = picked.hour * 60 + picked.minute;
      if (waktuMulai) {
        _mulaiMenit = menit;
      } else {
        _selesaiMenit = menit;
      }
    });
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final jadwal = JadwalPelajaran(
      id: widget.jadwal?.id ?? 0,
      tahunAjaran: widget.tahunAjaran,
      semester: widget.semester,
      kelas: _hasClass ? _kelas : null,
      hari: _hari,
      mulaiMenit: _mulaiMenit,
      selesaiMenit: _selesaiMenit,
      mataPelajaran: _mapel!,
      guru: _guru!,
      ruang: _ruang,
    );
    setState(() => _isSaving = true);
    try {
      final error = await JadwalService.instance.simpan(
        jadwal,
        kecualiId: widget.jadwal?.id,
      );
      if (!mounted) return;
      if (error != null) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
        return;
      }

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Jadwal gagal disimpan: $error')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      toolbarHeight: 64,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.textPrimary,
          size: 28,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        _isEditing ? 'Ubah Jadwal' : 'Tambah Jadwal',
        style: AppTextStyle.headingSmall.copyWith(fontSize: 20),
      ),
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PeriodeBanner(
                      tahunAjaran: widget.tahunAjaran,
                      semesterLabel: widget.semester.label,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                        boxShadow: _fieldShadow,
                      ),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        activeThumbColor: AppColors.white,
                        activeTrackColor: AppColors.primary,
                        inactiveThumbColor: AppColors.textSecondary,
                        inactiveTrackColor: AppColors.border,
                        title: Text(
                          'Jadwal untuk kelas tertentu',
                          style: AppTextStyle.bodyLarge.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Kelas boleh dikosongkan',
                          style: AppTextStyle.bodyMedium.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        value: _hasClass,
                        onChanged: (value) => setState(() => _hasClass = value),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_hasClass) ...[
                      const _FieldLabel('Kelas'),
                      _DropdownField<String>(
                        hint: 'Pilih kelas',
                        value: _kelas,
                        items: _daftarKelas,
                        label: (item) => item,
                        onChanged: (value) => setState(() {
                          _kelas = value;
                          // Sinkronkan ruang otomatis saat kelas diganti, selama belum
                          // diubah ke ruang non-kelas secara manual.
                          if (value != null &&
                              (_ruang == null ||
                                  _ruang!.startsWith('Ruang Kelas '))) {
                            _ruang = 'Ruang Kelas $value';
                          }
                        }),
                        validator: (value) =>
                            value == null ? 'Pilih kelas' : null,
                      ),
                      const SizedBox(height: 18),
                    ],
                    const _FieldLabel('Hari'),
                    _DropdownField<HariSekolah>(
                      hint: 'Pilih hari',
                      value: _hari,
                      items: HariSekolah.values,
                      label: (hari) => hari.label,
                      onChanged: (value) => setState(() => _hari = value!),
                      validator: (_) => null,
                    ),
                    const SizedBox(height: 18),
                    const _FieldLabel('Waktu Pelajaran'),
                    Row(
                      children: [
                        Expanded(
                          child: _TimeField(
                            label: 'Mulai',
                            menit: _mulaiMenit,
                            onTap: () => _pilihWaktu(waktuMulai: true),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '—',
                            style: AppTextStyle.bodyLarge.copyWith(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _TimeField(
                            label: 'Selesai',
                            menit: _selesaiMenit,
                            onTap: () => _pilihWaktu(waktuMulai: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _FieldLabel('Mata Pelajaran'),
                    _DropdownField<String>(
                      hint: 'Pilih mata pelajaran',
                      value: _mapel,
                      items: {...JadwalService.daftarMapel, ?_mapel}.toList(),
                      label: (item) => item,
                      onChanged: (value) => setState(() => _mapel = value),
                      validator: (value) =>
                          value == null ? 'Pilih mata pelajaran' : null,
                    ),
                    const SizedBox(height: 18),
                    const _FieldLabel('Guru'),
                    _DropdownField<String>(
                      hint: 'Pilih guru',
                      value: _guru,
                      items: {...JadwalService.daftarGuru, ?_guru}.toList(),
                      label: (item) => item,
                      onChanged: (value) => setState(() => _guru = value),
                      validator: (value) => value == null ? 'Pilih guru' : null,
                    ),
                    const SizedBox(height: 18),
                    const _FieldLabel('Ruang (opsional)'),
                    _DropdownField<String>(
                      hint: 'Pilih ruang (opsional)',
                      value: _ruang,
                      items: _daftarRuang,
                      label: (item) => item,
                      onChanged: (value) => setState(() => _ruang = value),
                      validator: (_) => null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Jam pelajaran dapat disesuaikan untuk jadwal Senin–Kamis dan Jumat–Sabtu.',
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Simpan Perubahan' : 'Simpan Jadwal',
                        style: AppTextStyle.button.copyWith(fontSize: 16),
                      ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

const _fieldShadow = [
  BoxShadow(
    color: AppColors.shadow,
    blurRadius: 6,
    offset: Offset(0, 1),
  ),
];

class _PeriodeBanner extends StatelessWidget {
  final String tahunAjaran;
  final String semesterLabel;

  const _PeriodeBanner({
    required this.tahunAjaran,
    required this.semesterLabel,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.primaryLight.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          size: 16,
          color: AppColors.primaryDark,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Periode · $tahunAjaran · Semester $semesterLabel',
            style: AppTextStyle.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: AppTextStyle.label.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
  );
}

class _DropdownField<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) label;
  final ValueChanged<T?> onChanged;
  final String? Function(T?) validator;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: _fieldShadow,
    ),
    child: DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      onChanged: onChanged,
      validator: validator,
      borderRadius: BorderRadius.circular(12),
      dropdownColor: AppColors.white,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        size: 24,
        color: AppColors.textPrimary,
      ),
      style: AppTextStyle.bodyLarge.copyWith(
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      hint: Text(
        hint,
        style: AppTextStyle.hint.copyWith(fontSize: 15),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        errorStyle: AppTextStyle.bodySmall.copyWith(
          fontSize: 12,
          color: AppColors.error,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                label(item),
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodyLarge.copyWith(fontSize: 15),
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _TimeField extends StatelessWidget {
  final String label;
  final int menit;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.menit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
      boxShadow: _fieldShadow,
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatMenit(menit),
                      style: AppTextStyle.bodyLarge.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.access_time_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
