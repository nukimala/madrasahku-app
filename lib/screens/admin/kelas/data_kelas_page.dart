import 'package:flutter/material.dart';

import '../../../models/kelas_model.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';
import 'tambah_kelas_page.dart';

class DataKelasPage extends StatefulWidget {
  const DataKelasPage({super.key});

  @override
  State<DataKelasPage> createState() => _DataKelasPageState();
}

class _DataKelasPageState extends State<DataKelasPage> {
  static final List<KelasItem> _kelasList = [
    const KelasItem(
      nama: '7',
      tingkat: '7',
      waliKelas: null,
      tahunAjaran: '2026/2027',
    ),
    const KelasItem(
      nama: '8A',
      tingkat: '8',
      waliKelas: null,
      tahunAjaran: '2026/2027',
    ),
    const KelasItem(
      nama: '8B',
      tingkat: '8',
      waliKelas: null,
      tahunAjaran: '2026/2027',
    ),
    const KelasItem(
      nama: '8C',
      tingkat: '8',
      waliKelas: null,
      tahunAjaran: '2026/2027',
    ),
    const KelasItem(
      nama: '9A',
      tingkat: '9',
      waliKelas: null,
      tahunAjaran: '2026/2027',
    ),
    const KelasItem(
      nama: '9B',
      tingkat: '9',
      waliKelas: null,
      tahunAjaran: '2026/2027',
    ),
    const KelasItem(
      nama: '9C',
      tingkat: '9',
      waliKelas: null,
      tahunAjaran: '2026/2027',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';
  String _selectedTingkat = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<KelasItem> get _filtered => _kelasList
      .where(
        (kelas) =>
            kelas.nama.toLowerCase().contains(_keyword.trim().toLowerCase()) &&
            (_selectedTingkat == 'Semua' ||
                kelas.tingkat == _selectedTingkat),
      )
      .toList();

  Future<void> _openForm({KelasItem? kelas}) async {
    final result = await Navigator.push<KelasItem>(
      context,
      MaterialPageRoute(builder: (_) => TambahKelasPage(kelas: kelas)),
    );
    if (!mounted || result == null) return;

    setState(() {
      if (kelas == null) {
        _kelasList.add(result);
      } else {
        final index = _kelasList.indexOf(kelas);
        if (index != -1) _kelasList[index] = result;
      }
    });
  }

  Future<void> _confirmDelete(KelasItem kelas) async {
    final hapus = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Hapus Kelas', style: AppTextStyle.headingSmall),
        content: Text(
          'Yakin ingin menghapus kelas ${kelas.nama}?',
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
    if (hapus == true && mounted) setState(() => _kelasList.remove(kelas));
  }

  void _handleAction(KelasItem kelas, String action) {
    switch (action) {
      case 'edit':
        _openForm(kelas: kelas);
      case 'delete':
        _confirmDelete(kelas);
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
          'Data Kelas',
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
            Row(
              children: [
                Expanded(
                  child: _SearchField(
                    controller: _searchController,
                    hint: 'Cari nama kelas...',
                    onChanged: (value) => setState(() => _keyword = value),
                  ),
                ),
                const SizedBox(width: 12),
                _TingkatFilter(
                  value: _selectedTingkat,
                  onChanged: (value) =>
                      setState(() => _selectedTingkat = value),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: data.isEmpty
                  ? Center(
                      child: Text(
                        'Data kelas tidak ditemukan',
                        style: AppTextStyle.bodyMedium.copyWith(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: data.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final kelas = data[index];
                        return _KelasCard(
                          kelas: kelas,
                          onAction: (action) => _handleAction(kelas, action),
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

class _KelasCard extends StatelessWidget {
  final KelasItem kelas;
  final ValueChanged<String> onAction;

  const _KelasCard({required this.kelas, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const _DocumentIcon(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kelas.nama,
                  style: AppTextStyle.headingSmall.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 3),
                Text(
                  'Tingkat ${kelas.tingkat}',
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Wali: ${kelas.waliKelas ?? 'Belum ditentukan'} · ${kelas.tahunAjaran}',
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
          PopupMenuButton<String>(
            onSelected: onAction,
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 54,
    decoration: _cardDecoration(radius: 12),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyle.bodyLarge.copyWith(fontSize: 16),
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: hint,
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
  );
}

class _DocumentIcon extends StatelessWidget {
  const _DocumentIcon();

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: const BoxDecoration(
      color: Color(0xFFE5E7EB),
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.description, size: 28, color: Color(0xFF777777)),
  );
}

class _TingkatFilter extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _TingkatFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    height: 54,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: _cardDecoration(radius: 12),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        key: const ValueKey('filter-tingkat'),
        value: value,
        borderRadius: BorderRadius.circular(12),
        items: const ['Semua', '7', '8', '9']
            .map(
              (tingkat) => DropdownMenuItem(
                key: ValueKey('filter-tingkat-$tingkat'),
                value: tingkat,
                child: Text(tingkat == 'Semua' ? 'Semua' : 'Tingkat $tingkat'),
              ),
            )
            .toList(),
        onChanged: (tingkat) {
          if (tingkat != null) onChanged(tingkat);
        },
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
