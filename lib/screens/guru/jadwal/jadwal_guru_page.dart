import 'package:flutter/material.dart';

import '../../../models/jadwal_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/jadwal_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class JadwalGuruPage extends StatefulWidget {
  const JadwalGuruPage({super.key});

  @override
  State<JadwalGuruPage> createState() => _JadwalGuruPageState();
}

class _JadwalGuruPageState extends State<JadwalGuruPage> {
  String _tahunAjaran = JadwalService.tahunAjaranTersedia.first;
  Semester _semester = Semester.ganjil;
  HariSekolah _hari = HariSekolah.senin;

  @override
  Widget build(BuildContext context) {
    final teacher = AuthService.instance.currentTeacherName;
    final entries = teacher == null
        ? <JadwalPelajaran>[]
        : JadwalService.instance.jadwalGuru(
            tahunAjaran: _tahunAjaran,
            semester: _semester,
            guru: teacher,
            hari: _hari,
          );

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
          'Jadwal Mengajar',
          style: AppTextStyle.headingSmall.copyWith(fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _Selector<String>(
                    label: 'Tahun ajaran',
                    value: _tahunAjaran,
                    items: JadwalService.tahunAjaranTersedia,
                    onChanged: (value) => setState(() => _tahunAjaran = value!),
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
                    onChanged: (value) => setState(() => _semester = value!),
                  ),
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
          const SizedBox(height: 12),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Belum ada jadwal mengajar untuk ${_hari.label.toLowerCase()} pada periode ini.',
                        textAlign: TextAlign.center,
                        style: AppTextStyle.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _TeacherScheduleCard(jadwal: entries[index]),
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

class _TeacherScheduleCard extends StatelessWidget {
  final JadwalPelajaran jadwal;

  const _TeacherScheduleCard({required this.jadwal});

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
                '${jadwal.kelas} · ${jadwal.mataPelajaran}',
                style: AppTextStyle.headingSmall.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                jadwal.ruang,
                style: AppTextStyle.bodySmall.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
