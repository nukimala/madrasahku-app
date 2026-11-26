import 'package:flutter/material.dart';

import '../../../models/jadwal_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/jadwal_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class JadwalSiswaPage extends StatefulWidget {
  const JadwalSiswaPage({super.key});

  @override
  State<JadwalSiswaPage> createState() => _JadwalSiswaPageState();
}

class _JadwalSiswaPageState extends State<JadwalSiswaPage> {
  HariSekolah _hari = HariSekolah.senin;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final wd = DateTime.now().weekday;
    if (wd >= 1 && wd <= 6) {
      _hari = HariSekolah.values[wd - 1];
    }
    _muatJadwal();
  }

  Future<void> _muatJadwal() async {
    setState(() => _loading = true);
    try {
      await JadwalService.instance.ambilJadwalApi();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final kelas = AuthService.instance.currentStudentClassName ?? '';
    final entries = JadwalService.instance.jadwalSiswa(hari: _hari);

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
            size: 26,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jadwal Pelajaran',
              style: AppTextStyle.headingSmall.copyWith(fontSize: 18),
            ),
            if (kelas.isNotEmpty)
              Text(
                'Kelas $kelas',
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: HariSekolah.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final hari = HariSekolah.values[index];
                final selected = _hari == hari;
                return ChoiceChip(
                  label: Text(hari.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _hari = hari),
                  selectedColor: AppColors.primaryLight,
                  labelStyle: TextStyle(
                    color: selected
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide.none,
                  showCheckmark: false,
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : entries.isEmpty
                ? RefreshIndicator(
                    onRefresh: _muatJadwal,
                    child: ListView(
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Text(
                            'Tidak ada jadwal pelajaran pada hari ${_hari.label}.',
                            style: AppTextStyle.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _muatJadwal,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: entries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = entries[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.mataPelajaran,
                                      style: AppTextStyle.headingSmall.copyWith(
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (item.guru.isNotEmpty)
                                      Text(
                                        item.guru,
                                        style: AppTextStyle.bodySmall.copyWith(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    if (item.ruang != null &&
                                        item.ruang!.isNotEmpty)
                                      Text(
                                        item.ruang!,
                                        style: AppTextStyle.bodySmall.copyWith(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.tampilanWaktu,
                                  style: AppTextStyle.label.copyWith(
                                    fontSize: 11,
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
