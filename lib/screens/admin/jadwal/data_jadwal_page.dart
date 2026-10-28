import 'package:flutter/material.dart';

import '../../../models/jadwal_model.dart';
import '../../../services/jadwal_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';
import 'tambah_jadwal_page.dart';

class DataJadwalPage extends StatefulWidget {
  const DataJadwalPage({super.key});

  @override
  State<DataJadwalPage> createState() => _DataJadwalPageState();
}

class _DataJadwalPageState extends State<DataJadwalPage> {
  String _tahunAjaran = JadwalService.tahunAjaranTersedia.first;
  Semester _semester = Semester.ganjil;
  String _kelas = JadwalService.daftarKelas.first;
  HariSekolah _hari = HariSekolah.senin;

  Future<void> _openForm({JadwalPelajaran? jadwal}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahJadwalPage(
          tahunAjaran: _tahunAjaran,
          semester: _semester,
          kelas: _kelas,
          hari: _hari,
          jadwal: jadwal,
        ),
      ),
    );
    if (saved == true && mounted) setState(() {});
  }

  Future<void> _salinHari() async {
    final targetDay = await showDialog<HariSekolah>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(
          'Salin jadwal ${_hari.label} ke',
          style: AppTextStyle.headingSmall,
        ),
        children: HariSekolah.values
            .where((hari) => hari != _hari)
            .map(
              (hari) => SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, hari),
                child: Text(hari.label),
              ),
            )
            .toList(),
      ),
    );
    if (targetDay == null || !mounted) return;

    final result = JadwalService.instance.salinHari(
      tahunAjaran: _tahunAjaran,
      semester: _semester,
      kelas: _kelas,
      dariHari: _hari,
      keHari: targetDay,
    );
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.dilewati == 0
              ? '${result.tersalin} jadwal disalin ke ${targetDay.label}.'
              : '${result.tersalin} jadwal disalin; ${result.dilewati} dilewati karena bentrok.',
        ),
      ),
    );
  }

  Future<void> _hapusJadwal(JadwalPelajaran jadwal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Hapus Jadwal?', style: AppTextStyle.headingSmall),
        content: Text(
          '${jadwal.mataPelajaran} · ${formatMenit(jadwal.mulaiMenit)} di kelas ${jadwal.kelas}',
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
    if (confirmed != true || !mounted) return;

    JadwalService.instance.hapus(jadwal.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final entries = JadwalService.instance.jadwalKelas(
      tahunAjaran: _tahunAjaran,
      semester: _semester,
      kelas: _kelas,
      hari: _hari,
    );
    final dayCount = JadwalService.instance
        .jadwalKelas(
          tahunAjaran: _tahunAjaran,
          semester: _semester,
          kelas: _kelas,
          hari: _hari,
        )
        .length;

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
          'Jadwal',
          style: AppTextStyle.headingSmall.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            tooltip: 'Salin jadwal hari',
            onPressed: entries.isEmpty ? null : _salinHari,
            icon: const Icon(Icons.copy_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _Selector<String>(
                        label: 'Tahun ajaran',
                        value: _tahunAjaran,
                        items: JadwalService.tahunAjaranTersedia,
                        onChanged: (value) =>
                            setState(() => _tahunAjaran = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _Selector<Semester>(
                        label: 'Semester',
                        value: _semester,
                        items: Semester.values,
                        itemLabel: (value) => value.label,
                        onChanged: (value) =>
                            setState(() => _semester = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Selector<String>(
                  label: 'Kelas',
                  value: _kelas,
                  items: JadwalService.daftarKelas,
                  onChanged: (value) => setState(() => _kelas = value!),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: HariSekolah.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final hari = HariSekolah.values[index];
                return ChoiceChip(
                  label: Text(hari.label),
                  selected: _hari == hari,
                  onSelected: (_) => setState(() => _hari = hari),
                  selectedColor: AppColors.primaryLight,
                  labelStyle: TextStyle(
                    color: _hari == hari
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                    fontWeight: _hari == hari
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  side: BorderSide.none,
                  showCheckmark: false,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_hari.label} · $dayCount jadwal',
                    style: AppTextStyle.headingSmall.copyWith(fontSize: 16),
                  ),
                ),
                TextButton.icon(
                  onPressed: _salinHari,
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  label: const Text('Salin hari'),
                ),
              ],
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? _EmptySchedule(hari: _hari, onAdd: () => _openForm())
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _ScheduleCard(
                      jadwal: entries[index],
                      onEdit: () => _openForm(jadwal: entries[index]),
                      onDelete: () => _hapusJadwal(entries[index]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Jadwal'),
      ),
    );
  }
}

class _Selector<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T)? itemLabel;
  final ValueChanged<T?> onChanged;

  const _Selector({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabel,
  });

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        onChanged: onChanged,
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabel?.call(item) ?? item.toString(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
      ),
    ),
  );
}

class _ScheduleCard extends StatelessWidget {
  final JadwalPelajaran jadwal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.jadwal,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 5,
          height: 62,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            '${formatMenit(jadwal.mulaiMenit)}\n${formatMenit(jadwal.selesaiMenit)}',
            style: AppTextStyle.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jadwal.mataPelajaran,
                style: AppTextStyle.headingSmall.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                '${jadwal.guru} · ${jadwal.ruang}',
                style: AppTextStyle.bodySmall.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Hapus')),
          ],
        ),
      ],
    ),
  );
}

class _EmptySchedule extends StatelessWidget {
  final HariSekolah hari;
  final VoidCallback onAdd;

  const _EmptySchedule({required this.hari, required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_note_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada jadwal untuk ${hari.label.toLowerCase()}.',
            textAlign: TextAlign.center,
            style: AppTextStyle.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Tambah pelajaran'),
          ),
        ],
      ),
    ),
  );
}
