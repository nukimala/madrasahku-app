import 'package:flutter/material.dart';

import '../../../models/siswa_model.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class TambahSiswaPage extends StatefulWidget {
  final SiswaItem? siswa;

  const TambahSiswaPage({super.key, this.siswa});

  @override
  State<TambahSiswaPage> createState() => _TambahSiswaPageState();
}

class _TambahSiswaPageState extends State<TambahSiswaPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _nisController = TextEditingController();
  final _tanggalController = TextEditingController();

  String? _selectedKelas;
  String? _selectedJenisKelamin;

  // Daftar dummy, nanti ambil dari data Kelas
  final List<String> _kelasList = [
    'VII A',
    'VII B',
    'VIII A',
    'VIII B',
    'IX A',
    'IX B',
  ];

  final List<String> _jenisKelaminList = [
    'Laki-laki',
    'Perempuan',
  ];

  bool get _isEditing => widget.siswa != null;

  @override
  void initState() {
    super.initState();
    final siswa = widget.siswa;
    if (siswa != null) {
      _namaController.text = siswa.nama;
      _nisController.text = siswa.nis;
      _tanggalController.text = siswa.tanggalLahir;
      _selectedKelas = siswa.kelas;
      _selectedJenisKelamin = siswa.jenisKelamin;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nisController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final existingDate = _parseDate(_tanggalController.text);
    final picked = await showDatePicker(
      context: context,
      initialDate: existingDate ?? DateTime(2012, 1, 1),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final d = picked.day.toString().padLeft(2, '0');
      final m = picked.month.toString().padLeft(2, '0');
      setState(() => _tanggalController.text = '$d/$m/${picked.year}');
    }
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      SiswaItem(
        nama: _namaController.text.trim(),
        nis: _nisController.text.trim(),
        kelas: _selectedKelas!,
        jenisKelamin: _selectedJenisKelamin!,
        tanggalLahir: _tanggalController.text.trim(),
        aktif: widget.siswa?.aktif ?? true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppColors.textPrimary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Data Siswa' : 'Tambah Data Siswa',
          style: AppTextStyle.headingSmall.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Nama Lengkap'),
                      _AppTextField(
                        controller: _namaController,
                        hint: 'Masukkan nama siswa',
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      const _FieldLabel('NIS'),
                      _AppTextField(
                        controller: _nisController,
                        hint: 'Masukkan NIS',
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'NIS wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      const _FieldLabel('Kelas'),
                      _AppDropdown(
                        hint: 'Pilih Kelas',
                        value: _selectedKelas,
                        items: _kelasList,
                        onChanged: (v) => setState(() => _selectedKelas = v),
                        validator: (v) => v == null ? 'Pilih kelas' : null,
                      ),
                      const SizedBox(height: 20),

                      const _FieldLabel('Jenis Kelamin'),
                      _AppDropdown(
                        hint: 'Pilih Jenis Kelamin',
                        value: _selectedJenisKelamin,
                        items: _jenisKelaminList,
                        onChanged: (v) =>
                            setState(() => _selectedJenisKelamin = v),
                        validator: (v) =>
                            v == null ? 'Pilih jenis kelamin' : null,
                      ),
                      const SizedBox(height: 20),

                      const _FieldLabel('Tanggal Lahir'),
                      _AppTextField(
                        controller: _tanggalController,
                        hint: 'Pilih Tanggal',
                        readOnly: true,
                        onTap: _pickDate,
                        suffixIcon: const Icon(
                          Icons.calendar_month_outlined,
                          size: 24,
                          color: AppColors.textPrimary,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Tanggal lahir wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      const _FieldLabel('Foto'),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // TODO: pakai image_picker untuk memilih foto
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pilih foto belum tersedia'),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1EDED),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 6,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Pilih Foto',
                            style: AppTextStyle.bodySmall.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tombol bawah
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Simpan Perubahan' : '+ Tambah Data Siswa',
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
}

// ---------- Komponen form ----------

const _fieldShadow = [
  BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  ),
];

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyle.label.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyle.hint.copyWith(fontSize: 15),
    isDense: true,
    filled: true,
    fillColor: AppColors.inputBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    errorStyle: const TextStyle(fontSize: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
  );
}

class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  const _AppTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _fieldShadow,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        style: AppTextStyle.bodyLarge.copyWith(fontSize: 16),
        decoration: _inputDecoration(hint).copyWith(suffixIcon: suffixIcon),
      ),
    );
  }
}

class _AppDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const _AppDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _fieldShadow,
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        validator: validator,
        onChanged: onChanged,
        borderRadius: BorderRadius.circular(12),
        icon: const Icon(Icons.keyboard_arrow_down,
            size: 28, color: AppColors.textPrimary),
        decoration: _inputDecoration(hint),
        style: AppTextStyle.bodyLarge.copyWith(fontSize: 16),
        dropdownColor: AppColors.white,
        hint: Text(hint, style: AppTextStyle.hint.copyWith(fontSize: 15)),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
      ),
    );
  }
}