import 'package:flutter/material.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

class TambahMateriPage extends StatefulWidget {
  const TambahMateriPage({super.key});

  @override
  State<TambahMateriPage> createState() => _TambahMateriPageState();
}

class _TambahMateriPageState extends State<TambahMateriPage> {
  static const Color _green = Color(0xFF219653);
  static const Color _hint = Color(0xFF8A9B91);

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  final List<String> _kelasList = const [
    'Kelas VII A',
    'Kelas VIII A',
    'Kelas IX A',
  ];
  final List<String> _mapelList = const [
    'Matematika',
    'Al-Quran Hadis',
    'Bahasa Arab',
  ];

  String? _selectedKelas;
  String? _selectedMapel;
  String? _namaFile;

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

 
  Future<void> _pilihFile() async {
    _showMessage('Pilih file akan aktif setelah package file_picker dipasang.');
  }

  void _simpan() {
    if (_judulController.text.trim().isEmpty ||
        _selectedKelas == null ||
        _selectedMapel == null) {
      _showMessage('Judul, kelas, dan mata pelajaran wajib diisi.');
      return;
    }

    // Kirim data kembali ke halaman sebelumnya
    Navigator.pop(context, {
      'judul': _judulController.text.trim(),
      'kelas': _selectedKelas!,
      'mapel': _selectedMapel!,
      'deskripsi': _deskripsiController.text.trim(),
      'file': _namaFile ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Tambah Materi',
                    style: AppTextStyle.headingSmall.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Judul Materi'),
                    _buildTextField(
                      controller: _judulController,
                      hint: 'Contoh: Persamaan Linier',
                    ),

                    const SizedBox(height: 16),
                    _label('Kelas'),
                    _buildDropdown(
                      hint: 'Pilih Kelas',
                      value: _selectedKelas,
                      items: _kelasList,
                      onChanged: (v) => setState(() => _selectedKelas = v),
                    ),

                    const SizedBox(height: 24),
                    _label('Mata pembelajaran'),
                    _buildDropdown(
                      hint: 'Pilih Mata Pelajaran',
                      value: _selectedMapel,
                      items: _mapelList,
                      onChanged: (v) => setState(() => _selectedMapel = v),
                    ),

                    const SizedBox(height: 24),
                    _label('Deskripsi'),
                    _buildTextField(
                      controller: _deskripsiController,
                      hint: 'Tulis Deskripsi Materi...',
                      maxLines: 5,
                    ),

                    const SizedBox(height: 24),
                    _label('File Materi'),
                    _buildFileField(),

                    const SizedBox(height: 40),

                    // Tombol tambah materi
                    Center(
                      child: SizedBox(
                        width: 214,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _simpan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            '+ Tambah Materi',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
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

  // Label di atas input
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyle.bodyMedium.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // Input teks
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: _cardDecoration(),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: maxLines,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: _hint,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // Dropdown
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _cardDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: const TextStyle(
              color: _hint,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Field pilih file
  Widget _buildFileField() {
    return InkWell(
      onTap: _pilihFile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 46,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        decoration: _cardDecoration(),
        child: Text(
          _namaFile ?? 'Pilih File (Pdf, Doc, Vlide, Gambar',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _namaFile == null ? _hint : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
}