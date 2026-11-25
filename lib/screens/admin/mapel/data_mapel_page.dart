import 'package:flutter/material.dart';

import '../../../models/mapel_model.dart';
import '../../../services/master_data_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';
import 'tambah_mapel_page.dart';

class DataMapelPage extends StatefulWidget {
  const DataMapelPage({super.key});

  @override
  State<DataMapelPage> createState() => _DataMapelPageState();
}

class _DataMapelPageState extends State<DataMapelPage> {
  List<MapelItem> _mapelList = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _fetchMapel();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMapel() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final items = await MasterDataService.instance.fetchMapel();
      if (!mounted) return;
      setState(() {
        _mapelList = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<MapelItem> get _filtered => _mapelList.where((mapel) {
    final keyword = _keyword.trim().toLowerCase();
    return mapel.nama.toLowerCase().contains(keyword) ||
        mapel.kode.toLowerCase().contains(keyword) ||
        mapel.kelompok.toLowerCase().contains(keyword);
  }).toList();

  Future<void> _openForm({MapelItem? mapel}) async {
    final result = await Navigator.push<MapelItem>(
      context,
      MaterialPageRoute(builder: (_) => TambahMapelPage(mapel: mapel)),
    );
    if (!mounted || result == null) return;

    try {
      if (mapel == null) {
        await MasterDataService.instance.createMapel(result);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mata pelajaran berhasil ditambahkan')),
        );
      } else if (mapel.id != null) {
        await MasterDataService.instance.updateMapel(mapel.id!, result);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mata pelajaran berhasil diperbarui')),
        );
      }
      _fetchMapel();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmDelete(MapelItem mapel) async {
    final hapus = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Hapus Mata Pelajaran', style: AppTextStyle.headingSmall),
        content: Text(
          'Yakin ingin menghapus ${mapel.nama}?',
          style: AppTextStyle.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (hapus == true && mounted && mapel.id != null) {
      try {
        await MasterDataService.instance.deleteMapel(mapel.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mata pelajaran berhasil dihapus')),
        );
        _fetchMapel();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleAction(MapelItem mapel, String action) {
    switch (action) {
      case 'edit':
        _openForm(mapel: mapel);
      case 'status':
        setState(() {
          final index = _mapelList.indexOf(mapel);
          if (index != -1)
            _mapelList[index] = mapel.copyWith(aktif: !mapel.aktif);
        });
      case 'delete':
        _confirmDelete(mapel);
    }
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
          'Mata Pelajaran',
          style: AppTextStyle.headingSmall.copyWith(fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () => _openForm(),
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
            Container(
              height: 54,
              decoration: _cardDecoration(radius: 12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _keyword = value),
                style: AppTextStyle.bodyLarge.copyWith(fontSize: 16),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Cari mata pelajaran...',
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: AppTextStyle.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _fetchMapel,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                  : data.isEmpty
                  ? Center(
                      child: Text(
                        'Mata pelajaran tidak ditemukan',
                        style: AppTextStyle.bodyMedium.copyWith(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchMapel,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: data.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final mapel = data[index];
                          return _MapelCard(
                            mapel: mapel,
                            onAction: (action) => _handleAction(mapel, action),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapelCard extends StatelessWidget {
  final MapelItem mapel;
  final ValueChanged<String> onAction;

  const _MapelCard({required this.mapel, required this.onAction});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    decoration: _cardDecoration(),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.description,
            size: 28,
            color: Color(0xFF777777),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mapel.nama,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.headingSmall.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 3),
              Text(
                '${mapel.kode} · ${mapel.kelompok}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _StatusBadge(aktif: mapel.aktif),
        PopupMenuButton<String>(
          onSelected: onAction,
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: 'status',
              child: Text(mapel.aktif ? 'Nonaktifkan' : 'Aktifkan'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Hapus')),
          ],
        ),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final bool aktif;

  const _StatusBadge({required this.aktif});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: aktif ? AppColors.primaryLight : const Color(0xFFFEE2E2),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      aktif ? 'Aktif' : 'Nonaktif',
      style: AppTextStyle.bodySmall.copyWith(
        color: aktif ? AppColors.primaryDark : AppColors.error,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

BoxDecoration _cardDecoration({double radius = 14}) => BoxDecoration(
  color: AppColors.white,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: const [
    BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 2)),
  ],
);
