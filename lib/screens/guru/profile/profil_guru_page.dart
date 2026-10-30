import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';
import '../jadwal/jadwal_guru_page.dart';
import '../materi/materi_guru_page.dart';
import '../tugas/tugas_guru_page.dart';
import '../../auth/login_page.dart';
import 'edit_profil_guru_page.dart';

/// Halaman profil guru yang mengikuti gaya desain Figma dan memakai
/// nama guru dari sesi login aplikasi.
class ProfilGuruPage extends StatefulWidget {
  const ProfilGuruPage({super.key, this.onLogout});

  /// Isi callback ini dengan proses logout aplikasi jika sudah tersedia.
  final VoidCallback? onLogout;

  @override
  State<ProfilGuruPage> createState() => _ProfilGuruPageState();
}

class _ProfilGuruPageState extends State<ProfilGuruPage> {
  static const Color _green = Color(0xFF219653);
  static const Color _darkGreen = Color(0xFF1E7145);
  static const Color _muted = Color(0xFF878787);

  // Hanya nama yang sudah tersedia di AuthService yang diambil otomatis.
  // Data lain ditampilkan sebagai belum diatur agar tidak memakai data palsu.
  String _nip = '';
  String _mataPelajaran = '';
  String _email = '';
  String _waliKelas = '';

  String get _namaGuru =>
      AuthService.instance.currentTeacherName?.trim().isNotEmpty == true
          ? AuthService.instance.currentTeacherName!.trim()
          : 'Guru';

  void _bukaJadwal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JadwalGuruPage()),
    );
  }

  void _bukaMateri() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MateriGuruPage()),
    );
  }

  void _bukaTugas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TugasGuruPage()),
    );
  }

Future<void> _editProfil() async {
  final hasil = await Navigator.push<ProfilGuruData>(
    context,
    MaterialPageRoute(
      builder: (_) => EditProfilGuruPage(
        profile: ProfilGuruData(
          nama: _namaGuru,
          nip: _nip,
          mataPelajaran: _mataPelajaran,
          email: _email,
          waliKelas: _waliKelas,
        ),
      ),
    ),
  );

  if (hasil == null || !mounted) return;

  setState(() {
    _nip = hasil.nip;
    _mataPelajaran = hasil.mataPelajaran;
    _email = hasil.email;
    _waliKelas = hasil.waliKelas;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Profil berhasil diperbarui.')),
  );
}

  Future<void> _ubahPassword() async {
    final passwordLama = TextEditingController();
    final passwordBaru = TextEditingController();
    final konfirmasi = TextEditingController();

    final hasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _EditField(
                controller: passwordLama,
                label: 'Password saat ini',
                obscureText: true,
              ),
              _EditField(
                controller: passwordBaru,
                label: 'Password baru',
                obscureText: true,
              ),
              _EditField(
                controller: konfirmasi,
                label: 'Konfirmasi password baru',
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _green),
            onPressed: () {
              if (passwordLama.text.isEmpty ||
                  passwordBaru.text.isEmpty ||
                  konfirmasi.text.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Semua kolom wajib diisi.')),
                );
                return;
              }
              if (passwordBaru.text.length < 8) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Password baru minimal 8 karakter.'),
                  ),
                );
                return;
              }
              if (passwordBaru.text != konfirmasi.text) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Konfirmasi password tidak sama.'),
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    passwordLama.dispose();
    passwordBaru.dispose();
    konfirmasi.dispose();

    if (hasil == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Validasi formulir berhasil. Hubungkan ke AuthService/backend '
            'untuk benar-benar mengganti password.',
          ),
        ),
      );
    }
  }

  Future<void> _keluar() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Anda akan kembali ke halaman login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _green,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (yakin != true || !mounted) return;

    // Akhiri sesi akun
    AuthService.instance.logout();

    // Kembali ke halaman login dan hapus riwayat navigasi
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Profil',
          style: AppTextStyle.headingSmall.copyWith(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIdentityCard(),
              const SizedBox(height: 24),
              const Text(
                'Data Mengajar',
                style: TextStyle(
                  color: _darkGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              _InfoCard(
                rows: [
                  _InfoRow(label: 'NIP', value: _nip),
                  _InfoRow(label: 'Mapel diampu', value: _mataPelajaran),
                  _InfoRow(label: 'Email', value: _email),
                  _InfoRow(label: 'Wali kelas', value: _waliKelas),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Pengaturan',
                style: TextStyle(
                  color: _muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _SettingTile(
                icon: Icons.calendar_month_outlined,
                title: 'Jadwal mengajar',
                onTap: _bukaJadwal,
              ),
              _SettingTile(
                icon: Icons.lock_outline,
                title: 'Ubah password',
                onTap: _ubahPassword,
              ),
              _SettingTile(
                icon: Icons.logout_rounded,
                title: 'Keluar',
                titleColor: Colors.red.shade700,
                onTap: _keluar,
                showDivider: false,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _editProfil,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Edit Profil',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 43,
            backgroundColor: const Color(0xFFE5E7EB),
            child: const Icon(
              Icons.person_rounded,
              size: 48,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _namaGuru,
            textAlign: TextAlign.center,
            style: AppTextStyle.headingSmall.copyWith(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _waliKelas.isEmpty
                ? 'Guru'
                : 'Guru · Wali kelas $_waliKelas',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _darkGreen,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: _green,
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            _bukaMateri();
          } else if (index == 2) {
            _bukaTugas();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Materi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 112,
                    child: Text(
                      rows[i].label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(': ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Text(
                      rows[i].value.isEmpty ? 'Belum diatur' : rows[i].value,
                      style: TextStyle(
                        color: rows[i].value.isEmpty
                            ? const Color(0xFF9CA3AF)
                            : Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i != rows.length - 1)
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
          ],
        ],
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleColor = const Color(0x99000000),
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color titleColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          dense: true,
          leading: Icon(icon, size: 19, color: titleColor),
          title: Text(
            title,
            style: TextStyle(fontSize: 13, color: titleColor),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF9CA3AF),
            size: 20,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          const Divider(height: 1, indent: 4, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
