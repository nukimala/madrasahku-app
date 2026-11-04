import 'package:flutter/material.dart';

import '../../models/jadwal_model.dart';
import '../../services/auth_service.dart';
import '../../services/jadwal_service.dart';
import '../../utilis/app_colors.dart';
import '../../utilis/app_text_style.dart';

import 'jadwal/jadwal_guru_page.dart';
import 'materi/materi_guru_page.dart';
import 'tugas/tugas_guru_page.dart';

class GuruHomePage extends StatefulWidget {
  const GuruHomePage({super.key});

  @override
  State<GuruHomePage> createState() => _GuruHomePageState();
}

class _GuruHomePageState extends State<GuruHomePage> {
  int _currentIndex = 0;

  static const Color _green = Color(0xFF219653);

  // Jumlah tugas yang perlu dinilai .
  final int _tugasPerluDinilai = 2;

  void _showComingSoon(String menu) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$menu akan kita buat berikutnya, ya!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openMateri() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MateriGuruPage()),
    );
  }

  void _openTugas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TugasGuruPage()),
    );
  }

  Future<void> _openJadwal() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const JadwalGuruPage()),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Jadwal guru yang login pada hari ini
    final todayIndex = DateTime.now().weekday - 1;
    final todaySchedules =
        todayIndex >= 0 && todayIndex < HariSekolah.values.length
        ? JadwalService.instance.jadwalGuru(
            tahunAjaran: JadwalService.tahunAjaranTersedia.first,
            semester: Semester.ganjil,
            guru: AuthService.instance.currentTeacherName ?? '',
            hari: HariSekolah.values[todayIndex],
          )
        : <JadwalPelajaran>[];

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
              const SizedBox(height: 22),

              // Aktivitas mengajar
              Text(
                'Aktivitas Mengajar',
                style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 12),
              _buildAktivitas(jumlahJadwal: todaySchedules.length),
              const SizedBox(height: 24),

              // Jadwal pelajaran hari ini
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Jadwal Pelajaran',
                      style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
                    ),
                  ),
                  GestureDetector(
                    onTap: _openJadwal,
                    child: const Text(
                      'Lihat semua',
                      style: TextStyle(
                        color: _green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (todaySchedules.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Belum ada jadwal mengajar hari ini.',
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ...todaySchedules.map(
                (jadwal) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _JadwalCard(
                    jam:
                        '${formatMenit(jadwal.mulaiMenit)} - ${formatMenit(jadwal.selesaiMenit)}',
                    mapel: jadwal.mataPelajaran,
                    kelas: 'Kelas ${jadwal.kelas} · ${jadwal.ruang}',
                    status: 'Mengajar',
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
                AuthService.instance.currentTeacherName ?? 'Guru',
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

  //jumlah jadwal hari ini & tugas perlu dinilai
  Widget _buildAktivitas({required int jumlahJadwal}) {
    return Row(
      children: [
        Expanded(
          child: _AktivitasCard(
            icon: Icons.calendar_month_outlined,
            jumlah: '$jumlahJadwal',
            label: 'jadwal hari ini',
            onTap: _openJadwal,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _AktivitasCard(
            icon: Icons.assignment_turned_in_outlined,
            jumlah: '$_tugasPerluDinilai',
            label: 'Tugas Perlu Dinilai',
            onTap: _openTugas,
          ),
        ),
      ],
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
          } else if (index == 1) {
            _openMateri();
          } else if (index == 2) {
            _openTugas();
          } else {
            _showComingSoon('Profil');
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

// Kartu ringkasan aktivitas 
class _AktivitasCard extends StatelessWidget {
  final IconData icon;
  final String jumlah;
  final String label;
  final VoidCallback onTap;

  const _AktivitasCard({
    required this.icon,
    required this.jumlah,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 120,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 30, color: const Color(0xFF219653)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jumlah,
                    style: AppTextStyle.headingSmall.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodySmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
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
                Text(jam, style: AppTextStyle.bodySmall.copyWith(fontSize: 11)),
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