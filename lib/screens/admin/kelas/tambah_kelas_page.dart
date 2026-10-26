import 'package:flutter/material.dart';

import '../../../models/kelas_model.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class TambahKelasPage extends StatefulWidget {
  final KelasItem? kelas;

  const TambahKelasPage({super.key, this.kelas});

  @override
  State<TambahKelasPage> createState() => _TambahKelasPageState();
}

class _TambahKelasPageState extends State<TambahKelasPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _tahunController;
  late String? _selectedTingkat;
  late String? _selectedWali;

  static const _tingkatList = ['VII', 'VIII', 'IX'];
  static const _waliKelasList = [
    'Ahmad Fauzi',
    'Siti Nurhaliza',
    'Budi Santoso',
    'Nur Aini',
    'Rizky Maulana',
  ];

  @override
  void initState() {
    super.initState();
    final kelas = widget.kelas;
    _namaController = TextEditingController(text: kelas?.nama);
    _tahunController = TextEditingController(
      text: kelas?.tahunAjaran ?? '2026/2027',
    );
    _selectedTingkat = kelas?.tingkat;
    _selectedWali = kelas?.waliKelas;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tahunController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final previous = widget.kelas;
    Navigator.pop(
      context,
      KelasItem(
        nama: _namaController.text.trim(),
        tingkat: _selectedTingkat!,
        waliKelas: _selectedWali!,
        tahunAjaran: _tahunController.text.trim(),
        jumlahSiswa: previous?.jumlahSiswa ?? 0,
        aktif: previous?.aktif ?? true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.kelas != null;

    return Scaffold(
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
          isEditing ? 'Ubah Data Kelas' : 'Tambah Data Kelas',
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
                      const _FieldLabel('Nama Kelas'),
                      _TextInput(
                        controller: _namaController,
                        hint: 'Contoh: VII A',
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Nama kelas wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      const _FieldLabel('Tingkat'),
                      _DropdownInput(
                        hint: 'Pilih Tingkat',
                        value: _selectedTingkat,
                        items: _tingkatList,
                        onChanged: (value) =>
                            setState(() => _selectedTingkat = value),
                        validator: (value) =>
                            value == null ? 'Pilih tingkat kelas' : null,
                      ),
                      const SizedBox(height: 20),
                      const _FieldLabel('Wali Kelas'),
                      _DropdownInput(
                        hint: 'Pilih Wali Kelas',
                        value: _selectedWali,
                        items: _waliKelasList,
                        onChanged: (value) =>
                            setState(() => _selectedWali = value),
                        validator: (value) =>
                            value == null ? 'Pilih wali kelas' : null,
                      ),
                      const SizedBox(height: 20),
                      const _FieldLabel('Tahun Ajaran'),
                      _TextInput(
                        controller: _tahunController,
                        hint: 'Contoh: 2026/2027',
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Tahun ajaran wajib diisi'
                            : null,
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
                    isEditing ? 'Simpan Perubahan' : '+ Tambah Data Kelas',
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

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?) validator;

  const _TextInput({
    required this.controller,
    required this.hint,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 6,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      validator: validator,
      style: AppTextStyle.bodyLarge.copyWith(fontSize: 16),
      decoration: _inputDecoration(hint),
    ),
  );
}

class _DropdownInput extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?) validator;

  const _DropdownInput({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 6,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      validator: validator,
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(
        Icons.keyboard_arrow_down,
        size: 28,
        color: AppColors.textPrimary,
      ),
      decoration: _inputDecoration(hint),
      style: AppTextStyle.bodyLarge.copyWith(fontSize: 16),
      dropdownColor: AppColors.white,
      hint: Text(hint, style: AppTextStyle.hint.copyWith(fontSize: 15)),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    ),
  );
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: AppTextStyle.hint.copyWith(fontSize: 15),
  filled: true,
  fillColor: AppColors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.error),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.error, width: 1.2),
  ),
);
