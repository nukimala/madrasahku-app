import 'package:flutter/material.dart';

import '../../../models/mapel_model.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class TambahMapelPage extends StatefulWidget {
  final MapelItem? mapel;

  const TambahMapelPage({super.key, this.mapel});

  @override
  State<TambahMapelPage> createState() => _TambahMapelPageState();
}

class _TambahMapelPageState extends State<TambahMapelPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _kodeController;
  late final TextEditingController _deskripsiController;
  late String? _selectedKelompok;

  static const _kelompokList = [kelompokPai, kelompokUmum];

  @override
  void initState() {
    super.initState();
    final mapel = widget.mapel;
    _namaController = TextEditingController(text: mapel?.nama);
    _kodeController = TextEditingController(text: mapel?.kode);
    _deskripsiController = TextEditingController(text: mapel?.deskripsi);
    _selectedKelompok = mapel?.kelompok;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kodeController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final previous = widget.mapel;
    Navigator.pop(
      context,
      MapelItem(
        nama: _namaController.text.trim(),
        kode: _kodeController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        kelompok: _selectedKelompok!,
        aktif: previous?.aktif ?? true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.mapel != null;

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
          isEditing ? 'Ubah Mata Pelajaran' : 'Tambah Mata Pelajaran',
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
                      const _FieldLabel('Nama Mata Pelajaran'),
                      _TextInput(
                        controller: _namaController,
                        hint: 'Masukkan nama mata pelajaran',
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Nama mata pelajaran wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      const _FieldLabel('Kelompok Mata Pelajaran'),
                      _DropdownInput(
                        hint: 'Pilih kelompok mata pelajaran',
                        value: _selectedKelompok,
                        items: _kelompokList,
                        onChanged: (value) =>
                            setState(() => _selectedKelompok = value),
                        validator: (value) => value == null
                            ? 'Pilih kelompok mata pelajaran'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      const _FieldLabel('Kode Mapel'),
                      _TextInput(
                        controller: _kodeController,
                        hint: 'Contoh: MTK',
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Kode mapel wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      const _FieldLabel('Deskripsi'),
                      _TextInput(
                        controller: _deskripsiController,
                        hint: 'Opsional',
                        maxLines: 5,
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
                    isEditing ? 'Simpan Perubahan' : '+ Tambah Mata Pelajaran',
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
  final String? Function(String?)? validator;
  final int maxLines;

  const _TextInput({
    required this.controller,
    required this.hint,
    this.validator,
    this.maxLines = 1,
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
      maxLines: maxLines,
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
