import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../models/jadwal_model.dart';
import '../../../services/jadwal_excel_importer.dart';
import '../../../services/jadwal_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';
import 'pratinjau_impor_jadwal_page.dart';
import 'tambah_jadwal_page.dart';

enum _TampilanJadwal { daftar, mingguan }

class DataJadwalPage extends StatefulWidget {
  const DataJadwalPage({super.key});

  @override
  State<DataJadwalPage> createState() => _DataJadwalPageState();
}

class _DataJadwalPageState extends State<DataJadwalPage> {
  final _searchController = TextEditingController();
  String _tahunAjaran = JadwalService.tahunAjaranTersedia.first;
  Semester _semester = Semester.ganjil;
  HariSekolah? _filterHari;
  String? _filterKelas;
  _TampilanJadwal _tampilan = _TampilanJadwal.daftar;
  bool _isDeletingAll = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({JadwalPelajaran? jadwal}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahJadwalPage(
          tahunAjaran: _tahunAjaran,
          semester: _semester,
          kelas: jadwal?.kelas ?? _filterKelas,
          hari: jadwal?.hari ?? _filterHari ?? HariSekolah.senin,
          jadwal: jadwal,
        ),
      ),
    );
    if (saved == true && mounted) setState(() {});
  }

  Future<void> _tambahTahunAjaran() async {
    final formKey = GlobalKey<FormState>();
    var inputTahunAjaran = '';
    final tahunAjaran = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text('Tambah tahun ajaran', style: AppTextStyle.headingSmall),
        content: Form(
          key: formKey,
          child: TextFormField(
            autofocus: true,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Tahun ajaran',
              hintText: '2028/2029',
              helperText: 'Masukkan dua tahun berurutan.',
            ),
            onChanged: (value) => inputTahunAjaran = value,
            validator: (value) {
              final normalized = value?.trim() ?? '';
              final match = RegExp(r'^(\d{4})/(\d{4})$').firstMatch(normalized);
              if (match == null) {
                return 'Gunakan format YYYY/YYYY.';
              }
              final start = int.parse(match.group(1)!);
              final end = int.parse(match.group(2)!);
              if (end != start + 1) {
                return 'Tahun harus berurutan, misalnya 2028/2029.';
              }
              if (JadwalService.instance.daftarTahunAjaran.contains(
                normalized,
              )) {
                return 'Tahun ajaran tersebut sudah tersedia.';
              }
              return null;
            },
            onFieldSubmitted: (_) {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, inputTahunAjaran.trim());
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, inputTahunAjaran.trim());
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
    if (tahunAjaran == null || !mounted) return;

    try {
      final added = await JadwalService.instance.tambahTahunAjaran(tahunAjaran);
      if (!mounted) return;
      if (!added) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tahun ajaran tersebut sudah tersedia.'),
          ),
        );
        return;
      }
      setState(() => _tahunAjaran = tahunAjaran);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tahun ajaran $tahunAjaran berhasil ditambahkan.'),
        ),
      );
    } on FormatException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tahun ajaran tidak valid: ${error.message}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tahun ajaran gagal disimpan: $error')),
      );
    }
  }

  Future<void> _pilihFileExcel() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
      );
      if (file == null || !mounted) return;

      final bytes = await file.readAsBytes();
      final parsed = JadwalExcelImporter.parse(bytes);
      if (!mounted) return;

      final imported = await Navigator.push<int>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PratinjauImporJadwalPage(hasil: parsed, namaFile: file.name),
        ),
      );
      if (imported == null || !mounted) return;
      setState(() {
        _tahunAjaran = parsed.tahunAjaran;
        _semester = parsed.semester;
        _filterHari = null;
        _filterKelas = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$imported jadwal berhasil diimpor.')),
      );
    } on FormatException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Format file tidak sesuai: ${error.message}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File jadwal gagal dibuka: $error')),
      );
    }
  }

  Future<void> _hapusJadwal(JadwalPelajaran jadwal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text('Hapus jadwal?', style: AppTextStyle.headingSmall),
        content: Text(
          '${jadwal.mataPelajaran} · ${jadwal.hari.label} · '
          '${jadwal.tampilanWaktu}',
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

    try {
      await JadwalService.instance.hapus(jadwal.id);
      if (mounted) setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Jadwal gagal dihapus: $error')));
    }
  }

  Future<void> _hapusSemuaJadwal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text('Hapus semua jadwal?', style: AppTextStyle.headingSmall),
        content: const Text(
          'Semua jadwal dari seluruh tahun ajaran dan semester akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Hapus semua',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeletingAll = true);
    try {
      final deleted = await JadwalService.instance.hapusSemua();
      if (!mounted) return;
      setState(() {
        _isDeletingAll = false;
        _filterHari = null;
        _filterKelas = null;
        _searchController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$deleted jadwal berhasil dihapus.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isDeletingAll = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Jadwal gagal dihapus: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedules = JadwalService.instance.semuaJadwal(
      tahunAjaran: _tahunAjaran,
      semester: _semester,
    );
    final classes =
        schedules
            .map((item) => item.kelas)
            .whereType<String>()
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final filtered = schedules.where((item) {
      if (_filterHari != null && item.hari != _filterHari) return false;
      if (_filterKelas != null && item.kelas != _filterKelas) return false;
      final query = _searchController.text.trim().toLowerCase();
      return query.isEmpty ||
          item.mataPelajaran.toLowerCase().contains(query) ||
          item.guru.toLowerCase().contains(query) ||
          (item.kodeMapel?.toLowerCase().contains(query) ?? false) ||
          (item.kelas?.toLowerCase().contains(query) ?? false);
    }).toList();
    final days = filtered.map((item) => item.hari).toSet();
    final subjects = filtered.map((item) => item.mataPelajaran).toSet();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
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
          TextButton.icon(
            onPressed: _pilihFileExcel,
            icon: const Icon(Icons.upload_file_outlined, size: 18),
            label: const Text('Impor'),
          ),
          if (JadwalService.instance.jumlahJadwalTersimpan > 0)
            IconButton(
              tooltip: 'Hapus semua jadwal',
              onPressed: _isDeletingAll ? null : _hapusSemuaJadwal,
              icon: _isDeletingAll
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_sweep_outlined),
            ),
          IconButton(
            tooltip: 'Tambah jadwal',
            onPressed: _openForm,
            icon: const Icon(Icons.add_circle_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Atur dan tinjau jadwal pelajaran',
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _Selector<String>(
                        label: 'Tahun ajaran',
                        value: _tahunAjaran,
                        items: JadwalService.instance.daftarTahunAjaran,
                        onChanged: (value) => setState(() {
                          _tahunAjaran = value!;
                          _filterKelas = null;
                        }),
                        trailing: IconButton(
                          tooltip: 'Tambah tahun ajaran',
                          onPressed: _tambahTahunAjaran,
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
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
                        onChanged: (value) => setState(() {
                          _semester = value!;
                          _filterKelas = null;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Statistic(count: '${filtered.length}', label: 'jadwal'),
                    const SizedBox(width: 18),
                    _Statistic(count: '${days.length}', label: 'hari'),
                    const SizedBox(width: 18),
                    _Statistic(count: '${subjects.length}', label: 'mapel'),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari mata pelajaran atau guru',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Hapus pencarian',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _FilterDropdown<HariSekolah?>(
                        value: _filterHari,
                        label: _filterHari?.label ?? 'Semua hari',
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Semua hari'),
                          ),
                          ...HariSekolah.values.map(
                            (hari) => DropdownMenuItem(
                              value: hari,
                              child: Text(hari.label),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _filterHari = value),
                      ),
                    ),
                    if (classes.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FilterDropdown<String?>(
                          value: _filterKelas,
                          label: _filterKelas ?? 'Semua kelas',
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Semua kelas'),
                            ),
                            ...classes.map(
                              (kelas) => DropdownMenuItem(
                                value: kelas,
                                child: Text(kelas),
                              ),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _filterKelas = value),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    SegmentedButton<_TampilanJadwal>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: _TampilanJadwal.daftar,
                          icon: Icon(Icons.view_agenda_outlined, size: 18),
                        ),
                        ButtonSegment(
                          value: _TampilanJadwal.mingguan,
                          icon: Icon(
                            Icons.calendar_view_week_outlined,
                            size: 18,
                          ),
                        ),
                      ],
                      selected: {_tampilan},
                      onSelectionChanged: (value) =>
                          setState(() => _tampilan = value.first),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _EmptySchedule(
                    hasSchedules: schedules.isNotEmpty,
                    onImport: _pilihFileExcel,
                    onAdd: _openForm,
                  )
                : _tampilan == _TampilanJadwal.daftar
                ? _ScheduleList(
                    schedules: filtered,
                    onEdit: (jadwal) => _openForm(jadwal: jadwal),
                    onDelete: _hapusJadwal,
                  )
                : _WeeklySchedule(
                    schedules: filtered,
                    onEdit: (jadwal) => _openForm(jadwal: jadwal),
                    onDelete: _hapusJadwal,
                  ),
          ),
        ],
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
  final Widget? trailing;

  const _Selector({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabel,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: Row(
      children: [
        Expanded(
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
        ),
        ?trailing,
      ],
    ),
  );
}

class _FilterDropdown<T> extends StatelessWidget {
  final T value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        onChanged: onChanged,
        items: items,
        selectedItemBuilder: (_) => items
            .map(
              (item) => Align(
                alignment: Alignment.centerLeft,
                child: Text(label, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
      ),
    ),
  );
}

class _Statistic extends StatelessWidget {
  final String count;
  final String label;

  const _Statistic({required this.count, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        count,
        style: AppTextStyle.headingSmall.copyWith(
          color: AppColors.primaryDark,
          fontSize: 16,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    ],
  );
}

class _ScheduleList extends StatelessWidget {
  final List<JadwalPelajaran> schedules;
  final ValueChanged<JadwalPelajaran> onEdit;
  final ValueChanged<JadwalPelajaran> onDelete;

  const _ScheduleList({
    required this.schedules,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
    children: [
      for (final day in HariSekolah.values)
        if (schedules.any((item) => item.hari == day)) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
            child: Text(
              '${day.label.toUpperCase()} · '
              '${schedules.where((item) => item.hari == day).length} jadwal',
              style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
            ),
          ),
          ...schedules
              .where((item) => item.hari == day)
              .map(
                (item) => _ScheduleCard(
                  jadwal: item,
                  onEdit: () => onEdit(item),
                  onDelete: () => onDelete(item),
                ),
              ),
        ],
    ],
  );
}

class _WeeklySchedule extends StatelessWidget {
  final List<JadwalPelajaran> schedules;
  final ValueChanged<JadwalPelajaran> onEdit;
  final ValueChanged<JadwalPelajaran> onDelete;

  const _WeeklySchedule({
    required this.schedules,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final day in HariSekolah.values)
            if (schedules.any((item) => item.hari == day))
              SizedBox(
                width: 270,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
                        child: Text(
                          day.label,
                          style: AppTextStyle.headingSmall.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      for (final item in schedules.where(
                        (item) => item.hari == day,
                      ))
                        _ScheduleCard(
                          jadwal: item,
                          onEdit: () => onEdit(item),
                          onDelete: () => onDelete(item),
                        ),
                    ],
                  ),
                ),
              ),
        ],
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
    margin: const EdgeInsets.only(bottom: 9),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 68,
          child: Text(
            jadwal.tampilanWaktu,
            style: AppTextStyle.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
              ),
              if (jadwal.kodeMapel != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Kode ${jadwal.kodeMapel}',
                  style: AppTextStyle.bodySmall.copyWith(fontSize: 10),
                ),
              ],
              const SizedBox(height: 3),
              Text(
                [
                  jadwal.guru,
                  if (jadwal.tampilanLokasi.isNotEmpty) jadwal.tampilanLokasi,
                ].join(' · '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          padding: EdgeInsets.zero,
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
  final bool hasSchedules;
  final VoidCallback onImport;
  final VoidCallback onAdd;

  const _EmptySchedule({
    required this.hasSchedules,
    required this.onImport,
    required this.onAdd,
  });

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
            hasSchedules
                ? 'Tidak ada jadwal yang cocok dengan pencarian atau filter.'
                : 'Belum ada jadwal untuk periode ini.',
            textAlign: TextAlign.center,
            style: AppTextStyle.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (!hasSchedules) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: onImport,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Impor Excel'),
                ),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah jadwal'),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}
