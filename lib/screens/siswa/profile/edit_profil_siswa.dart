import 'package:flutter/material.dart';

import '../../../utilis/app_text_style.dart';

/// Versi DUMMY tanpa model: data dikirim sebagai teks biasa,
/// hasil edit dikembalikan ke halaman profil lewat Map.
class EditProfilSiswaPage extends StatefulWidget {
  final String nama;
  final String email;
  final String alamat;

  const EditProfilSiswaPage({
    super.key,
    required this.nama,
    required this.email,
    required this.alamat,
  });

  @override
  State<EditProfilSiswaPage> createState() => _EditProfilSiswaPageState();
}

class _EditProfilSiswaPageState extends State<EditProfilSiswaPage> {
  static const Color _green = Color(0xFF219653);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.nama);
    _emailController = TextEditingController(text: widget.email);
    _addressController = TextEditingController(text: widget.alamat);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: simpan ke AuthService / database kalau sudah siap
    Navigator.pop(context, {
      'nama': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'alamat': _addressController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 14, 28, 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(
                                Icons.arrow_back,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Edit Profil',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Avatar
                      Center(
                        child: Container(
                          width: 87,
                          height: 87,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD9D9D9),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      _Field(
                        label: 'Nama Lengkap',
                        controller: _nameController,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Nama lengkap wajib diisi'
                            : null,
                      ),
                      _Field(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email wajib diisi';
                          }
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(v.trim())) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      _Field(
                        label: 'Alamat',
                        controller: _addressController,
                        maxLines: 2,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Alamat wajib diisi'
                            : null,
                      ),
                      Text(
                        'NISN, kelas, dan wali kelas hanya dapat diubah oleh admin.',
                        style: AppTextStyle.bodySmall.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF878787),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tombol simpan
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 20),
              child: Container(
                width: double.infinity,
                height: 46,
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFCDC9C4),
                      blurRadius: 15,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _save,
                    borderRadius: BorderRadius.circular(15),
                    child: const Center(
                      child: Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
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

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?) validator;

  const _Field({
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
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E7145),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF219653)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}