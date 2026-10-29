import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';
import '../../auth/login_page.dart';
import '../Materi/materi_page.dart';
import '../tugas/tugas_page.dart';
import 'edit_profil_siswa.dart';

class ProfilSiswaPage extends StatefulWidget {
  const ProfilSiswaPage({super.key});

  @override
  State<ProfilSiswaPage> createState() => _ProfilSiswaPageState();
}

class _ProfilSiswaPageState extends State<ProfilSiswaPage> {
  static const Color _green = Color(0xFF219653);
  static const Color _greenDark = Color(0xFF1E7145);

  AuthService get _authService => AuthService.instance;

  // Data dummy (nanti bisa diganti dari AuthService / database)
  String _nama = 'Ahmad Fauzi';
  final String _nisn = '0051234567';
  String _email = 'ahmad.f@siswa.sch';
  final String _kelas = 'VIII A';
  String _alamat = 'Kedungwaru, Tulungagung';
  final String _waliKelas = 'Bu Siti Nurhazia';

  // Membuka halaman edit, lalu update tampilan kalau ada perubahan
  Future<void> _editProfile() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilSiswaPage(
          nama: _nama,
          email: _email,
          alamat: _alamat,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _nama = result['nama'] ?? _nama;
        _email = result['email'] ?? _email;
        _alamat = result['alamat'] ?? _alamat;
      });
    }
  }

  void _showComingSoon(String menu) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$menu akan kita buat berikutnya, ya!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _changePassword() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var obscurePasswords = true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Ubah Password', style: AppTextStyle.headingSmall),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PasswordField(
                    controller: currentPasswordController,
                    label: 'Password saat ini',
                    obscureText: obscurePasswords,
                    onToggleVisibility: () => setDialogState(
                      () => obscurePasswords = !obscurePasswords,
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Password saat ini wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _PasswordField(
                    controller: newPasswordController,
                    label: 'Password baru',
                    obscureText: obscurePasswords,
                    onToggleVisibility: () => setDialogState(
                      () => obscurePasswords = !obscurePasswords,
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _PasswordField(
                    controller: confirmPasswordController,
                    label: 'Konfirmasi password baru',
                    obscureText: obscurePasswords,
                    onToggleVisibility: () => setDialogState(
                      () => obscurePasswords = !obscurePasswords,
                    ),
                    validator: (value) => value != newPasswordController.text
                        ? 'Konfirmasi password tidak sama'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                // TODO: ganti dengan AuthService.changeSiswaPassword(...)
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diubah (dummy).')),
      );
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Keluar dari akun?', style: AppTextStyle.headingSmall),
        content: Text(
          'Kamu perlu masuk kembali untuk mengakses beranda siswa.',
          style: AppTextStyle.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (shouldLogout != true || !mounted) return;

    _authService.logout();
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 14, 28, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.maybePop(context),
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
                        Text(
                          'Profil',
                          style: _poppins(15, FontWeight.w600, Colors.black),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    // Kartu profil
                    _buildProfileCard(_nama, _kelas),

                    const SizedBox(height: 26),

                    // Data pribadi
                    const _SectionTitle(
                      title: 'Data Pribadi',
                      color: _greenDark,
                      lineColor: Color(0x331E7145),
                    ),
                    _InfoRow(label: 'NISN', value: _nisn),
                    _InfoRow(label: 'Email', value: _email),
                    _InfoRow(label: 'Alamat', value: _alamat),
                    _InfoRow(label: 'Wali kelas', value: _waliKelas),

                    const SizedBox(height: 36),

                    // Pengaturan
                    const _SectionTitle(
                      title: 'Pengaturan',
                      color: Color(0xFF878787),
                      lineColor: Color(0x33878787),
                    ),
                    _SettingItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Jadwal Pelajaran',
                      onTap: () => _showComingSoon('Jadwal Pelajaran'),
                    ),
                    _SettingItem(
                      icon: Icons.lock_outline,
                      label: 'ubah password',
                      onTap: _changePassword,
                    ),
                    _SettingItem(
                      icon: Icons.logout,
                      label: 'Keluar',
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ),

            // Tombol edit profil
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 16),
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
                    onTap: _editProfile,
                    borderRadius: BorderRadius.circular(15),
                    child: Center(
                      child: Text(
                        'Edit Profil',
                        style: _inter(13, FontWeight.w600, Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: _green,
        unselectedItemColor: const Color(0xFFD1D5DB),
        selectedFontSize: 10,
        unselectedFontSize: 10,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MateriPage()),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const TugasPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined, size: 28),
            label: 'Materi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_rounded, size: 28),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 28),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String nama, String kelas) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFCDC9C5),
            blurRadius: 15,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 87,
            height: 87,
            decoration: const BoxDecoration(
              color: Color(0xFFD9D9D9),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            nama,
            textAlign: TextAlign.center,
            style: _poppins(15, FontWeight.w600, Colors.black),
          ),
          Text(
            'Siswa Kelas $kelas',
            textAlign: TextAlign.center,
            style: _poppins(12, FontWeight.w500, _greenDark),
          ),
        ],
      ),
    );
  }
}

// Gaya teks dari Figma
TextStyle _poppins(double size, FontWeight weight, Color color) => TextStyle(
  fontFamily: 'Poppins',
  fontSize: size,
  fontWeight: weight,
  color: color,
);

TextStyle _inter(double size, FontWeight weight, Color color) => TextStyle(
  fontFamily: 'Inter',
  fontSize: size,
  fontWeight: weight,
  color: color,
);

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  final Color lineColor;

  const _SectionTitle({
    required this.title,
    required this.color,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(3, 0, 0, 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: lineColor, width: 1)),
      ),
      child: Text(title, style: _inter(13, FontWeight.w500, color)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(2, 7, 0, 7),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _inter(13, FontWeight.w500, Colors.black)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: _inter(13, FontWeight.w500, Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.black.withValues(alpha: 0.60);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(4, 6, 0, 6),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.8),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 12),
            Text(label, style: _poppins(13, FontWeight.w400, color)),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?) validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: obscureText,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: IconButton(
        onPressed: onToggleVisibility,
        icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}