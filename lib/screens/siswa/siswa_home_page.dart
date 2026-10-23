import 'package:flutter/material.dart';

import '../../utilis/app_colors.dart';
import '../../utilis/app_text_style.dart';

import 'Materi/materi_page.dart';

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
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Banner utama
              Container(
                width: double.infinity,
                height: 154,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF35C979), Color(0xFF4ADE80)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      top: 17,
                      right: 12,
                      child: Text(
                        'Jadikan ilmu sebagai\n'
                        'jalan meraih ridha Allah',
                        style: AppTextStyle.headingSmall.copyWith(
                          color: AppColors.white,
                          fontSize: 14,
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
                        height: 127,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Menu utama (2 x 2)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MenuItem(
                          title: 'Materi',
                          icon: Icons.menu_book_outlined,
                          color: const Color(0xFF219653),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MateriPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 52),
                        _MenuItem(
                          title: 'Tugas',
                          icon: Icons.description,
                          color: const Color(0xFF60A5FA),
                          onTap: () => _showComingSoon(context, 'Tugas'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MenuItem(
                          title: 'Nilai',
                          icon: Icons.assignment_outlined,
                          color: const Color(0xFF219653),
                          onTap: () => _showComingSoon(context, 'Nilai'),
                        ),
                        const SizedBox(width: 52),
                        _MenuItem(
                          title: 'Profil',
                          icon: Icons.person,
                          color: const Color(0xFF60A5FA),
                          onTap: () => _showComingSoon(context, 'Profil'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tugas terbaru
              Text(
                'Tugas Terbaru',
                style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 12),
              _TaskCard(
                subject: 'Matematika',
                title: 'Bab 3 - Persamaan Linear',
                deadline: 'Batas: 12 April 2026',
                isNew: true,
                onTap: () => _showComingSoon(context, 'Detail Tugas'),
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
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedFontSize: 10,
        unselectedFontSize: 10,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const MateriPage()));
          } else if (index == 2) {
            _showComingSoon(context, 'Tugas');
          } else if (index == 3) {
            _showComingSoon(context, 'Profil');
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
            icon: Icon(Icons.edit_note_rounded),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
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
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodySmall.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String subject;
  final String title;
  final String deadline;
  final bool isNew;
  final VoidCallback onTap;

  const _TaskCard({
    required this.subject,
    required this.title,
    required this.deadline,
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
            children: [
              const Icon(Icons.description, size: 30, color: Color(0xFF60A5FA)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      deadline,
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
