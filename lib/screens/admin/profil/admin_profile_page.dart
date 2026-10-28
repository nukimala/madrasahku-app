import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';
import '../../auth/login_page.dart';
import 'edit_admin_profile_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  AuthService get _authService => AuthService.instance;

  Future<void> _editProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditAdminProfilePage(profile: _authService.adminProfile),
      ),
    );
    if (updated == true && mounted) setState(() {});
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
                final changed = _authService.changeAdminPassword(
                  currentPassword: currentPasswordController.text,
                  newPassword: newPasswordController.text,
                );
                if (!changed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password saat ini tidak sesuai.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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
        const SnackBar(content: Text('Password berhasil diubah.')),
      );
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Keluar dari akun?', style: AppTextStyle.headingSmall),
        content: Text(
          'Kamu perlu masuk kembali untuk mengakses beranda admin.',
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
    final profile = _authService.adminProfile;

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
          'Profil',
          style: AppTextStyle.headingSmall.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _ProfileHero(name: profile.namaLengkap),
            const SizedBox(height: 28),
            const _SectionHeading('Informasi Admin'),
            _InfoRow(label: 'Nama Lengkap', value: profile.namaLengkap),
            _InfoRow(label: 'Email', value: profile.email),
            _InfoRow(label: 'Username', value: profile.username),
            _InfoRow(label: 'No. Telepon', value: profile.nomorTelepon),
            const SizedBox(height: 28),
            const _SectionHeading('Pengaturan Akun'),
            _SettingRow(
              icon: Icons.person_outline,
              label: 'Ubah Profil',
              onTap: _editProfile,
            ),
            _SettingRow(
              icon: Icons.lock_outline,
              label: 'Ubah Password',
              onTap: _changePassword,
            ),
            _SettingRow(icon: Icons.logout, label: 'Keluar', onTap: _logout),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit_outlined),
                label: Text(
                  'Edit Profil',
                  style: AppTextStyle.button.copyWith(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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

class _ProfileHero extends StatelessWidget {
  final String name;

  const _ProfileHero({required this.name});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 28),
    decoration: _cardDecoration(),
    child: Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            color: Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 68, color: Color(0xFF777777)),
        ),
        const SizedBox(height: 12),
        Text(name, style: AppTextStyle.headingSmall.copyWith(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          'Administrator',
          style: AppTextStyle.bodyLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  final String title;

  const _SectionHeading(this.title);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.headingSmall.copyWith(
            color: AppColors.primaryDark,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, color: AppColors.primaryLight),
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 52),
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyle.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyle.bodyLarge,
          ),
        ),
      ],
    ),
  );
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      height: 56,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: AppTextStyle.bodyLarge)),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    ),
  );
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

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.white,
  borderRadius: BorderRadius.circular(14),
  boxShadow: const [
    BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 2)),
  ],
);
