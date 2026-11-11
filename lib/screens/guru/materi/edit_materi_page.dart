import 'package:flutter/material.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

import 'tambah_materi_page.dart' show MateriBaru;

class EditMateriPage extends StatefulWidget {
  final String topik;
  final String kelas;
  final String mapel;

  // Data lama untuk prefill.
  final String judulAwal;
  final String deskripsiAwal;
  final String? namaFileAwal;

  const EditMateriPage({
    super.key,
    required this.topik,
    required this.kelas,
    required this.mapel,
    required this.judulAwal,
    required this.deskripsiAwal,
    this.namaFileAwal,
  });

  @override
  State<EditMateriPage> createState() => _EditMateriPageState();
}

class _EditMateriPageState extends State<EditMateriPage> {
  static const Color _green = Color(0xFF219653);

  late final TextEditingController _judul;
  late final TextEditingController _deskripsi;
  String? _namaFile;

  @override
  void initState() {
    super.initState();
    _judul = TextEditingController(text: widget.judulAwal);
    _deskripsi = TextEditingController(text: widget.deskripsiAwal);
    _namaFile = widget.namaFileAwal;
  }

  @override
  void dispose() {
    _judul.dispose();
    _deskripsi.dispose();
    super.dispose();
  }

  Future<void> _pilihFile() async {
    setState(() => _namaFile = 'materi_contoh.pdf');
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
                          'Edit Materi',
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
                    'Simpan Perubahan',
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

// Widget kecil pendukung (sama seperti di TambahMateriPage).
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