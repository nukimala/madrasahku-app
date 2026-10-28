import 'package:flutter/material.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class MateriGuruPage extends StatefulWidget {
  const MateriGuruPage({super.key});

  @override
  State<MateriGuruPage> createState() => _MateriGuruPageState();
}

class _MateriGuruPageState extends State<MateriGuruPage> {
  static const Color _green = Color(0xFF219653);
  static const Color _orange = Color(0xFFFF8A2B);

  final TextEditingController _searchController = TextEditingController();

  // Pilihan dropdown (nanti bisa diganti dari database)
  final List<String> _kelasList = const ['Kelas VII A', 'Kelas VIII A', 'Kelas IX A'];
  final List<String> _mapelList = const ['Matematika', 'Al-Quran Hadis', 'Bahasa Arab'];

  String _selectedKelas = 'Kelas VIII A';
  String _selectedMapel = 'Matematika';
  String _query = '';

  // Data dummy materi (nanti bisa diganti dari database)
  final List<Map<String, String>> _materi = const [
    {
      'judul': 'Himpunan',
      'bab': 'Bab 3 - Himpunan',
      'file': 'PDF 2.5 MB',
    },
    {
      'judul': 'Persaamaan Linier',
      'bab': 'Bab 3 - Persamaan Linear',
      'file': 'PPT 2.5 MB',
    },
    {
      'judul': 'Fungsi Linier',
      'bab': 'Bab 3 - Fungsi Linear',
      'file': 'PDF 2.5 MB',
    },
    {
      'judul': 'Aritmatika',
      'bab': 'Bab 3 -AritmatikaLinear',
      'file': 'PPT 2.5 MB',
    },
    {
      'judul': 'Statistika',
      'bab': 'Bab 3 - Statistika',
      'file': 'PDF 2.5 MB',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showComingSoon(String menu) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$menu akan kita buat berikutnya, ya!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Map<String, String>> get _filteredMateri {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _materi;
    return _materi
        .where((m) =>
            m['judul']!.toLowerCase().contains(q) ||
            m['bab']!.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = _filteredMateri;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Materi Pembelajaran',
                    style: AppTextStyle.headingSmall.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Filter kelas & mapel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      value: _selectedKelas,
                      items: _kelasList,
                      onChanged: (v) => setState(() => _selectedKelas = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      value: _selectedMapel,
                      items: _mapelList,
                      onChanged: (v) => setState(() => _selectedMapel = v!),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Pencarian
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearch(),
            ),

            const SizedBox(height: 14),

            // Daftar materi
            Expanded(
              child: data.isEmpty
                  ? Center(
                      child: Text(
                        'Materi tidak ditemukan',
                        style: AppTextStyle.bodySmall.copyWith(fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        final m = data[i];
                        return _MateriCard(
                          judul: m['judul']!,
                          bab: m['bab']!,
                          file: m['file']!,
                          iconColor: _orange,
                          onTap: () => _showComingSoon(m['judul']!),
                        );
                      },
                    ),
            ),

            // Tombol tambah materi
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 8, 40, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _showComingSoon('Tambah Materi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    '+ Tambah Materi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Dropdown putih dengan bayangan
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: _cardDecoration(radius: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: AppTextStyle.bodyMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Kolom cari
  Widget _buildSearch() {
    return Container(
      height: 46,
      decoration: _cardDecoration(radius: 12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v),
        style: const TextStyle(fontSize: 13),
        decoration: const InputDecoration(
          hintText: 'Cari Materi....',
          hintStyle: TextStyle(
            color: Color(0xFF8A9B91),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.black87, size: 24),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  // Bottom navigation (tab Materi aktif)
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
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: _green,
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context); // kembali ke beranda guru
          } else if (index != 1) {
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

  static BoxDecoration _cardDecoration({double radius = 14}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
}

class _MateriCard extends StatelessWidget {
  final String judul;
  final String bab;
  final String file;
  final Color iconColor;
  final VoidCallback onTap;

  const _MateriCard({
    required this.judul,
    required this.bab,
    required this.file,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: _MateriGuruCardStyle.decoration,
          child: Row(
            children: [
              Icon(Icons.description, size: 38, color: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: AppTextStyle.headingSmall.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bab,
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      file,
                      style: AppTextStyle.bodySmall.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MateriGuruCardStyle {
  static final BoxDecoration decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: const [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );
}