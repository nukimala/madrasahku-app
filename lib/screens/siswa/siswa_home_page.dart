import 'package:flutter/material.dart';

import '../../utilis/app_colors.dart';
import '../../utilis/app_text_style.dart';

import 'Materi/materi_page.dart';
import 'tugas/tugas_page.dart';
import 'tugas/upload_tugas_page.dart';
import 'profile/profil_siswa_page.dart';

class SiswaHomePage extends StatelessWidget {
  const SiswaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header siswa
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assalamu’alaikum,',
                          style: AppTextStyle.bodySmall,
                        ),
                        Text('Ahmad Fauzi', style: AppTextStyle.headingSmall),
                        Text(
                          'Siswa - Kelas VIII A',
                          style: AppTextStyle.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Banner utama
              Container(
                width: double.infinity,
                height: 130,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2F9E62), Color(0xFF4ADE80)],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      top: 16,
                      right: 12,
                      child: Text(
                        'Jadikan Ilmu sebagai\n'
                        'jalan meraih ridha Allah',
                        style: AppTextStyle.headingSmall.copyWith(
                          color: AppColors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
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

              // Aktivitas Pembelajaran
              Text(
                'Aktivitas Pembelajaran',
                style: AppTextStyle.headingSmall.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _ActivityCard(
                      icon: Icons.menu_book_outlined,
                      count: '5',
                      label: 'Materi Belum Dibaca',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MateriPage(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _ActivityCard(
                      icon: Icons.assignment_turned_in_outlined,
                      count: '2',
                      label: 'Tugas Perlu Dikerjakan',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TugasPage(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Tugas terbaru
              Text(
                'Tugas Terbaru',
                style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 12),
              _TaskCard(
                title: 'Matematika',
                line1: 'Bab 3 - Persamaan Linear',
                line2: 'Batas: 12 April 2026',
                isNew: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadTugasPage(
                      title: 'Bab 3 - Persamaan Linear',
                      subject: 'Matematika',
                      deadline: '12 April 2026',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _TaskCard(
                title: 'Hafalan Surat',
                line1: 'Al-Quran Hadis',
                line2: 'PPT 2.5 MB',
                isNew: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UploadTugasPage(
                      title: 'Hafalan Surat',
                      subject: 'Al-Quran Hadis',
                      deadline: '12 April 2026',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: const Color(0xFF219653),
        unselectedItemColor: const Color(0xFFD1D5DB),
        selectedFontSize: 10,
        unselectedFontSize: 10,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const MateriPage()));
          } else if (index == 2) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const TugasPage()));
          } else if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfilSiswaPage()),
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

}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 26, color: const Color(0xFF219653)),
              const SizedBox(height: 6),
              Text(
                count,
                style: AppTextStyle.headingSmall.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String line1;
  final String line2;
  final bool isNew;
  final VoidCallback onTap;

  const _TaskCard({
    required this.title,
    required this.line1,
    required this.line2,
    required this.isNew,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.description,
                  size: 30,
                  color: Color(0xFF60A5FA),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      line1,
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      line2,
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isNew)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD9D9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Baru',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}