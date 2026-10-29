import 'package:flutter/material.dart';
import '../../../utilis/app_colors.dart';
import '../guru_home_page.dart';
import '../materi/materi_guru_page.dart';
import '../profile/profil_guru_page.dart';
import 'tambah_tugas_page.dart';

class GuruTugasItem {
  final String title;
  final String subtitle;
  final String fileInfo;
  final String kelas;
  final String mapel;

  const GuruTugasItem({
    required this.title,
    required this.subtitle,
    required this.fileInfo,
    required this.kelas,
    required this.mapel,
  });
}

class TugasGuruPage extends StatefulWidget {
  const TugasGuruPage({super.key});

  @override
  State<TugasGuruPage> createState() => _TugasGuruPageState();
}

class _TugasGuruPageState extends State<TugasGuruPage> {
  static const Color _green = Color(0xFF219653);

  final List<String> _kelasList = ['Semua Kelas', 'Kelas VII A', 'Kelas VIII A', 'Kelas IX A'];
  final List<String> _mapelList = ['Semua Mapel', 'Matematika', 'Al-Quran Hadis', 'Bahasa Arab', 'IPA'];

  String _selectedKelas = 'Kelas VIII A';
  String _selectedMapel = 'Matematika';
  String _searchQuery = '';

  final List<GuruTugasItem> _tugasList = [
    const GuruTugasItem(
      title: 'Himpunan',
      subtitle: 'Bab 3 - Himpunan',
      fileInfo: 'PDF 2.5 MB',
      kelas: 'Kelas VIII A',
      mapel: 'Matematika',
    ),
    const GuruTugasItem(
      title: 'Persamaan Linier',
      subtitle: 'Bab 3 - Persamaan Linear',
      fileInfo: 'PPT 2.5 MB',
      kelas: 'Kelas VIII A',
      mapel: 'Matematika',
    ),
    const GuruTugasItem(
      title: 'Fungsi Linier',
      subtitle: 'Bab 3 - Fungsi Linear',
      fileInfo: 'PDF 2.5 MB',
      kelas: 'Kelas VIII A',
      mapel: 'Matematika',
    ),
    const GuruTugasItem(
      title: 'Aritmatika',
      subtitle: 'Bab 3 - AritmatikaLinear',
      fileInfo: 'PPT 2.5 MB',
      kelas: 'Kelas VIII A',
      mapel: 'Matematika',
    ),
    const GuruTugasItem(
      title: 'Statistika',
      subtitle: 'Bab 3 - Statistika',
      fileInfo: 'PDF 2.5 MB',
      kelas: 'Kelas VIII A',
      mapel: 'Matematika',
    ),
  ];


  List<GuruTugasItem> get _filteredList {
    return _tugasList.where((item) {
      final matchKelas = _selectedKelas == 'Semua Kelas' || item.kelas == _selectedKelas;
      final matchMapel = _selectedMapel == 'Semua Mapel' || item.mapel == _selectedMapel;
      final q = _searchQuery.trim().toLowerCase();
      final matchQuery = q.isEmpty ||
          item.title.toLowerCase().contains(q) ||
          item.subtitle.toLowerCase().contains(q);
      return matchKelas && matchMapel && matchQuery;
    }).toList();
  }

  void _openTambahTugas() async {
    final result = await Navigator.push<GuruTugasItem>(
      context,
      MaterialPageRoute(builder: (_) => const TambahTugasPage()),
    );
    if (result != null) {
      setState(() {
        _tugasList.insert(0, result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredList;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Tugas',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Dropdown Kelas
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x10000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedKelas,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF374151)),
                            items: _kelasList.map((k) => DropdownMenuItem(
                              value: k,
                              child: Text(k, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedKelas = val);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Dropdown Mapel
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x10000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedMapel,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF374151)),
                            items: _mapelList.map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedMapel = val);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Search Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'Cari Tugas....',
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF374151), size: 22),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List of Tasks
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('Tidak ada tugas pada filter ini.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.description, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.subtitle,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.fileInfo,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Bottom "+ Tambah Tugas" Button
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _openTambahTugas,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  '+ Tambah Tugas',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _green,
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          if (index == 2) return;
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GuruHomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MateriGuruPage()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfilGuruPage()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Materi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
