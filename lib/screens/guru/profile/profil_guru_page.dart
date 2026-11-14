import 'package:flutter/material.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';
import '../../../services/auth_service.dart';
import '../../auth/login_page.dart';
import '../jadwal/jadwal_guru_page.dart';
import 'edit_profil_guru_page.dart';

// =====================================================
// HALAMAN PROFIL GURU
// =====================================================

class ProfilGuruPage extends StatefulWidget {
  const ProfilGuruPage({
    super.key,
    this.onLogout,
  });

  final VoidCallback? onLogout;

  @override
  State<ProfilGuruPage> createState() => _ProfilGuruPageState();
}

class _ProfilGuruPageState extends State<ProfilGuruPage> {
  // =====================================================
  // DATA PROFIL
  // =====================================================

  String _nama = '';
  String _nip = '';
  String _mataPelajaran = '';
  String _email = '';
  String _alamat = '';
  String _waliKelas = '';

  @override
  void initState() {
    super.initState();
    final auth = AuthService.instance;
    _nama = auth.currentTeacherName ?? 'Guru';
    _email = auth.adminProfile.email;
    auth.fetchMe().then((_) {
      if (mounted) {
        setState(() {
          _nama = auth.currentTeacherName ?? 'Guru';
          _email = auth.adminProfile.email;
        });
      }
    });
  }

  String get _namaGuru {
    if (_nama.trim().isNotEmpty) return _nama;

    final nama = AuthService.instance.currentTeacherName?.trim();
    if (nama != null && nama.isNotEmpty) return nama;

    return 'Guru';
  }

  // =====================================================
  // NAVIGASI
  // =====================================================

  void _bukaJadwal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JadwalGuruPage()),
    );
  }

  // =====================================================
  // EDIT PROFIL
  // =====================================================

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
            alamat: _alamat,
          ),
        ),
      ),
    );

    if (!mounted || hasil == null) return;

    setState(() {
      _nama = hasil.nama;
      _nip = hasil.nip;
      _mataPelajaran = hasil.mataPelajaran;
      _email = hasil.email;
      _waliKelas = hasil.waliKelas;
      _alamat = hasil.alamat;
    });

    _snack('Profil berhasil diperbarui.');
  }

  // =====================================================
  // UBAH PASSWORD
  // =====================================================

  Future<void> _ubahPassword() async {
    final passwordLama = TextEditingController();
    final passwordBaru = TextEditingController();
    final konfirmasi = TextEditingController();

    bool obscurePassword = true;

    final hasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Ubah Password',
                style: AppTextStyle.headingSmall,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PasswordField(
                      controller: passwordLama,
                      label: 'Password saat ini',
                      obscureText: obscurePassword,
                      onToggleVisibility: () {
                        setDialogState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _PasswordField(
                      controller: passwordBaru,
                      label: 'Password baru',
                      obscureText: obscurePassword,
                      onToggleVisibility: () {
                        setDialogState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _PasswordField(
                      controller: konfirmasi,
                      label: 'Konfirmasi password baru',
                      obscureText: obscurePassword,
                      onToggleVisibility: () {
                        setDialogState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(
                    'Batal',
                    style: AppTextStyle.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (passwordLama.text.isEmpty ||
                        passwordBaru.text.isEmpty ||
                        konfirmasi.text.isEmpty) {
                      _snack('Semua kolom wajib diisi.', target: dialogContext);
                      return;
                    }

                    if (passwordBaru.text.length < 8) {
                      _snack(
                        'Password baru minimal 8 karakter.',
                        target: dialogContext,
                      );
                      return;
                    }

                    if (passwordBaru.text != konfirmasi.text) {
                      _snack(
                        'Konfirmasi password tidak sama.',
                        target: dialogContext,
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Simpan', style: AppTextStyle.button),
                ),
              ],
            );
          },
        );
      },
    );

    passwordLama.dispose();
    passwordBaru.dispose();
    konfirmasi.dispose();

    if (hasil == true && mounted) {
      _snack(
        'Validasi berhasil. Fitur ini perlu dihubungkan '
        'ke AuthService atau backend untuk mengganti password.',
      );
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> _logout() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Keluar dari akun?',
            style: AppTextStyle.headingSmall,
          ),
          content: Text(
            'Anda akan kembali ke halaman login.',
            style: AppTextStyle.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Batal',
                style: AppTextStyle.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Keluar', style: AppTextStyle.button),
            ),
          ],
        );
      },
    );

    if (yakin != true || !mounted) return;

    if (widget.onLogout != null) {
      widget.onLogout!();
      return;
    }

    AuthService.instance.logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // =====================================================
  // SNACK HELPER
  // =====================================================

  void _snack(String pesan, {BuildContext? target}) {
    final ctx = target ?? context;
    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            pesan,
            style: AppTextStyle.bodyLarge.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  // =====================================================
  // BUILD — padding & spacing disamakan dengan
  // MateriGuruPage / TugasGuruPage
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER — sama persis dengan halaman lain
          Text(
            'Profil Guru',
            style: AppTextStyle.headingSmall,
          ),

          const SizedBox(height: 14),

          // SCROLL AREA
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 90),
              children: [
                // KARTU IDENTITAS
                _buildProfileCard(),

                const SizedBox(height: 22),

                // DATA PRIBADI
                const _SectionTitle(title: 'Data Pribadi'),
                _InfoRow(label: 'NIP', value: _nip),
                _InfoRow(label: 'Email', value: _email),
                _InfoRow(label: 'Alamat', value: _alamat),

                const SizedBox(height: 22),

                // DATA MENGAJAR
                const _SectionTitle(title: 'Data Mengajar'),
                _InfoRow(label: 'Mata pelajaran', value: _mataPelajaran),
                _InfoRow(label: 'Wali kelas', value: _waliKelas),

                const SizedBox(height: 28),

                // PENGATURAN
                const _SectionTitle(
                  title: 'Pengaturan',
                  color: AppColors.textSecondary,
                  lineColor: AppColors.border,
                ),

                _SettingItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Jadwal Mengajar',
                  onTap: _bukaJadwal,
                ),
                _SettingItem(
                  icon: Icons.lock_outline,
                  label: 'Ubah Password',
                  onTap: _ubahPassword,
                ),
                _SettingItem(
                  icon: Icons.logout,
                  label: 'Keluar',
                  onTap: _logout,
                  showDivider: false,
                  titleColor: AppColors.error,
                ),

                const SizedBox(height: 24),

                // TOMBOL EDIT PROFIL — style tombol sama
                // dengan "Tambah Topik" di MateriGuruPage
                Center(
                  child: SizedBox(
                    height: 44,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _editProfil,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Edit Profil', style: AppTextStyle.button),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // KARTU PROFIL — mengikuti style _Kotak (radius 10,
  // shadow 0x1A000000) dari halaman lain
  // =====================================================

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 42,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _namaGuru,
            textAlign: TextAlign.center,
            style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            _waliKelas.isEmpty
                ? 'Guru'
                : 'Guru · Wali kelas $_waliKelas',
            textAlign: TextAlign.center,
            style: AppTextStyle.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// JUDUL SECTION
// =====================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  final Color lineColor;

  const _SectionTitle({
    required this.title,
    this.color = AppColors.primaryDark,
    this.lineColor = AppColors.primaryLight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: lineColor, width: 1),
        ),
      ),
      child: Text(
        title,
        style: AppTextStyle.bodySmall.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// =====================================================
// BARIS INFORMASI
// =====================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: AppTextStyle.bodyMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isEmpty ? 'Belum diatur' : value,
              textAlign: TextAlign.right,
              style: AppTextStyle.bodyMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: value.isEmpty
                    ? AppColors.textHint
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ITEM PENGATURAN
// =====================================================

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color titleColor;
  final bool showDivider;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.titleColor = AppColors.textPrimary,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  bottom: BorderSide(
                    color: AppColors.border,
                    width: 0.8,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: titleColor),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyle.bodyLarge.copyWith(
                fontSize: 13,
                color: titleColor,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// FIELD PASSWORD — pakai _Kotak style seperti halaman lain
// =====================================================

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback onToggleVisibility;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: AppTextStyle.bodyMedium.copyWith(fontSize: 12),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTextStyle.bodySmall.copyWith(fontSize: 12),
            hintStyle: AppTextStyle.hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textHint,
                size: 20,
              ),
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}