import 'package:flutter/material.dart';

import '../../../models/jadwal_model.dart';
import '../../../services/jadwal_excel_importer.dart';
import '../../../services/jadwal_service.dart';
import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class PratinjauImporJadwalPage extends StatefulWidget {
  final JadwalImportHasil hasil;
  final String namaFile;

  const PratinjauImporJadwalPage({
    super.key,
    required this.hasil,
    required this.namaFile,
  });

  @override
  State<PratinjauImporJadwalPage> createState() =>
      _PratinjauImporJadwalPageState();
}

class _PratinjauImporJadwalPageState extends State<PratinjauImporJadwalPage> {
  bool _isImporting = false;

  Future<void> _konfirmasiImpor() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ganti jadwal?'),
        content: Text(
          'Jadwal ${widget.hasil.tahunAjaran} · ${widget.hasil.semester.label} '
          'yang tersimpan akan diganti dengan ${widget.hasil.jadwal.length} '
          'jadwal dari file ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ganti jadwal'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isImporting = true);
    try {
      final imported = await JadwalService.instance.gantiJadwal(
        tahunAjaran: widget.hasil.tahunAjaran,
        semester: widget.hasil.semester,
        jadwalBaru: widget.hasil.jadwal,
      );
      if (mounted) Navigator.pop(context, imported);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isImporting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Impor gagal: $error')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text('Pratinjau impor', style: AppTextStyle.headingSmall),
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _FileCard(
                  fileName: widget.namaFile,
                  sheetName: widget.hasil.namaSheet,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        value: '${widget.hasil.jadwal.length}',
                        label: 'Jadwal terbaca',
                        icon: Icons.event_note_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        value: '${widget.hasil.catatan.length}',
                        label: 'Perlu ditinjau',
                        icon: Icons.info_outline,
                        color: widget.hasil.catatan.isEmpty
                            ? AppColors.primary
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Periode impor', style: AppTextStyle.label),
                      const SizedBox(height: 10),
                      Text(
                        '${widget.hasil.tahunAjaran} · Semester '
                        '${widget.hasil.semester.label}',
                        style: AppTextStyle.headingSmall.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Impor akan mengganti jadwal pada periode ini. '
                        'Kelas dan ruang bersifat opsional; jam pelajaran '
                        'ditampilkan sesuai isi file.',
                        style: AppTextStyle.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.hasil.catatan.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Perlu ditinjau',
                    style: AppTextStyle.headingSmall.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...widget.hasil.catatan
                      .take(30)
                      .map((catatan) => _NoteTile(text: catatan)),
                  if (widget.hasil.catatan.length > 30)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Dan ${widget.hasil.catatan.length - 30} catatan lainnya.',
                        style: AppTextStyle.bodySmall,
                      ),
                    ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Contoh jadwal',
                  style: AppTextStyle.headingSmall.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...widget.hasil.jadwal
                    .take(8)
                    .map((jadwal) => _PreviewScheduleCard(jadwal: jadwal)),
                if (widget.hasil.jadwal.length > 8)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Menampilkan 8 dari ${widget.hasil.jadwal.length} jadwal.',
                      style: AppTextStyle.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isImporting
                        ? null
                        : () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _isImporting ? null : _konfirmasiImpor,
                    icon: _isImporting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file_outlined),
                    label: Text(_isImporting ? 'Mengimpor...' : 'Ganti jadwal'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _FileCard extends StatelessWidget {
  final String fileName;
  final String sheetName;

  const _FileCard({required this.fileName, required this.sheetName});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.description_outlined,
          color: AppColors.primary,
          size: 30,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Lembar: $sheetName',
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyle.headingSmall.copyWith(fontSize: 18),
              ),
              Text(label, style: AppTextStyle.bodySmall.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _NoteTile extends StatelessWidget {
  final String text;

  const _NoteTile({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 16, color: AppColors.warning),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTextStyle.bodySmall)),
      ],
    ),
  );
}

class _PreviewScheduleCard extends StatelessWidget {
  final JadwalPelajaran jadwal;

  const _PreviewScheduleCard({required this.jadwal});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(
            '${jadwal.hari.label}\n${jadwal.tampilanWaktu}',
            style: AppTextStyle.bodySmall.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jadwal.mataPelajaran,
                style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
              ),
              Text(
                [
                  if (jadwal.kelas != null) 'Kelas ${jadwal.kelas}',
                  jadwal.guru,
                ].join(' · '),
                style: AppTextStyle.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
