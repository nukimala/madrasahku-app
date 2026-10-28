import 'package:flutter/material.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';
import '../Materi/materi_page.dart';

enum TugasStatus { aktif, dikumpulkan, selesai }

class _TugasItem {
  final String title;
  final String subject;
  final String fileInfo;
  final TugasStatus status;
  final bool isNew;

  const _TugasItem({
    required this.title,
    required this.subject,
    required this.fileInfo,
    required this.status,
    this.isNew = false,
  });
}

class TugasPage extends StatefulWidget {
  const TugasPage({super.key});

  @override
  State<TugasPage> createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  static const Color _green = Color(0xFF219653);
  static const Color _blue = Color(0xFF60A5FA);

  // Data dummy (nanti bisa diganti dari API / database)
  static const List<_TugasItem> _allTugas = [
    _TugasItem(
      title: 'Persamaan Linear',
      subject: 'Matematika',
      fileInfo: 'PDF 2.5 MB',
      status: TugasStatus.aktif,
      isNew: true,
    ),
    _TugasItem(
      title: 'Hafalan Surat',
      subject: 'Al-Quran Hadis',
      fileInfo: 'PDF 2.5 MB',
      status: TugasStatus.aktif,
    ),
    _TugasItem(
      title: 'Kosa Kata Bahasa Arab',
      subject: 'Bahasa Arab',
      fileInfo: 'PDF 2.5 MB',
      status: TugasStatus.aktif,
    ),
    _TugasItem(
      title: 'Adab Islami',
      subject: 'Akidah Akhlak',
      fileInfo: 'PPT 2.5 MB',
      status: TugasStatus.aktif,
    ),
    _TugasItem(
      title: 'Ketentuan Zakat',
      subject: 'Fikih',
      fileInfo: 'PDF 2.5 MB',
      status: TugasStatus.aktif,
    ),
    _TugasItem(
      title: 'Fotosintesis',
      subject: 'IPA',
      fileInfo: 'Gambar 2.5 MB',
      status: TugasStatus.aktif,
    ),
    _TugasItem(
      title: 'Teks Narasi',
      subject: 'Bahasa Indonesia',
      fileInfo: 'PDF 1.8 MB',
      status: TugasStatus.dikumpulkan,
    ),
    _TugasItem(
      title: 'Sejarah Kerajaan Islam',
      subject: 'SKI',
      fileInfo: 'PPT 3.2 MB',
      status: TugasStatus.selesai,
    ),
  ];

  static const List<String> _tabs = ['Aktif', 'Dikumpulkan', 'Selesai'];

  int _selectedTab = 0;
  String _query = '';

  List<_TugasItem> get _filtered {
    final status = TugasStatus.values[_selectedTab];
    return _allTugas.where((t) {
      final matchStatus = t.status == status;
      final q = _query.trim().toLowerCase();
      final matchQuery = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.subject.toLowerCase().contains(q);
      return matchStatus && matchQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.maybePop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_back,
                        size: 22,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Tugas', style: AppTextStyle.headingSmall),
                ],
              ),

              const SizedBox(height: 16),

              // Tab filter
              Row(
                children: List.generate(_tabs.length, (index) {
                  final selected = index == _selectedTab;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == _tabs.length - 1 ? 0 : 8,
                      ),
                      child: _TabChip(
                        label: _tabs[index],
                        selected: selected,
                        onTap: () => setState(() => _selectedTab = index),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Search
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  style: AppTextStyle.bodySmall.copyWith(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Cari Materi...',
                    hintStyle: AppTextStyle.bodySmall.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF9CA3AF),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: Color(0xFF6B7280),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // List tugas
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada tugas',
                          style: AppTextStyle.bodySmall,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 16, top: 2),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _TugasCard(
                            item: item,
                            onTap: () => _showComingSoon(
                              context,
                              'Detail Tugas ${item.title}',
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: _green,
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedFontSize: 10,
        unselectedFontSize: 10,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MateriPage()),
            );
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

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF219653) : AppColors.white,
      elevation: selected ? 0 : 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 32,
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyle.bodySmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _TugasCard extends StatelessWidget {
  final _TugasItem item;
  final VoidCallback onTap;

  const _TugasCard({required this.item, required this.onTap});

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
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subject,
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      item.fileInfo,
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.isNew)
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