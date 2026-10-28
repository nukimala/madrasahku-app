import 'package:flutter/material.dart';

import '../../utilis/app_colors.dart';
import '../../utilis/app_text_style.dart';

class GuruHomePage extends StatefulWidget {
  const GuruHomePage({super.key});

  @override
  State<GuruHomePage> createState() => _GuruHomePageState();
}

class _GuruHomePageState extends State<GuruHomePage> {
  int _currentIndex = 0;

  static const Color _green = Color(0xFF219653);
  static const Color _blue = Color(0xFF60A5FA);

  // Data dummy jadwal hari ini (nanti bisa diganti dari database)
  final List<Map<String, String>> _jadwal = const [
    {
      'jam': '07.00 - 08.30',
      'mapel': 'Al-Quran Hadis',
      'kelas': 'Kelas VII A',
      'status': 'Mengajar',
    },
    {
      'jam': '07.00 - 08.30',
      'mapel': 'Bahasa Arab',
      'kelas': 'Kelas VII A',
      'status': 'Mengajar',
    },
  ];

  void _showComingSoon(String menu) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$menu akan kita buat berikutnya, ya!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
              _buildHeader(),
              const SizedBox(height: 20),
              _buildPresensiCard(),
              const SizedBox(height: 24),
              _buildMenu(),
              const SizedBox(height: 24),
              Text(
                'Jadwal Pelajaran Hari Ini',
                style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 12),
              ..._jadwal.map(
                (j) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _JadwalCard(
                    jam: j['jam']!,
                    mapel: j['mapel']!,
                    kelas: j['kelas']!,
                    status: j['status']!,
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

  // Header guru
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFFE5E7EB),
            shape: BoxShape.circle,
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
                'Bu Siti Nurhazila',
                style: AppTextStyle.headingSmall.copyWith(fontSize: 18),
              ),
              Text(
                'Guru',
                style: AppTextStyle.bodySmall.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Kartu presensi hari ini
  Widget _buildPresensiCard() {
    return Container(
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
          // Gambar masjid sebagai background
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/image/masjid.png',
              height: 150,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            ),
          ),

          // Judul & jam
          Positioned(
            left: 16,
            top: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Presensi Hari Ini',
                  style: AppTextStyle.headingSmall.copyWith(
                    color: AppColors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '07.00 - 14.00',
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Badge Aktif
          Positioned(
            right: 12,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Aktif',
                style: TextStyle(
                  color: _green,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // Tombol Mulai Presensi
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showComingSoon('Mulai Presensi'),
                child: const SizedBox(
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_camera, size: 18, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Mulai Presensi',
                        style: TextStyle(
                          color: _green,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Menu: Materi, Nilai, Tugas, Profil
  Widget _buildMenu() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 24,
        runSpacing: 16,
        children: [
          _MenuItem(
            title: 'Materi',
            icon: Icons.description,
            color: _green,
            onTap: () => _showComingSoon('Materi'),
          ),
          _MenuItem(
            title: 'Nilai',
            icon: Icons.description,
            color: _blue,
            onTap: () => _showComingSoon('Nilai'),
          ),
          _MenuItem(
            title: 'Tugas',
            icon: Icons.assignment_outlined,
            color: _green,
            onTap: () => _showComingSoon('Tugas'),
          ),
          _MenuItem(
            title: 'Profil',
            icon: Icons.person,
            color: _blue,
            onTap: () => _showComingSoon('Profil'),
          ),
        ],
      ),
    );
  }

  // Bottom navigation
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
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: _green,
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          if (index == 0) {
            setState(() => _currentIndex = 0);
          } else {
            const labels = ['Home', 'Materi', 'Tugas', 'Profil'];
            _showComingSoon(labels[index]);
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
        width: 84,
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
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: AppTextStyle.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JadwalCard extends StatelessWidget {
  final String jam;
  final String mapel;
  final String kelas;
  final String status;

  const _JadwalCard({
    required this.jam,
    required this.mapel,
    required this.kelas,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.description, size: 32, color: Color(0xFF219653)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jam,
                  style: AppTextStyle.bodySmall.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  mapel,
                  style: AppTextStyle.headingSmall.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  kelas,
                  style: AppTextStyle.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Color(0xFF219653),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}