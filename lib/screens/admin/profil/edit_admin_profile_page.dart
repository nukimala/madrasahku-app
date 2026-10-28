import 'package:flutter/material.dart';

import '../../../models/admin_profile_model.dart';
import '../../../services/auth_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class EditAdminProfilePage extends StatefulWidget {
  final AdminProfile profile;

  const EditAdminProfilePage({super.key, required this.profile});

  @override
  State<EditAdminProfilePage> createState() => _EditAdminProfilePageState();
}

class _EditAdminProfilePageState extends State<EditAdminProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.namaLengkap);
    _emailController = TextEditingController(text: widget.profile.email);
    _usernameController = TextEditingController(text: widget.profile.username);
    _phoneController = TextEditingController(text: widget.profile.nomorTelepon);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updated = AuthService.instance.updateAdminProfile(
      AdminProfile(
        namaLengkap: _nameController.text,
        email: _emailController.text,
        username: _usernameController.text,
        nomorTelepon: _phoneController.text,
      ),
    );
    if (!updated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email atau username sudah digunakan akun lain.'),
        ),
      );
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
                      controller: _nameController,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Nama lengkap wajib diisi'
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
                      label: 'Username',
                      controller: _usernameController,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Username wajib diisi'
                          : null,
                    ),
                    _ProfileField(
                      label: 'No. Telepon',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Nomor telepon wajib diisi'
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
