import 'package:flutter/material.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

// =====================================================
// HALAMAN EDIT PROFIL GURU
// =====================================================

class EditProfilGuruPage extends StatefulWidget {
  final ProfilGuruData profile;

  const EditProfilGuruPage({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfilGuruPage> createState() =>
      _EditProfilGuruPageState();
}

class _EditProfilGuruPageState
    extends State<EditProfilGuruPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _namaController;
  late final TextEditingController _emailController;
  late final TextEditingController _alamatController;

  @override
  void initState() {
    super.initState();

    _namaController = TextEditingController(
      text: widget.profile.nama,
    );

    _emailController = TextEditingController(
      text: widget.profile.email,
    );

    _alamatController = TextEditingController(
      text: widget.profile.alamat,
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _alamatController.dispose();

    super.dispose();
  }

  // =====================================================
  // VALIDASI
  // =====================================================

  String? _validateNama(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }

    if (!RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  String? _validateAlamat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alamat wajib diisi';
    }
    return null;
  }

  // =====================================================
  // SIMPAN PERUBAHAN
  // =====================================================

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updated = ProfilGuruData(
      nama: _namaController.text.trim(),
      nip: widget.profile.nip,
      mataPelajaran: widget.profile.mataPelajaran,
      email: _emailController.text.trim(),
      waliKelas: widget.profile.waliKelas,
      alamat: _alamatController.text.trim(),
    );

    Navigator.pop(context, updated);
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            // =========================================
            // FORM CONTENT
            // =========================================

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  28, 14, 28, 16,
                ),

                child: Form(
                  key: _formKey,

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // =================================
                      // HEADER
                      // =================================

                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },

                            borderRadius:
                                BorderRadius.circular(20),

                            child: const Padding(
                              padding: EdgeInsets.all(2),

                              child: Icon(
                                Icons.arrow_back,
                                size: 20,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Text(
                            'Edit Profil',
                            style: AppTextStyle.headingSmall,
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // =================================
                      // AVATAR
                      // =================================

                      Center(
                        child: Container(
                          width: 87,
                          height: 87,

                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.person,
                            size: 44,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // =================================
                      // NAMA LENGKAP
                      // =================================

                      _ProfileField(
                        label: 'Nama Lengkap',
                        controller: _namaController,
                        validator: _validateNama,
                      ),

                      // =================================
                      // EMAIL
                      // =================================

                      _ProfileField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),

                      // =================================
                      // ALAMAT
                      // =================================

                      _ProfileField(
                        label: 'Alamat',
                        controller: _alamatController,
                        maxLines: 2,
                        validator: _validateAlamat,
                      ),

                      // =================================
                      // KETERANGAN
                      // =================================

                      Text(
                        'NIP, mata pelajaran, dan wali kelas '
                        'hanya dapat diubah oleh admin.',
                        style: AppTextStyle.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // =========================================
            // TOMBOL SIMPAN — style seragam dengan
            // tombol "Edit Profil" di ProfilGuruPage
            // =========================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                50, 0, 50, 20,
              ),

              child: SizedBox(
                width: double.infinity,
                height: 46,

                child: ElevatedButton(
                  onPressed: _save,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 3,
                    shadowColor: AppColors.shadow,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  child: Text(
                    'Simpan Perubahan',
                    style: AppTextStyle.button,
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

// =====================================================
// WIDGET FIELD FORM
// =====================================================

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?) validator;

  const _ProfileField({
    required this.label,
    required this.controller,
    required this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            label,

            style: AppTextStyle.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryDark,
            ),
          ),

          const SizedBox(height: 6),

          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,

            style: AppTextStyle.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),

            cursorColor: AppColors.primary,

            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.inputBackground,

              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.4,
                ),
              ),

              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.error,
                ),
              ),

              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.4,
                ),
              ),

              errorStyle: AppTextStyle.bodySmall.copyWith(
                fontSize: 10,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// MODEL DATA PROFIL GURU
// =====================================================

class ProfilGuruData {
  const ProfilGuruData({
    required this.nama,
    required this.nip,
    required this.mataPelajaran,
    required this.email,
    required this.waliKelas,
    this.alamat = '',
  });

  final String nama;
  final String nip;
  final String mataPelajaran;
  final String email;
  final String waliKelas;
  final String alamat;
}