import 'package:flutter/material.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class EditProfilSiswaPage extends StatefulWidget {
  final String? initialNama;
  final String? initialNisn;
  final String? initialEmail;
  final String? initialAlamat;
  final String? initialKelas;
  final String? initialWaliKelas;

  const EditProfilSiswaPage({
    super.key,
    this.initialNama,
    this.initialNisn,
    this.initialEmail,
    this.initialAlamat,
    this.initialKelas,
    this.initialWaliKelas,
  });

  @override
  State<EditProfilSiswaPage> createState() => _EditProfilSiswaPageState();
}

class _EditProfilSiswaPageState extends State<EditProfilSiswaPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaCtrl;
  late TextEditingController _nisnCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _alamatCtrl;
  late TextEditingController _kelasCtrl;
  late TextEditingController _waliKelasCtrl;

  static const Color _green = Color(0xFF219653);

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(
      text: widget.initialNama ?? 'Ahmad Fauzi',
    );
    _nisnCtrl = TextEditingController(text: widget.initialNisn ?? '0051234567');
    _emailCtrl = TextEditingController(text: widget.initialEmail ?? 'ahmad.f@siswa.sch');
    _alamatCtrl = TextEditingController(text: widget.initialAlamat ?? 'Kedungwaru, Tulungagung');
    _kelasCtrl = TextEditingController(text: widget.initialKelas ?? 'VII A');
    _waliKelasCtrl = TextEditingController(text: widget.initialWaliKelas ?? 'Bu Siti Nurhazia');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nisnCtrl.dispose();
    _emailCtrl.dispose();
    _alamatCtrl.dispose();
    _kelasCtrl.dispose();
    _waliKelasCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil siswa berhasil diperbarui!'),
        backgroundColor: _green,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context, {
      'nama': _namaCtrl.text.trim(),
      'nisn': _nisnCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'alamat': _alamatCtrl.text.trim(),
      'kelas': _kelasCtrl.text.trim(),
      'waliKelas': _waliKelasCtrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profil Siswa',
          style: AppTextStyle.headingSmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar dengan overlay tombol kamera
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D5DB),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 58,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur ubah foto profil akan segera hadir'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: _green,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Akun',
                        style: AppTextStyle.headingSmall.copyWith(
                          fontSize: 15,
                          color: _green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _namaCtrl,
                        label: 'Nama Lengkap',
                        icon: Icons.person_outline,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _nisnCtrl,
                        label: 'NISN',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _kelasCtrl,
                        label: 'Kelas',
                        icon: Icons.school_outlined,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _emailCtrl,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _waliKelasCtrl,
                        label: 'Wali Kelas',
                        icon: Icons.supervisor_account_outlined,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _alamatCtrl,
                        label: 'Alamat Tempat Tinggal',
                        icon: Icons.home_outlined,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _simpan,
                    child: const Text(
                      'Simpan Perubahan',
                      style: TextStyle(
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _green, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
