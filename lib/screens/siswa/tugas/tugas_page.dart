import 'package:flutter/material.dart';

import '../../../services/tugas_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';
import '../siswa_home_page.dart';
import 'upload_tugas_page.dart';

enum TugasStatus { aktif, selesai, terlambat }

class _TugasItem {
  final String title;
  final String subject;
  final String startTime;
  final String startDate;
  final String endTime;
  final String endDate;
  final TugasStatus status;

  /// Dipakai untuk pengelompokan di tab Selesai & Terlambat.
  final String month;

  /// Tugas mendesak (judul & jam deadline berwarna merah) di tab Aktif.
  final bool isUrgent;
  final String? publicId;

  const _TugasItem({
    required this.title,
    required this.subject,
    required this.startTime,
    required this.startDate,
    required this.endTime,
    required this.endDate,
    required this.status,
    this.month = 'November 2026',
    this.isUrgent = false,
    this.publicId,
  });

  String get deadline => '$endDate, $endTime';
}

class TugasPage extends StatefulWidget {
  final VoidCallback? onBack;

  const TugasPage({super.key, this.onBack});

  @override
  State<TugasPage> createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  List<_TugasItem> _liveTugas = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _muatTugas();
  }

  Future<void> _muatTugas() async {
    setState(() => _loading = true);
    try {
      final items = await TugasService.instance.ambilDaftarTugas();
      if (items.isNotEmpty) {
        final mapped = items.map((t) {
          final isDone = t.isSubmitted;
          final status = isDone ? TugasStatus.selesai : TugasStatus.aktif;
          final dl = t.deadline;
          final isUrgent = dl.toLowerCase().contains('hari ini') || dl.toLowerCase().contains('besok');
          return _TugasItem(
            title: t.title,
            subject: t.subjectName,
            startTime: '',
            startDate: '',
            endTime: '',
            endDate: t.deadline,
            status: status,
            month: 'Semester Berjalan',
            isUrgent: isUrgent,
            publicId: t.publicId,
          );
        }).toList();
        if (mounted) setState(() => _liveTugas = mapped);
      } else {
        if (mounted) setState(() => _liveTugas = []);
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  static const List<String> _tabs = ['Aktif', 'Selesai', 'Terlambat'];

  int _selectedTab = 0;

  List<_TugasItem> get _filtered {
    final status = TugasStatus.values[_selectedTab];
    return _liveTugas.where((t) => t.status == status).toList();
  }

  /// Kelompokkan tugas per bulan (urutan kemunculan dipertahankan).
  Map<String, List<_TugasItem>> _groupByMonth(List<_TugasItem> items) {
    final map = <String, List<_TugasItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.month, () => []).add(item);
    }
    return map;
  }

  void _openUpload(_TugasItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadTugasPage(
          title: item.title,
          subject: item.subject,
          deadline: item.deadline,
          publicId: item.publicId,
        ),
      ),
    ).then((_) => _muatTugas());
  }

  void _goHome() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SiswaHomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    final isAktif = _selectedTab == 0;

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
                    onTap: _goHome,
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
                  Text('Daftar Tugas', style: AppTextStyle.headingSmall),
                ],
              ),

              const SizedBox(height: 16),

              // Tab filter (Aktif | Selesai | Terlambat)
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_tabs.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == _tabs.length - 1 ? 0 : 10,
                      ),
                      child: _TabChip(
                        label: _tabs[index],
                        selected: index == _selectedTab,
                        onTap: () => setState(() => _selectedTab = index),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),

              // List tugas
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  'Belum ada tugas ${isAktif ? "aktif" : _tabs[_selectedTab].toLowerCase()}',
                                  style: AppTextStyle.bodyMedium.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        : isAktif
                            ? _buildFlatList(items)
                            : _buildGroupedList(items),
              ),
            ],
          ),
        ),
      ),

    );
  }

  // Tab Aktif: daftar biasa tanpa pengelompokan bulan.
  Widget _buildFlatList(List<_TugasItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16, top: 2),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _TugasCard(item: item, onTap: () => _openUpload(item));
      },
    );
  }

  // Tab Selesai & Terlambat: dikelompokkan per bulan dengan badge status.
  Widget _buildGroupedList(List<_TugasItem> items) {
    final groups = _groupByMonth(items);

    return ListView(
      padding: const EdgeInsets.only(bottom: 16, top: 2),
      children: [
        for (final entry in groups.entries) ...[
          Center(
            child: Text(
              entry.key,
              style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          for (final item in entry.value) ...[
            _TugasCard(
              item: item,
              showBadge: true,
              onTap: () => _openUpload(item),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
        ],
      ],
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
      elevation: selected ? 0 : 3,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 28,
          constraints: const BoxConstraints(minWidth: 64),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyle.bodySmall.copyWith(
              fontSize: 11,
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
  final bool showBadge;

  const _TugasCard({
    required this.item,
    required this.onTap,
    this.showBadge = false,
  });

  static const Color _red = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final urgentColor = item.isUrgent ? Colors.red : AppColors.textPrimary;

    return Material(
      color: AppColors.white,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.description,
                  size: 28,
                  color: Color(0xFF60A5FA),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul + badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.headingSmall.copyWith(
                              fontSize: 12,
                              color: urgentColor,
                            ),
                          ),
                        ),
                        if (showBadge) _StatusBadge(status: item.status),
                      ],
                    ),
                    Text(
                      item.subject,
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 8,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Waktu mulai -> waktu deadline
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: _TimeBlock(
                            time: item.startTime,
                            date: item.startDate,
                          ),
                        ),
                        const Expanded(
                          flex: 3,
                          child: Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: _TimeBlock(
                            time: item.endTime,
                            date: item.endDate,
                            color: item.isUrgent ? _red : null,
                          ),
                        ),
                      ],
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

class _TimeBlock extends StatelessWidget {
  final String time;
  final String date;
  final Color? color;

  const _TimeBlock({required this.time, required this.date, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: AppTextStyle.bodySmall.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: c,
          ),
        ),
        Text(
          date,
          style: AppTextStyle.bodySmall.copyWith(
            fontSize: 7,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TugasStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isSelesai = status == TugasStatus.selesai;
    final bg = isSelesai ? const Color(0xFFD1F5DC) : const Color(0xFFFFD9D9);
    final fg = isSelesai ? const Color(0xFF219653) : const Color(0xFFEF4444);
    final label = isSelesai ? 'Selesai' : 'Terlambat';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}