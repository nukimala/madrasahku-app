import 'package:flutter/material.dart';

import '../../utilis/app_colors.dart';
import '../../utilis/app_text_style.dart';
import '../../services/auth_service.dart';
import 'kelas/data_kelas_page.dart';
import 'guru/data_guru_page.dart';
import 'mapel/data_mapel_page.dart';
import 'profil/admin_profile_page.dart';
import 'siswa/data_siswa_page.dart';
import 'rekap_presensi_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  Future<void> _openProfile() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const AdminProfilePage()),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profile = AuthService.instance.adminProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header admin
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _openProfile,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE5E7EB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 38,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Assalamu’alaikum,',
                                    style: AppTextStyle.bodySmall.copyWith(fontSize: 13),
                                  ),
                                  Text(
                                    profile.namaLengkap,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyle.headingSmall.copyWith(fontSize: 18),
                                  ),
                                  Text(
                                    'Administrator',
                                    style: AppTextStyle.bodySmall.copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Menu notifikasi belum tersedia'),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 30,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Banner utama
              Container(
                width: double.infinity,
                height: 160,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF35C979), Color(0xFF4ADE80)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      top: 16,
                      right: 12,
                      child: Text(
                        'Kelola madrasah dengan mudah,\n'
                        'semua dalam satu aplikasi. ✨',
                        style: AppTextStyle.headingSmall.copyWith(
                          color: AppColors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Gambar masjid di atas bukit
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Image.asset(
                        'assets/image/masjid.png',
                        height: 180,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Menu utama
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 112, // tinggi tiap menu (kotak + teks)
                ),
                children: [
                  _MenuItem(
                    title: 'Data Guru',
                    icon: Icons.person,
                    color: const Color(0xFF219653),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DataGuruPage()),
                    ),
                  ),
                  _MenuItem(
                    title: 'Data Siswa',
                    icon: Icons.person,
                    color: const Color(0xFF60A5FA),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DataSiswaPage()),
                    ),
                  ),
                  _MenuItem(
                    title: 'Data Kelas',
                    icon: Icons.description,
                    color: const Color(0xFF219653),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DataKelasPage()),
                    ),
                  ),
                  _MenuItem(
                    title: 'Mata Pelajaran',
                    icon: Icons.assignment_outlined,
                    color: const Color(0xFF219653),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DataMapelPage()),
                    ),
                  ),
                  _MenuItem(
                    title: 'Jadwal',
                    icon: Icons.calendar_month_outlined,
                    color: const Color(0xFF60A5FA),
                    onTap: () => _showComingSoon(context, 'Jadwal'),
                  ),
                  _MenuItem(
                    title: 'Profil',
                    icon: Icons.account_circle_outlined,
                    color: const Color(0xFF60A5FA),
                    onTap: _openProfile,
                  ),
                  _MenuItem(
                    title: 'rekap presensi',
                    icon: Icons.fact_check_outlined,
                    color: const Color(0xFF60A5FA),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RekapPresensiPage()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showComingSoon(BuildContext context, String menu) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$menu akan kita buat berikutnya, ya!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 44, color: color),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: AppTextStyle.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
