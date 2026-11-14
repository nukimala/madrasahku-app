import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';


class MateriBaru {
  final String judul;
  final String deskripsi;
  final String? namaFile;

  const MateriBaru({
    required this.judul,
    required this.deskripsi,
    this.namaFile,
  });
}

class TambahMateriPage extends StatefulWidget {
  final String topik; 
  final String kelas;
  final String mapel;

  const TambahMateriPage({
    super.key,
    required this.topik,
    required this.kelas,
    required this.mapel,
  });

  @override
  State<TambahMateriPage> createState() => _TambahMateriPageState();
}

class _TambahMateriPageState extends State<TambahMateriPage> {
  static const Color _green = Color(0xFF219653);

  final _judul = TextEditingController();
  final _deskripsi = TextEditingController();

  String? _namaFile;

  @override
  void dispose() {
    _judul.dispose();
    _deskripsi.dispose();
    super.dispose();
  }

  // Pilih file materi.
  Future<void> _pilihFile() async {
    try {
      final res = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'png'],
      );
      if (res.isNotEmpty) {
        setState(() => _namaFile = res.first.name);
      }
    } catch (_) {}
  }

  void _simpan() {
    if (_judul.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Judul materi wajib diisi')),
        );
      return;
    }

    Navigator.pop(
      context,
      MateriBaru(
        judul: _judul.text.trim(),
        deskripsi: _deskripsi.text.trim(),
        namaFile: _namaFile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              // Header.
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 22),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tambah Materi',
                          style: AppTextStyle.headingSmall.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.topik,
                          style: AppTextStyle.bodySmall.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Form.
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Judul Materi'),

                      _Kotak(
                        child: TextField(
                          controller: _judul,
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            hintText: 'Contoh: Persamaan Linier',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 13),
                          ),
                        ),
                      ),

                      const _Label('Kelas'),
                      _KotakTerkunci(teks: widget.kelas),

                      const _Label('Mata pembelajaran'),
                      _KotakTerkunci(teks: widget.mapel),

                      const _Label('Deskripsi'),

                      _Kotak(
                        child: TextField(
                          controller: _deskripsi,
                          maxLines: 5,
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            hintText: 'Tulis Deskripsi Materi...',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 13),
                          ),
                        ),
                      ),

                      const _Label('File Materi'),

                      InkWell(
                        onTap: _pilihFile,
                        borderRadius: BorderRadius.circular(10),
                        child: _Kotak(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _namaFile ??
                                        'Pilih File (Pdf, Doc, Video, Gambar)',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _namaFile == null
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                ),

                                if (_namaFile == null)
                                  const Icon(
                                    Icons.attach_file,
                                    size: 18,
                                    color: Colors.grey,
                                  )
                                else
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() => _namaFile = null),
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tombol simpan.
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '+ Tambah Materi',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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

// WIDGET KECIL PENDUKUNG
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        text,
        style: AppTextStyle.bodySmall.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Kotak extends StatelessWidget {
  final Widget child;
  const _Kotak({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Kelas & mapel 
class _KotakTerkunci extends StatelessWidget {
  final String teks;
  const _KotakTerkunci({required this.teks});

  @override
  Widget build(BuildContext context) {
    return _Kotak(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text(teks, style: const TextStyle(fontSize: 12))),
            const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}