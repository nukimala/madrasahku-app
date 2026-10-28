import 'package:flutter/material.dart';

import '../../../models/jadwal_model.dart';
import '../../../services/jadwal_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class TambahJadwalPage extends StatefulWidget {
  final String tahunAjaran;
  final Semester semester;
  final String kelas;
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
  String? _mapel;
  String? _guru;
  String? _ruang;

  bool get _isEditing => widget.jadwal != null;

  @override
  void initState() {
    super.initState();
    final jadwal = widget.jadwal;
    _hari = jadwal?.hari ?? widget.hari;
    _mulaiMenit = jadwal?.mulaiMenit ?? 7 * 60;
    _selesaiMenit = jadwal?.selesaiMenit ?? 7 * 60 + 40;
    _mapel = jadwal?.mataPelajaran;
    _guru = jadwal?.guru;
    _ruang = jadwal?.ruang;
  }

  Future<void> _pilihWaktu({required bool waktuMulai}) async {
    final menitSaatIni = waktuMulai ? _mulaiMenit : _selesaiMenit;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: menitSaatIni ~/ 60,
        minute: menitSaatIni % 60,
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

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final jadwal = JadwalPelajaran(
      id: widget.jadwal?.id ?? 0,
      tahunAjaran: widget.tahunAjaran,
      semester: widget.semester,
      kelas: widget.kelas,
      hari: _hari,
      mulaiMenit: _mulaiMenit,
      selesaiMenit: _selesaiMenit,
      mataPelajaran: _mapel!,
      guru: _guru!,
      ruang: _ruang!,
    );
    final error = JadwalService.instance.simpan(
      jadwal,
      kecualiId: widget.jadwal?.id,
    );
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.pop(context, true);
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
                    _FieldLabel('Kelas · ${widget.kelas}'),
                    _ReadOnlyValue(widget.kelas),
                    const SizedBox(height: 18),
                    _FieldLabel(
                      'Periode · ${widget.tahunAjaran} · Semester ${widget.semester.label}',
                    ),
                    const SizedBox(height: 18),
                    const _FieldLabel('Hari'),
                    _DropdownField<HariSekolah>(
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
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('—'),
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
                      value: _mapel,
                      items: JadwalService.daftarMapel,
                      label: (item) => item,
                      onChanged: (value) => setState(() => _mapel = value),
                      validator: (value) =>
                          value == null ? 'Pilih mata pelajaran' : null,
                    ),
                    const SizedBox(height: 18),
                    const _FieldLabel('Guru'),
                    _DropdownField<String>(
                      value: _guru,
                      items: JadwalService.daftarGuru,
                      label: (item) => item,
                      onChanged: (value) => setState(() => _guru = value),
                      validator: (value) => value == null ? 'Pilih guru' : null,
                    ),
                    const SizedBox(height: 18),
                    const _FieldLabel('Ruang (wajib)'),
                    _DropdownField<String>(
                      value: _ruang,
                      items: JadwalService.daftarRuang,
                      label: (item) => item,
                      onChanged: (value) => setState(() => _ruang = value),
                      validator: (value) =>
                          value == null ? 'Pilih ruang' : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Jam pelajaran dapat disesuaikan untuk jadwal Senin–Kamis dan Jumat–Sabtu.',
                      style: AppTextStyle.bodySmall.copyWith(fontSize: 12),
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
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
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

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: AppTextStyle.label.copyWith(fontWeight: FontWeight.w600),
    ),
  );
}

class _ReadOnlyValue extends StatelessWidget {
  final String value;

  const _ReadOnlyValue(this.value);

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(value, style: AppTextStyle.bodyLarge),
  );
}

class _DropdownField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) label;
  final ValueChanged<T?> onChanged;
  final String? Function(T?) validator;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    initialValue: value,
    isExpanded: true,
    onChanged: onChanged,
    validator: validator,
    decoration: InputDecoration(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    items: items
        .map(
          (item) => DropdownMenuItem<T>(
            value: item,
            child: Text(label(item), overflow: TextOverflow.ellipsis),
          ),
        )
        .toList(),
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
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      child: Text(formatMenit(menit), style: AppTextStyle.bodyLarge),
    ),
  );
}
