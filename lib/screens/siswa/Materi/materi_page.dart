import 'package:flutter/material.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';
import 'detail_materi_page.dart';
import '../siswa_home_page.dart';

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  static const _semuaMapel = 'Semua Mata Pelajaran';

  final _kelasList = const ['Kelas VIII A', 'Kelas VIII B', 'Kelas VIII C'];

  final _materiList = const [
    _Materi('Matematika', 'Bab 3 - Persamaan Linear', 'PDF 2.5 MB'),
    _Materi('Al-Quran Hadis', 'Bab 3 - Hafalan Surat', 'PPT 2.5 MB'),
    _Materi('Bahasa Arab', 'Bab 3 - Kosa Kata', 'PDF 2.5 MB'),
    _Materi('Akidah Akhlak', 'Bab 3 - Adab Zakat', 'PPT 2.5 MB'),
    _Materi('Fikih', 'Bab 3 - Ketentuan Zakat', 'PDF 2.5 MB'),
    _Materi('IPA', 'Bab 1 - Fotosintesis', 'Gambar 2.5 MB'),
  ];

  String _selectedKelas = 'Kelas VIII A';
  String _selectedMapel = _semuaMapel;
  String _query = '';

  List<String> get _mapelList => [
        _semuaMapel,
        ..._materiList.map((m) => m.subject),
      ];

  List<_Materi> get _filteredMateri {
    final q = _query.trim().toLowerCase();
    return _materiList.where((m) {
      final cocokMapel =
          _selectedMapel == _semuaMapel || m.subject == _selectedMapel;
      final cocokCari = q.isEmpty ||
          m.subject.toLowerCase().contains(q) ||
          m.title.toLowerCase().contains(q);
      return cocokMapel && cocokCari;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = _filteredMateri;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _goHome(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Materi Pembelajaran',
                    style: AppTextStyle.headingSmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Filter kelas & mata pelajaran
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _FilterDropdown(
                      value: _selectedKelas,
                      items: _kelasList,
                      onChanged: (v) => setState(() => _selectedKelas = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 6,
                    child: _FilterDropdown(
                      value: _selectedMapel,
                      items: _mapelList.toSet().toList(),
                      onChanged: (v) => setState(() => _selectedMapel = v),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Pencarian
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: AppTextStyle.bodySmall.copyWith(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Cari Materi....',
                    hintStyle: AppTextStyle.bodySmall.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF9CA3AF),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 22,
                      color: AppColors.textPrimary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Daftar materi
            Expanded(
              child: data.isEmpty
                  ? Center(
                      child: Text(
                        'Materi tidak ditemukan',
                        style: AppTextStyle.bodySmall,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final materi = data[index];
                        return _MateriCard(
                          materi: materi,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailMateriPage(
                                judul: materi.title.split(' - ').last,
                                mapel: materi.subject,
                                kelas: _selectedKelas,
                              ),
                            ),
                          ),
                          onDownload: () => _showComingSoon(
                            context,
                            'Unduh ${materi.subject}',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: const Color(0xFF219653),
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedFontSize: 10,
        unselectedFontSize: 10,
        onTap: (index) {
          if (index == 1) return;
          if (index == 0) {
            _goHome(context);
            return;
          }
          const labels = ['Home', 'Materi', 'Tugas', 'Profile'];
          _showComingSoon(context, labels[index]);
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
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  static void _goHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SiswaHomePage()),
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

class _Materi {
  final String subject;
  final String title;
  final String fileInfo;

  const _Materi(this.subject, this.title, this.fileInfo);
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textPrimary,
          ),
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          style: AppTextStyle.bodySmall.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _MateriCard extends StatelessWidget {
  final _Materi materi;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  const _MateriCard({
    required this.materi,
    required this.onTap,
    required this.onDownload,
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
              const Icon(
                Icons.description,
                size: 32,
                color: Color(0xFF219653),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      materi.subject,
                      style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      materi.title,
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      materi.fileInfo,
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDownload,
                icon: const Icon(
                  Icons.download_rounded,
                  size: 24,
                  color: Color(0xFF219653),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}