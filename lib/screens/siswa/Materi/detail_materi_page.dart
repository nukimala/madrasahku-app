import 'package:flutter/material.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class DetailMateriPage extends StatefulWidget {
  final String judul;
  final String mapel;
  final String kelas;
  final String guru;
  final String deskripsi;
  final String fileInfo;


  const DetailMateriPage({
    super.key,
    this.judul = 'Fotosintesis',
    this.mapel = 'IPA',
    this.kelas = 'Kelas VIII A',
    this.guru = 'Budi Santoso',
    this.deskripsi =
        'Materi ini menjelaskan proses fotosintesis pada tumbuhan beserta '
            'tahapan dan contoh dalam kehidupan sehari-hari',
    this.fileInfo = 'PDF 2.5 MB',
  });

  @override
  State<DetailMateriPage> createState() => _DetailMateriPageState();
}

class _DetailMateriPageState extends State<DetailMateriPage> {
  static const _green = Color(0xFF219653);

  // 0 = Deskripsi, 1 = File
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
                        Text(
                          'Materi Pembelajaran',
                          style: AppTextStyle.headingSmall.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Preview video
                    GestureDetector(
                      onTap: () => _showComingSoon(context, 'Pemutar video'),
                      child: Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.textPrimary,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.play_arrow_outlined,
                              size: 32,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info materi
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Icon(
                            Icons.play_circle_fill_rounded,
                            size: 18,
                            color: _green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.judul,
                                style: AppTextStyle.headingSmall.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${widget.mapel} - ${widget.kelas}',
                                style: AppTextStyle.headingSmall.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Guru: ${widget.guru}',
                                style: AppTextStyle.headingSmall.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Tab Deskripsi / File
                    Row(
                      children: [
                        Expanded(
                          child: _TabButton(
                            label: 'Deskripsi',
                            selected: _tabIndex == 0,
                            onTap: () => setState(() => _tabIndex = 0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TabButton(
                            label: 'File',
                            selected: _tabIndex == 1,
                            onTap: () => setState(() => _tabIndex = 1),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (_tabIndex == 0) ...[
                      Text(
                        widget.deskripsi,
                        style: AppTextStyle.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _FileCard(
                        icon: Icons.description,
                        title: 'Video Pembelajaran',
                        info: '8:12 MP4 - 25MB',
                        onTap: () => _showComingSoon(context, 'Video'),
                      ),
                    ] else ...[
                      _FileCard(
                        icon: Icons.description,
                        title: 'Video Pembelajaran',
                        info: '8:12 MP4 - 25MB',
                        showDownload: true,
                        onTap: () => _showComingSoon(context, 'Unduh video'),
                      ),
                      const SizedBox(height: 12),
                      _FileCard(
                        icon: Icons.description,
                        title: 'Modul ${widget.mapel}',
                        info: widget.fileInfo,
                        showDownload: true,
                        onTap: () => _showComingSoon(context, 'Unduh modul'),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Tombol Tonton Video
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 8, 40, 24),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () => _showComingSoon(context, 'Pemutar video'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: AppColors.white,
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tonton Video',
                    style: TextStyle(
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
    );
  }

  static void _showComingSoon(BuildContext context, String menu) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$menu akan kita buat berikutnya, ya!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF219653) : const Color(0xFFEDEDED),
      elevation: selected ? 0 : 3,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 30,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String info;
  final bool showDownload;
  final VoidCallback onTap;

  const _FileCard({
    required this.icon,
    required this.title,
    required this.info,
    required this.onTap,
    this.showDownload = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 30, color: const Color(0xFF219653)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.headingSmall.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      info,
                      style: AppTextStyle.bodySmall.copyWith(
                        fontSize: 9,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (showDownload)
                const Icon(
                  Icons.download_rounded,
                  size: 24,
                  color: Color(0xFF219653),
                ),
            ],
          ),
        ),
      ),
    );
  }
}