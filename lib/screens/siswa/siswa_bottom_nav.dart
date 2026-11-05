import 'package:flutter/material.dart';

import '../../utilis/app_colors.dart';
import 'materi/materi_page.dart';
import 'profile/profil_siswa_page.dart';
import 'siswa_home_page.dart';
import 'tugas/tugas_page.dart';

class SiswaBottomNav extends StatelessWidget {
  final int currentIndex;

  const SiswaBottomNav({super.key, required this.currentIndex});

  static const _green = Color(0xFF219653);

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        // Home = root, hapus semua halaman di atasnya
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SiswaHomePage()),
          (route) => false,
        );
        break;
      case 1:
        _replace(context, const MateriPage());
        break;
      case 2:
        _replace(context, const TugasPage());
        break;
      case 3:
        _replace(context, const ProfilSiswaPage());
        break;
    }
  }

  void _replace(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.white,
      selectedItemColor: _green,
      unselectedItemColor: const Color(0xFF9CA3AF),
      selectedFontSize: 10,
      unselectedFontSize: 10,
      onTap: (i) => _onTap(context, i),
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
          label: 'Profile',
        ),
      ],
    );
  }
}