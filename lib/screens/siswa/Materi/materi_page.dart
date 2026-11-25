import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../services/jadwal_service.dart';
import '../../../services/master_data_service.dart';
import '../../../services/materi_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';
import 'detail_materi_page.dart';
import '../tugas/upload_tugas_page.dart';

class MateriPage extends StatefulWidget {
  final VoidCallback? onBack;
  final int refreshTick;

  const MateriPage({
    super.key,
    this.onBack,
    this.refreshTick = 0,
  });

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  // Ambil kelas dari akun siswa yang sedang login (fallback ke 'Kelas VII' kalau kosong)
  String _kelas = 'Kelas VII';

  // Daftar mata pelajaran diisi dinamis dari jadwal/database server
  List<String> _mapelList = [];

  // Data materi dari database server API (disimpan per mapel)
  final Map<String, List<_Topik>> _data = {};

  String _selectedMapel = '';
  String _query = '';
  final Set<int> _expanded = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _muatDataDanMateri();
  }

  @override
  void didUpdateWidget(covariant MateriPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTick != widget.refreshTick && !_loading) {
      _muatDataDanMateri();
    }
  }

  Future<void> _muatDataDanMateri() async {
    setState(() => _loading = true);
    try {
      final auth = AuthService.instance;
      if (auth.currentRole == 'siswa') {
        _kelas = auth.currentStudentClassName ?? 'Kelas Siswa';
      }

      // 1. Ambil daftar mata pelajaran kelas siswa dari jadwal live
      final Set<String> mapelSet = {};
      try {
        final jadwal = await JadwalService.instance.ambilJadwalApi();
        for (final j in jadwal) {
          if (j.mataPelajaran.trim().isNotEmpty) {
            mapelSet.add(j.mataPelajaran.trim());
          }
        }
      } catch (_) {}

      // Fallback ke master mata pelajaran jika jadwal belum ada
      if (mapelSet.isEmpty) {
        try {
          final masterMapel = await MasterDataService.instance.fetchMapel();
          for (final m in masterMapel) {
            if (m.nama.trim().isNotEmpty) {
              mapelSet.add(m.nama.trim());
            }
          }
        } catch (_) {}
      }

      // 2. Ambil daftar materi dari API (filter by classId siswa)
      final classId = auth.currentStudentClassId;
      final items = await MateriService.instance.ambilDaftarMateri(classId: classId);

      final Map<String, List<_Topik>> tempData = {};
      for (final item in items) {
        final mapel = item.subjectName.isNotEmpty ? item.subjectName : 'Umum';
        mapelSet.add(mapel);

        final topiks = tempData.putIfAbsent(mapel, () => []);
        final topicName = (item.topicNama != null && item.topicNama!.isNotEmpty)
            ? (item.topicMinggu != null
                ? 'Minggu ${item.topicMinggu} - ${item.topicNama}'
                : item.topicNama!)
            : (item.title.isNotEmpty ? item.title : 'Materi Pembelajaran');

        var existing = topiks.where((t) => t.title == topicName).toList();
        _Topik t;
        if (existing.isEmpty) {
          t = _Topik(topicName, []);
          topiks.add(t);
        } else {
          t = existing.first;
        }

        t.items.add(_Item(
          item.title,
          item.description ?? 'Silakan pelajari materi berikut',
          _Status.lanjutkan,
          isTugas: false,
          badge: null,
          fileUrl: item.fileUrl,
        ));
      }

      if (mounted) {
        final sortedMapel = mapelSet.toList()..sort();
        setState(() {
          _data.clear();
          _data.addAll(tempData);
          _mapelList = sortedMapel;
          if (_mapelList.isNotEmpty && !_mapelList.contains(_selectedMapel)) {
            _selectedMapel = _mapelList.first;
          }
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<_Topik> get _topikList {
    final all = _data[_selectedMapel] ?? const <_Topik>[];
    final q = _query.trim().toLowerCase();

    if (q.isEmpty) return all;

    return all
        .where((topik) =>
            topik.title.toLowerCase().contains(q) ||
            topik.items.any((item) => item.title.toLowerCase().contains(q)))
        .toList();
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.maybePop(context);
    }
  }

  Future<void> _openDetail(_Topik topik, _Item item) async {
    final selesai = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailMateriPage(
          judul: item.title,
          mapel: _selectedMapel,
          kelas: _kelas,
          deskripsi: item.subtitle,
          fileUrl: item.fileUrl,
        ),
      ),
    );

    if (selesai == true && !item.isTugas && mounted) {
      setState(() => item.status = _Status.selesai);
    }
  }

  void _openUploadTugas(_Item item) {
    final deadline = item.subtitle.startsWith('Deadline: ')
        ? item.subtitle.replaceFirst('Deadline: ', '')
        : 'Belum ditentukan';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadTugasPage(
          title: item.title,
          subject: _selectedMapel,
          deadline: deadline,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topikList = _topikList;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _handleBack,
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

            // Pencarian dan filter mata pelajaran.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      height: 38,
                      decoration: _boxDecoration(),
                      child: TextField(
                        onChanged: (value) => setState(() => _query = value),
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
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 9),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: _boxDecoration(),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _mapelList.contains(_selectedMapel)
                              ? _selectedMapel
                              : null,
                          hint: const Text('Pilih Mapel'),
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
                          items: _mapelList
                              .map(
                                (mapel) => DropdownMenuItem(
                                  value: mapel,
                                  child: Text(
                                    mapel,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedMapel = value;
                              _expanded.clear();
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Daftar topik (accordion).
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : topikList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.menu_book_outlined, size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            _query.isEmpty
                                ? 'Belum ada materi pembelajaran untuk $_selectedMapel'
                                : 'Materi "$_query" tidak ditemukan',
                            textAlign: TextAlign.center,
                            style: AppTextStyle.bodySmall,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: topikList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final topik = topikList[index];
                        final open = _expanded.contains(index);

                        return _TopikCard(
                          topik: topik,
                          expanded: open,
                          onToggle: () => setState(() {
                            if (open) {
                              _expanded.remove(index);
                            } else {
                              _expanded.add(index);
                            }
                          }),
                          onItemTap: (item) => _openDetail(topik, item),
                          onKumpulkan: _openUploadTugas,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // Bottom navigation dikelola oleh SiswaHomePage.
    );
  }

  static BoxDecoration _boxDecoration() => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      );
}

enum _Status { selesai, lanjutkan, sisa }

class _Topik {
  final String title;
  final List<_Item> items;

  _Topik(this.title, this.items);
}

class _Item {
  final String title;
  final String subtitle;
  final bool isTugas;
  final String? badge;
  final String? fileUrl;
  _Status status;

  _Item(
    this.title,
    this.subtitle,
    this.status, {
    this.isTugas = false,
    this.badge,
    this.fileUrl,
  });
}

class _TopikCard extends StatelessWidget {
  final _Topik topik;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<_Item> onItemTap;
  final ValueChanged<_Item> onKumpulkan;

  const _TopikCard({
    required this.topik,
    required this.expanded,
    required this.onToggle,
    required this.onItemTap,
    required this.onKumpulkan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1EDED),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Topik',
                          style: AppTextStyle.bodySmall.copyWith(
                            fontSize: 10,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          topik.title,
                          style:
                              AppTextStyle.headingSmall.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
          ),
          if (expanded && topik.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < topik.items.length; i++) ...[
                      if (i > 0) const SizedBox(height: 6),
                      _ItemTile(
                        item: topik.items[i],
                        onTap: () => onItemTap(topik.items[i]),
                        onKumpulkan: () => onKumpulkan(topik.items[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final _Item item;
  final VoidCallback onTap;
  final VoidCallback onKumpulkan;

  const _ItemTile({
    required this.item,
    required this.onTap,
    required this.onKumpulkan,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.isTugas ? onKumpulkan : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.description,
              size: 28,
              color: item.isTugas
                  ? const Color(0xFF4F8EF7)
                  : const Color(0xFF219653),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyle.headingSmall.copyWith(fontSize: 12),
                  ),
                  if (item.subtitle.isNotEmpty)
                    Text(
                      item.subtitle,
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 8,
                        color: AppColors.textPrimary,
                      ),
                    ),
                ],
              ),
            ),
            _statusWidget(),
          ],
        ),
      ),
    );
  }

  Widget _statusWidget() {
    switch (item.status) {
      case _Status.selesai:
        return const _Chip(
          'Selesai',
          bg: Color(0xFFD1F2DC),
          fg: Color(0xFF219653),
        );
      case _Status.lanjutkan:
        return const _Chip(
          'Lanjutkan',
          bg: Color(0xFF219653),
          fg: Colors.white,
        );
      case _Status.sisa:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Chip(
              item.badge ?? 'Sisa waktu',
              bg: const Color(0xFFFAD4D4),
              fg: const Color(0xFFD32F2F),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: onKumpulkan,
              child: const _Chip(
                'Kumpulkan Tugas',
                bg: Color(0xFF219653),
                fg: Colors.white,
              ),
            ),
          ],
        );
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Chip(
    this.label, {
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
