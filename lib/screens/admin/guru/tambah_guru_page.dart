import 'package:flutter/material.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class TambahGuruPage extends StatefulWidget {
  const TambahGuruPage({super.key});

  @override
  State<TambahGuruPage> createState() => _TambahGuruPageState();
}

class _TambahGuruPageState extends State<TambahGuruPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _nipController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();

  String? _selectedMapel;

  // Daftar dummy, nanti ambil dari data Mata Pelajaran
  final List<String> _mapelList = [
    'Matematika',
    'Bahasa Indonesia',
    'Bahasa Inggris',
    'IPA',
    'IPS',
    'PAI',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _nipController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: simpan data ke service/database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data guru berhasil ditambahkan')),
    );
    Navigator.pop(context);
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
          'Tambah Data Guru',
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
                        hint: 'Masukkan nama guru',
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      const _FieldLabel('NIP/NUPTK'),
                      _AppTextField(
                        controller: _nipController,
                        hint: 'Masukkan NIP atau NUPTK',
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'NIP/NUPTK wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      const _FieldLabel('Mata pembelajaran'),
                      _AppDropdown(
                        hint: 'Pilih Mata Pelajaran',
                        value: _selectedMapel,
                        items: _mapelList,
                        onChanged: (v) => setState(() => _selectedMapel = v),
                        validator: (v) =>
                            v == null ? 'Pilih mata pelajaran' : null,
                      ),
                      const SizedBox(height: 20),

                      const _FieldLabel('Email'),
                      _AppTextField(
                        controller: _emailController,
                        hint: 'Masukkan Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email wajib diisi';
                          }
                          if (!v.contains('@')) return 'Email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      const _FieldLabel('No. Telepon'),
                      _AppTextField(
                        controller: _teleponController,
                        hint: 'Masukkan Nomer Telepon',
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'No. telepon wajib diisi'
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
                    '+ Tambah Data Guru',
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

  const _AppTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
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
        style: AppTextStyle.bodyLarge.copyWith(fontSize: 16),
        decoration: _inputDecoration(hint),
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