import 'package:flutter/material.dart';
import '../../../utilis/app_colors.dart';
import 'tugas_guru_page.dart';

class TambahTugasPage extends StatefulWidget {
  const TambahTugasPage({super.key});

  @override
  State<TambahTugasPage> createState() => _TambahTugasPageState();
}

class _TambahTugasPageState extends State<TambahTugasPage> {
  static const Color _green = Color(0xFF219653);

  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String? _selectedKelas;
  String? _selectedMapel;
  String? _selectedFile;

  final List<String> _kelasList = [
    'Kelas VII A',
    'Kelas VII B',
    'Kelas VIII A',
    'Kelas VIII B',
    'Kelas IX A',
  ];

  final List<String> _mapelList = [
    'Matematika',
    'Al-Qur’an Hadis',
    'Akidah Akhlak',
    'Fikih',
    'Sejarah Kebudayaan Islam (SKI)',
    'Bahasa Arab',
    'Bahasa Indonesia',
    'IPA',
    'IPS',
    'Bahasa Inggris',
  ];

  void _simpan() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tugas wajib diisi')),
      );
      return;
    }

    final newTugas = GuruTugasItem(
      title: title,
      subtitle: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : 'Bab 1 - Pendahuluan',
      fileInfo: _selectedFile ?? 'PDF 2.5 MB',
      kelas: _selectedKelas ?? 'Kelas VIII A',
      mapel: _selectedMapel ?? 'Matematika',
    );

    Navigator.pop(context, newTugas);
  }

  void _pilihFile() {
    setState(() {
      _selectedFile = 'Tugas_${DateTime.now().millisecondsSinceEpoch}.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File terpilih: $_selectedFile')),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tambah Tugas',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Tugas
            _buildLabel('Judul Tugas'),
            const SizedBox(height: 8),
            _buildCardInput(
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Persamaan Linier',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Kelas
            _buildLabel('Kelas'),
            const SizedBox(height: 8),
            _buildCardInput(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedKelas,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Pilih Kelas', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                  ),
                  isExpanded: true,
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.keyboard_arrow_down, color: Color(0xFF374151)),
                  ),
                  items: _kelasList.map((k) => DropdownMenuItem(
                    value: k,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(k, style: const TextStyle(fontSize: 14)),
                    ),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedKelas = v),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Mata Pelajaran
            _buildLabel('Mata pembelajaran'),
            const SizedBox(height: 8),
            _buildCardInput(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMapel,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Pilih Mata Pelajaran', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                  ),
                  isExpanded: true,
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.keyboard_arrow_down, color: Color(0xFF374151)),
                  ),
                  items: _mapelList.map((m) => DropdownMenuItem(
                    value: m,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(m, style: const TextStyle(fontSize: 14)),
                    ),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedMapel = v),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Deskripsi
            _buildLabel('Deskripsi'),
            const SizedBox(height: 8),
            _buildCardInput(
              child: TextField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Tulis Deskripsi Tugas...',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // File Tugas
            _buildLabel('File Tugas'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pilihFile,
              borderRadius: BorderRadius.circular(14),
              child: _buildCardInput(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedFile ?? 'Pilih File (Pdf, Doc, Video, Gambar)',
                          style: TextStyle(
                            color: _selectedFile != null ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                            fontSize: 14,
                            fontWeight: _selectedFile != null ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      const Icon(Icons.attach_file, color: Color(0xFF9CA3AF), size: 20),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Tombol Tambah Tugas
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  '+ Tambah Tugas',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildCardInput({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
