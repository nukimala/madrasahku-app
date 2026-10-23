import 'package:flutter/material.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';
import 'tambah_siswa_page.dart';

/// Model sederhana (sementara). Nanti bisa dipindah ke folder models.
class SiswaItem {
  final String nama;
  final String kelas;
  final bool aktif;

  const SiswaItem({
    required this.nama,
    required this.kelas,
    this.aktif = true,
  });
}

class DataSiswaPage extends StatefulWidget {
  const DataSiswaPage({super.key});

  @override
  State<DataSiswaPage> createState() => _DataSiswaPageState();
}

class _DataSiswaPageState extends State<DataSiswaPage> {
  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';

  // Data dummy, nanti diganti dari service/database
  final List<SiswaItem> _siswaList = [
    const SiswaItem(nama: 'Ahmad Rifai', kelas: 'Kelas VIII A'),
    const SiswaItem(nama: 'Siti Aisyah', kelas: 'Kelas VIII A'),
    const SiswaItem(nama: 'Fahri Maulana', kelas: 'Kelas VIII A'),
    const SiswaItem(nama: 'Naila Putri', kelas: 'Kelas VIII A'),
    const SiswaItem(nama: 'Muhammad Iqbal', kelas: 'Kelas VIII A'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SiswaItem> get _filtered => _siswaList
      .where((s) => s.nama.toLowerCase().contains(_keyword.toLowerCase()))
      .toList();

  void _openTambah() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TambahSiswaPage()),
    );
  }

  void _confirmDelete(SiswaItem siswa) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Hapus Siswa',
          style: AppTextStyle.headingSmall.copyWith(fontSize: 18),
        ),
        content: Text(
          'Yakin ingin menghapus ${siswa.nama}?',
          style: AppTextStyle.bodyMedium.copyWith(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(fontSize: 15)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _siswaList.remove(siswa));
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
          icon: const Icon(Icons.arrow_back,
              color: AppColors.textPrimary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Data Siswa',
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
                  hintText: 'Cari nama siswa...',
                  hintStyle: AppTextStyle.hint.copyWith(fontSize: 16),
                  prefixIcon: const Icon(Icons.search,
                      size: 26, color: AppColors.textPrimary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // List siswa
            Expanded(
              child: data.isEmpty
                  ? Center(
                      child: Text(
                        'Data siswa tidak ditemukan',
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
                        final siswa = data[i];
                        return _SiswaCard(
                          siswa: siswa,
                          onEdit: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Edit ${siswa.nama} belum tersedia')),
                            );
                          },
                          onDelete: () => _confirmDelete(siswa),
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
      BoxShadow(
        color: Color(0x1F000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );
}

class _SiswaCard extends StatelessWidget {
  final SiswaItem siswa;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SiswaCard({
    required this.siswa,
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
                  siswa.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.headingSmall.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 3),
                Text(
                  siswa.kelas,
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
              color: siswa.aktif
                  ? AppColors.primaryLight
                  : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              siswa.aktif ? 'Aktif' : 'Nonaktif',
              style: AppTextStyle.bodySmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: siswa.aktif ? AppColors.primary : AppColors.error,
              ),
            ),
          ),
          PopupMenuButton<String>(
            padding: const EdgeInsets.all(4),
            icon: const Icon(Icons.more_vert,
                size: 28, color: AppColors.textPrimary),
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
                  style: AppTextStyle.bodyMedium
                      .copyWith(fontSize: 15, color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}