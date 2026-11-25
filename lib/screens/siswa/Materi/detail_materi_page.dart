import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class DetailMateriPage extends StatefulWidget {
  /// Judul materi, contoh: "Minggu 1 - Persamaan Linear"
  final String judul;
  final String mapel;
  final String kelas;
  final String? deskripsi;
  final String? fileUrl;
  final int totalHalaman;
  final int halamanAwal;

  const DetailMateriPage({
    super.key,
    this.judul = 'Materi Pembelajaran',
    this.mapel = '',
    this.kelas = '',
    this.deskripsi,
    this.fileUrl,
    this.totalHalaman = 1,
    this.halamanAwal = 1,
  });

  @override
  State<DetailMateriPage> createState() => _DetailMateriPageState();
}

class _DetailMateriPageState extends State<DetailMateriPage> {
  static const _green = Color(0xFF219653);

  late int _halaman = widget.halamanAwal.clamp(1, widget.totalHalaman);
  bool _selesai = false;

  void _ganti(int delta) {
    final next = _halaman + delta;
    if (next < 1 || next > widget.totalHalaman) return;
    setState(() => _halaman = next);
  }

  void _selesaikan() {
    setState(() => _selesai = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Materi ditandai selesai'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context, true); // beri tahu halaman daftar bahwa materi selesai
  }

  Future<void> _salinLinkFile() async {
    final url = widget.fileUrl?.trim() ?? '';
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Materi ini tidak memiliki lampiran file.')),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tautan lampiran disalin: $url')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.maybePop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.judul,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Viewer halaman materi
              Container(
                width: double.infinity,
                height: 280,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.judul,
                        style: AppTextStyle.headingSmall.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.mapel} • ${widget.kelas}',
                        style: AppTextStyle.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Divider(height: 24),
                      Text(
                        (widget.deskripsi != null && widget.deskripsi!.trim().isNotEmpty)
                            ? widget.deskripsi!
                            : 'Silakan pelajari materi dan lampiran yang disediakan oleh guru.',
                        style: AppTextStyle.bodyMedium.copyWith(height: 1.5),
                      ),
                      if (widget.fileUrl != null && widget.fileUrl!.trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_file, size: 18, color: _green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.fileUrl!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.bodySmall.copyWith(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Navigasi halaman
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _halaman > 1 ? () => _ganti(-1) : null,
                    icon: const Icon(Icons.arrow_back, size: 20),
                    color: AppColors.textPrimary,
                  ),
                  Text(
                    'Halaman $_halaman/${widget.totalHalaman}',
                    style: AppTextStyle.headingSmall.copyWith(fontSize: 12),
                  ),
                  IconButton(
                    onPressed:
                        _halaman < widget.totalHalaman ? () => _ganti(1) : null,
                    icon: const Icon(Icons.arrow_forward, size: 20),
                    color: AppColors.textPrimary,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Download File
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: OutlinedButton(
                    onPressed: _salinLinkFile,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: _green,
                      side: const BorderSide(color: Colors.black87),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Salin Tautan File',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Selesaikan Materi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _selesai ? null : _selesaikan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: _green.withOpacity(0.5),
                      disabledForegroundColor: AppColors.white,
                      elevation: 4,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _selesai ? 'Materi Selesai' : 'Selesaikan Materi',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}