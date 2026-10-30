import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

/// Halaman edit profil guru dengan gaya yang konsisten dengan
/// [EditAdminProfilePage].
///
/// Hasil edit dikembalikan lewat [Navigator.pop] berupa [ProfilGuruData].
class EditProfilGuruPage extends StatefulWidget {
  final ProfilGuruData profile;

  const EditProfilGuruPage({super.key, required this.profile});

  @override
  State<EditProfilGuruPage> createState() => _EditProfilGuruPageState();
}

class _EditProfilGuruPageState extends State<EditProfilGuruPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _nipController;
  late final TextEditingController _mapelController;
  late final TextEditingController _emailController;
  late final TextEditingController _waliController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.profile.nama);
    _nipController = TextEditingController(text: widget.profile.nip);
    _mapelController =
        TextEditingController(text: widget.profile.mataPelajaran);
    _emailController = TextEditingController(text: widget.profile.email);
    _waliController = TextEditingController(text: widget.profile.waliKelas);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nipController.dispose();
    _mapelController.dispose();
    _emailController.dispose();
    _waliController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updated = ProfilGuruData(
      nama: _namaController.text.trim(),
      nip: _nipController.text.trim(),
      mataPelajaran: _mapelController.text.trim(),
      email: _emailController.text.trim(),
      waliKelas: _waliController.text.trim(),
    );

    Navigator.pop(context, updated);
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
        'Edit Profil',
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
                    _ProfileField(
                      label: 'Nama Lengkap',
                      controller: _namaController,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Nama lengkap wajib diisi'
                          : null,
                    ),
                    _ProfileField(
                      label: 'NIP',
                      controller: _nipController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'NIP wajib diisi';
                        if (!RegExp(r'^\d+$').hasMatch(v)) {
                          return 'NIP hanya boleh berisi angka';
                        }
                        if (v.length < 8) {
                          return 'NIP minimal 8 digit';
                        }
                        return null;
                      },
                    ),
                    _ProfileField(
                      label: 'Mata Pelajaran Diampu',
                      controller: _mapelController,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Mata pelajaran wajib diisi'
                          : null,
                    ),
                    _ProfileField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email wajib diisi';
                        }
                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(value.trim())) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    _ProfileField(
                      label: 'Wali Kelas',
                      controller: _waliController,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Wali kelas wajib diisi'
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
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Simpan Perubahan',
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

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;

  const _ProfileField({
    required this.label,
    required this.controller,
    required this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: AppTextStyle.label.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyle.bodyLarge.copyWith(fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
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
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Model data profil guru yang dipakai untuk mengirim hasil edit.
class ProfilGuruData {
  const ProfilGuruData({
    required this.nama,
    required this.nip,
    required this.mataPelajaran,
    required this.email,
    required this.waliKelas,
  });

  final String nama;
  final String nip;
  final String mataPelajaran;
  final String email;
  final String waliKelas;
}