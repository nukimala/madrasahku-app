import 'package:flutter/material.dart';

import '../../../models/guru_model.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';
import 'tambah_guru_page.dart';

class DataGuruPage extends StatefulWidget {
  const DataGuruPage({super.key});

  @override
  State<DataGuruPage> createState() => _DataGuruPageState();
}

class _DataGuruPageState extends State<DataGuruPage> {
  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';

  // Data dummy, nanti diganti dari service/database
  final List<GuruItem> _guruList = [
    const GuruItem(nama: 'Ahmad Fauzi', mapel: 'Matematika'),
    const GuruItem(nama: 'Siti Nurhaliza', mapel: 'Bahasa Indonesia'),
    const GuruItem(nama: 'Budi Santoso', mapel: 'IPA'),
    const GuruItem(nama: 'Nur Aini', mapel: 'Bahasa Inggris'),
    const GuruItem(nama: 'Rizky Maulana', mapel: 'PAI'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GuruItem> get _filtered => _guruList
      .where((g) => g.nama.toLowerCase().contains(_keyword.toLowerCase()))
      .toList();

  Future<void> _openTambah() async {
    final guru = await Navigator.push<GuruItem>(
      context,
      MaterialPageRoute(builder: (_) => const TambahGuruPage()),
    );

    if (!mounted || guru == null) return;

    setState(() {
      _guruList.insert(0, guru);
      _keyword = '';
      _searchController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data guru berhasil ditambahkan')),
    );
  }

  Future<void> _openEdit(GuruItem guru) async {
    final updatedGuru = await Navigator.push<GuruItem>(
      context,
      MaterialPageRoute(builder: (_) => TambahGuruPage(guru: guru)),
    );

    if (!mounted || updatedGuru == null) return;

    final index = _guruList.indexOf(guru);
    if (index == -1) return;

    setState(() {
      _guruList[index] = updatedGuru;
      _keyword = '';
      _searchController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data guru berhasil diperbarui')),
    );
  }

  void _confirmDelete(GuruItem guru) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Hapus Guru',
          style: AppTextStyle.headingSmall.copyWith(fontSize: 18),
        ),
        content: Text(
          'Yakin ingin menghapus ${guru.nama}?',
          style: AppTextStyle.bodyMedium.copyWith(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(fontSize: 15)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _guruList.remove(guru));
              Navigator.pop(ctx);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Data Guru',
          style: AppTextStyle.headingSmall.copyWith(fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: _openTambah,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    '+ Tambah',
                    style: AppTextStyle.button.copyWith(fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          children: [
            // Search
            Container(
              height: 54,
              decoration: _cardDecoration(radius: 12),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _keyword = v),
                style: AppTextStyle.bodyLarge.copyWith(fontSize: 16),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Cari nama guru...',
                  hintStyle: AppTextStyle.hint.copyWith(fontSize: 16),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 26,
                    color: AppColors.textPrimary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // List guru
            Expanded(
              child: data.isEmpty
                  ? Center(
                      child: Text(
                        'Data guru tidak ditemukan',
                        style: AppTextStyle.bodyMedium.copyWith(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final guru = data[i];
                        return _GuruCard(
                          guru: guru,
                          onEdit: () => _openEdit(guru),
                          onDelete: () => _confirmDelete(guru),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration({double radius = 14}) {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [
      BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );
}

class _GuruCard extends StatelessWidget {
  final GuruItem guru;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GuruCard({
    required this.guru,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFE5E7EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 36, color: Color(0xFF374151)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guru.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.headingSmall.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 3),
                Text(
                  'Guru ${guru.mapel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.bodySmall.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: guru.aktif
                  ? AppColors.primaryLight
                  : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              guru.aktif ? 'Aktif' : 'Nonaktif',
              style: AppTextStyle.bodySmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: guru.aktif ? AppColors.primary : AppColors.error,
              ),
            ),
          ),
          PopupMenuButton<String>(
            padding: const EdgeInsets.all(4),
            icon: const Icon(
              Icons.more_vert,
              size: 28,
              color: AppColors.textPrimary,
            ),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'hapus') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                height: 48,
                child: Text(
                  'Edit',
                  style: AppTextStyle.bodyMedium.copyWith(fontSize: 15),
                ),
              ),
              PopupMenuItem(
                value: 'hapus',
                height: 48,
                child: Text(
                  'Hapus',
                  style: AppTextStyle.bodyMedium.copyWith(
                    fontSize: 15,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
