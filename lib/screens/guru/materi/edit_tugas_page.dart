import 'package:flutter/material.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

import 'tambah_tugas_page.dart' show TugasBaru;

class EditTugasPage extends StatefulWidget {
  final String topik;
  final String kelas;
  final String mapel;

  // Data lama untuk prefill.
  final String judulAwal;
  final String deskripsiAwal;
  final DateTime mulaiAwal;
  final DateTime deadlineAwal;
  final String jenisAwal;
  final String? namaFileAwal;

  const EditTugasPage({
    super.key,
    required this.topik,
    required this.kelas,
    required this.mapel,
    required this.judulAwal,
    required this.deskripsiAwal,
    required this.mulaiAwal,
    required this.deadlineAwal,
    required this.jenisAwal,
    this.namaFileAwal,
  });

  @override
  State<EditTugasPage> createState() => _EditTugasPageState();
}

class _EditTugasPageState extends State<EditTugasPage> {
  static const Color _green = Color(0xFF219653);

  static const _hari = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  static const _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  late final TextEditingController _judul;
  late final TextEditingController _deskripsi;

  late DateTime _mulai;
  late DateTime _deadline;
  late String _jenis;
  String? _namaFile;

  @override
  void initState() {
    super.initState();
    _judul = TextEditingController(text: widget.judulAwal);
    _deskripsi = TextEditingController(text: widget.deskripsiAwal);
    _mulai = widget.mulaiAwal;
    _deadline = widget.deadlineAwal;
    _jenis = widget.jenisAwal;
    _namaFile = widget.namaFileAwal;
  }

  @override
  void dispose() {
    _judul.dispose();
    _deskripsi.dispose();
    super.dispose();
  }

  String _jam(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _hariTanggal(DateTime d) =>
      '${_hari[d.weekday - 1]}, ${d.day} ${_bulan[d.month - 1]}';

  Future<DateTime?> _pilihWaktu(DateTime awal) async {
    final tanggal = await showDatePicker(
      context: context,
      initialDate: awal,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (tanggal == null || !mounted) return null;

    final jam = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(awal),
    );
    if (jam == null) return null;

    return DateTime(
        tanggal.year, tanggal.month, tanggal.day, jam.hour, jam.minute);
  }

  Future<void> _pilihMulai() async {
    final hasil = await _pilihWaktu(_mulai);
    if (hasil != null) setState(() => _mulai = hasil);
  }

  Future<void> _pilihDeadline() async {
    final hasil = await _pilihWaktu(_deadline);
    if (hasil != null) setState(() => _deadline = hasil);
  }

  Future<void> _pilihFile() async {
    setState(() => _namaFile = 'tugas_contoh.pdf');
  }

  void _snack(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  void _simpan() {
    if (_judul.text.trim().isEmpty) {
      _snack('Judul tugas wajib diisi');
      return;
    }
    if (!_deadline.isAfter(_mulai)) {
      _snack('Deadline harus setelah waktu mulai');
      return;
    }

    Navigator.pop(
      context,
      TugasBaru(
        judul: _judul.text.trim(),
        deskripsi: _deskripsi.text.trim(),
        mulai: _mulai,
        deadline: _deadline,
        jenis: _jenis,
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
                          'Edit Tugas',
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
                      const _Label('Judul Tugas'),
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

                      const _Label('Deadline'),
                      _Kotak(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: _BlokWaktu(
                                  jam: _jam(_mulai),
                                  hari: _hariTanggal(_mulai),
                                  onTap: _pilihMulai,
                                ),
                              ),
                              const Icon(Icons.arrow_forward, size: 16),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _BlokWaktu(
                                  jam: _jam(_deadline),
                                  hari: _hariTanggal(_deadline),
                                  onTap: _pilihDeadline,
                                ),
                              ),
                              const Icon(Icons.calendar_month, size: 20),
                            ],
                          ),
                        ),
                      ),

                      const _Label('Deskripsi'),
                      _Kotak(
                        child: TextField(
                          controller: _deskripsi,
                          maxLines: 5,
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            hintText: 'Tulis Deskripsi Tugas...',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 13),
                          ),
                        ),
                      ),

                      const _Label('Jenis Tugas'),
                      _Kotak(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _jenis,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            items: const ['Individu', 'Kelompok']
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _jenis = v);
                            },
                          ),
                        ),
                      ),

                      const _Label('File Tugas'),
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

// Widget kecil pendukung.
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

class _BlokWaktu extends StatelessWidget {
  final String jam;
  final String hari;
  final VoidCallback onTap;

  const _BlokWaktu({
    required this.jam,
    required this.hari,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            jam,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          Text(
            hari,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}