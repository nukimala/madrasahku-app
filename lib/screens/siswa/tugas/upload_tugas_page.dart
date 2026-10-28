import 'package:flutter/material.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class UploadTugasPage extends StatefulWidget {
  final String title;
  final String subject;
  final String deadline;

  const UploadTugasPage({
    super.key,
    required this.title,
    required this.subject,
    required this.deadline,
  });

  @override
  State<UploadTugasPage> createState() => _UploadTugasPageState();
}

class _UploadTugasPageState extends State<UploadTugasPage> {
  static const Color _green = Color(0xFF219653);
  static const Color _blue = Color(0xFF60A5FA);

  final _noteController = TextEditingController();

  // File terpilih (sementara berupa data dummy)
  String? _fileName;
  String? _fileInfo;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _pickFile() {
    setState(() {
      _fileName = 'Tugas_Matematika.pdf';
      _fileInfo = 'PDF 2.5 MB';
    });
  }

  void _removeFile() {
    setState(() {
      _fileName = null;
      _fileInfo = null;
    });
  }

  Future<void> _submit() async {
    if (_fileName == null) {
      _showMessage('Pilih file tugas terlebih dahulu.');
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    _showMessage('Tugas "${widget.title}" berhasil dikumpulkan.');
    Navigator.pop(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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
                              size: 22,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('Kumpulkan Tugas',
                            style: AppTextStyle.headingSmall),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Info tugas
                    _buildInfoCard(),

                    const SizedBox(height: 24),

                    // Upload file
                    Text(
                      'Upload File Tugas',
                      style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    _buildPickerBox(),

                    // File terpilih
                    if (_fileName != null) ...[
                      const SizedBox(height: 16),
                      _buildSelectedFile(),
                    ],

                    const SizedBox(height: 24),

                    // Catatan
                    Text(
                      'Catatan (Opsional)',
                      style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    _buildNoteField(),
                  ],
                ),
              ),
            ),

            // Tombol kumpulkan
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _green.withOpacity(0.6),
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Kumpulkan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
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

  // Kartu info tugas
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.description, size: 30, color: _blue),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyle.headingSmall.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subject,
                  style: AppTextStyle.bodySmall.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Batas Waktu',
                  style: AppTextStyle.bodySmall.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.deadline,
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Kotak "Pilih File"
  Widget _buildPickerBox() {
    return Material(
      color: AppColors.white,
      elevation: 3,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: _pickFile,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          child: Column(
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 32, color: _green),
              const SizedBox(height: 8),
              Text(
                'Pilih File',
                style: AppTextStyle.headingSmall.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                '(PDF, DOC, JPG, PNG, MP4)',
                textAlign: TextAlign.center,
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                ),
              ),
              Text(
                'Maksimal 5MB',
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Baris file yang sudah dipilih
  Widget _buildSelectedFile() {
    return Row(
      children: [
        const Icon(Icons.description, size: 30, color: _blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _fileName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.headingSmall.copyWith(fontSize: 13),
              ),
              Text(
                _fileInfo ?? '',
                style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 10,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _removeFile,
          icon: const Icon(Icons.close, size: 20, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }

  // Input catatan
  Widget _buildNoteField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _noteController,
        maxLines: 4,
        style: AppTextStyle.bodySmall.copyWith(fontSize: 12),
        decoration: InputDecoration(
          hintText: 'Tambahkan catatan...',
          hintStyle: AppTextStyle.bodySmall.copyWith(
            fontSize: 12,
            color: const Color(0xFF9CA3AF),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}