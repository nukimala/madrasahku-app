import 'package:flutter/material.dart';

import '../../../utilis/app_colors.dart';
import '../../../utilis/app_text_style.dart';

import 'tambah_materi_page.dart';
import 'tambah_tugas_page.dart';

import 'edit_materi_page.dart';
import 'edit_tugas_page.dart';

// =====================================================================
// MODEL SEMENTARA
// =====================================================================
class _Item {
  final String judul;
  final String sub;
  final bool isTugas;

  // Data mentah untuk edit.
  final String deskripsi;
  final String? namaFile;
  final DateTime? mulai;    // hanya tugas
  final DateTime? deadline; // hanya tugas
  final String? jenis;      // hanya tugas

  _Item({
    required this.judul,
    this.sub = '',
    this.isTugas = false,
    this.deskripsi = '',
    this.namaFile,
    this.mulai,
    this.deadline,
    this.jenis,
  });

  _Item copyWith({
    String? judul,
    String? sub,
    bool? isTugas,
    String? deskripsi,
    String? namaFile,
    DateTime? mulai,
    DateTime? deadline,
    String? jenis,
    bool hapusFile = false,
  }) {
    return _Item(
      judul: judul ?? this.judul,
      sub: sub ?? this.sub,
      isTugas: isTugas ?? this.isTugas,
      deskripsi: deskripsi ?? this.deskripsi,
      namaFile: hapusFile ? null : (namaFile ?? this.namaFile),
      mulai: mulai ?? this.mulai,
      deadline: deadline ?? this.deadline,
      jenis: jenis ?? this.jenis,
    );
  }
}

class _Topik {
  final int minggu;
  final String nama;
  final DateTime waktu;
  final List<_Item> items;

  _Topik({
    required this.minggu,
    required this.nama,
    required this.waktu,
    List<_Item>? items,
  }) : items = items ?? [];

  String get judul => 'Minggu $minggu - $nama';
}

// =====================================================================
// HALAMAN MATERI GURU
// =====================================================================
class MateriGuruPage extends StatefulWidget {
  const MateriGuruPage({super.key});

  @override
  State<MateriGuruPage> createState() => _MateriGuruPageState();
}

class _MateriGuruPageState extends State<MateriGuruPage> {
  static const Color _green = Color(0xFF219653);
  static const Color _topikBg = Color(0xFFF1EDEC);

  static const _kelasList = [
    'Kelas VII A',
    'Kelas VII B',
    'Kelas VIII A',
    'Kelas VIII B',
    'Kelas IX A',
  ];

  static const _mapelList = [
    'Matematika',
    'Bahasa Indonesia',
    'IPA',
    'IPS',
    'Bahasa Inggris',
  ];

  String _kelas = 'Kelas VIII A';
  String _mapel = 'Matematika';
  String _query = '';

  final Set<_Topik> _terbuka = {};
  final List<_Topik> _topik = [];

  @override
  void initState() {
    super.initState();

    // Data contoh — hapus kalau sudah pakai data asli.
    final contoh = _Topik(
      minggu: 1,
      nama: 'Kurva',
      waktu: DateTime(2026, 11, 3, 7, 0),
      items: [
        _Item(
          judul: 'Persamaan Linear',
          sub: 'Silahkan dipelajari materi berikut',
          deskripsi: 'Silahkan dipelajari materi berikut',
          namaFile: 'materi_contoh.pdf',
        ),
        _Item(
          judul: 'Persamaan Linear',
          sub: 'Deadline: 11/12/2026, 23.59',
          isTugas: true,
          deskripsi: 'Kerjakan soal halaman 10',
          namaFile: 'tugas_contoh.pdf',
          mulai: DateTime(2026, 12, 4, 7, 0),
          deadline: DateTime(2026, 12, 11, 23, 59),
          jenis: 'Individu',
        ),
      ],
    );

    _topik.add(contoh);
    _terbuka.add(contoh);

    _topik.add(
      _Topik(minggu: 3, nama: 'FPB dan KPK', waktu: DateTime(2026, 11, 17)),
    );
    _topik.add(
      _Topik(minggu: 4, nama: 'Desimal', waktu: DateTime(2026, 11, 24)),
    );
  }

  // Filter pencarian.
  List<_Topik> get _hasil {
    final q = _query.toLowerCase();
    if (q.isEmpty) return _topik;

    return _topik.where((t) {
      return t.judul.toLowerCase().contains(q) ||
          t.items.any((i) => i.judul.toLowerCase().contains(q));
    }).toList();
  }

  // -------------------------------------------------------------------
  // TAMBAH TOPIK
  // -------------------------------------------------------------------
  Future<void> _tambahTopik() async {
    final hasil = await showDialog<_Topik>(
      context: context,
      builder: (_) => const _TambahTopikDialog(),
    );

    if (hasil == null) return;

    setState(() {
      _topik.add(hasil);
      _terbuka.add(hasil);
    });
  }

  // -------------------------------------------------------------------
  // CARD KECIL: UPLOAD MATERI / UPLOAD TUGAS
  // -------------------------------------------------------------------
  void _pilihJenisUpload(_Topik topik) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tambah ke ${topik.judul}',
                textAlign: TextAlign.center,
                style: AppTextStyle.headingSmall.copyWith(fontSize: 13),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _PilihanUpload(
                      icon: Icons.description,
                      warna: _green,
                      label: 'Upload Materi',
                      onTap: () {
                        Navigator.pop(ctx);
                        _bukaTambahMateri(topik);
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _PilihanUpload(
                      icon: Icons.assignment,
                      warna: const Color(0xFF2F80ED),
                      label: 'Upload Tugas',
                      onTap: () {
                        Navigator.pop(ctx);
                        _bukaTambahTugas(topik);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // BUKA HALAMAN TAMBAH MATERI
  // -------------------------------------------------------------------
  Future<void> _bukaTambahMateri(_Topik topik) async {
    final hasil = await Navigator.push<MateriBaru>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahMateriPage(
          topik: topik.judul,
          kelas: _kelas,
          mapel: _mapel,
        ),
      ),
    );

    if (hasil == null || !mounted) return;

    setState(() {
      topik.items.add(
        _Item(
          judul: hasil.judul,
          sub: hasil.deskripsi.isNotEmpty
              ? hasil.deskripsi
              : (hasil.namaFile ?? ''),
          deskripsi: hasil.deskripsi,
          namaFile: hasil.namaFile,
        ),
      );
      _terbuka.add(topik);
    });
  }

  // -------------------------------------------------------------------
  // BUKA HALAMAN TAMBAH TUGAS
  // -------------------------------------------------------------------
  Future<void> _bukaTambahTugas(_Topik topik) async {
    final hasil = await Navigator.push<TugasBaru>(
      context,
      MaterialPageRoute(
        builder: (_) => TambahTugasPage(
          topik: topik.judul,
          kelas: _kelas,
          mapel: _mapel,
        ),
      ),
    );

    if (hasil == null || !mounted) return;

    final d = hasil.deadline;

    setState(() {
      topik.items.add(
        _Item(
          judul: hasil.judul,
          sub: 'Deadline: ${d.day}/${d.month}/${d.year}, '
              '${d.hour.toString().padLeft(2, '0')}.'
              '${d.minute.toString().padLeft(2, '0')}',
          isTugas: true,
          deskripsi: hasil.deskripsi,
          namaFile: hasil.namaFile,
          mulai: hasil.mulai,
          deadline: hasil.deadline,
          jenis: hasil.jenis,
        ),
      );
      _terbuka.add(topik);
    });
  }

  // -------------------------------------------------------------------
  // BUKA HALAMAN EDIT MATERI
  // -------------------------------------------------------------------
  Future<void> _bukaEditMateri(_Topik topik, _Item item) async {
    final hasil = await Navigator.push<MateriBaru>(
      context,
      MaterialPageRoute(
        builder: (_) => EditMateriPage(
          topik: topik.judul,
          kelas: _kelas,
          mapel: _mapel,
          judulAwal: item.judul,
          deskripsiAwal: item.deskripsi,
          namaFileAwal: item.namaFile,
        ),
      ),
    );

    if (hasil == null || !mounted) return;

    setState(() {
      final i = topik.items.indexOf(item);
      if (i == -1) return;

      // Tandai kalau user memang menghapus file (dari ada → null).
      final hapusFile = item.namaFile != null && hasil.namaFile == null;

      topik.items[i] = item.copyWith(
        judul: hasil.judul,
        deskripsi: hasil.deskripsi,
        namaFile: hasil.namaFile,
        hapusFile: hapusFile,
        sub: hasil.deskripsi.isNotEmpty
            ? hasil.deskripsi
            : (hasil.namaFile ?? ''),
      );
      _terbuka.add(topik);
    });
  }

  // -------------------------------------------------------------------
  // BUKA HALAMAN EDIT TUGAS
  // -------------------------------------------------------------------
  Future<void> _bukaEditTugas(_Topik topik, _Item item) async {
    // Fallback kalau data mentah belum ada (misal data contoh lama).
    final mulaiAwal = item.mulai ?? DateTime.now();
    final deadlineAwal =
        item.deadline ?? DateTime.now().add(const Duration(days: 1));

    final hasil = await Navigator.push<TugasBaru>(
      context,
      MaterialPageRoute(
        builder: (_) => EditTugasPage(
          topik: topik.judul,
          kelas: _kelas,
          mapel: _mapel,
          judulAwal: item.judul,
          deskripsiAwal: item.deskripsi,
          mulaiAwal: mulaiAwal,
          deadlineAwal: deadlineAwal,
          jenisAwal: item.jenis ?? 'Individu',
          namaFileAwal: item.namaFile,
        ),
      ),
    );

    if (hasil == null || !mounted) return;

    final d = hasil.deadline;

    setState(() {
      final i = topik.items.indexOf(item);
      if (i == -1) return;

      final hapusFile = item.namaFile != null && hasil.namaFile == null;

      topik.items[i] = item.copyWith(
        judul: hasil.judul,
        deskripsi: hasil.deskripsi,
        namaFile: hasil.namaFile,
        hapusFile: hapusFile,
        mulai: hasil.mulai,
        deadline: hasil.deadline,
        jenis: hasil.jenis,
        sub: 'Deadline: ${d.day}/${d.month}/${d.year}, '
            '${d.hour.toString().padLeft(2, '0')}.'
            '${d.minute.toString().padLeft(2, '0')}',
      );
      _terbuka.add(topik);
    });
  }

  // -------------------------------------------------------------------
  // HAPUS ITEM
  // -------------------------------------------------------------------
  Future<void> _hapusItem(_Topik topik, _Item item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus?', style: TextStyle(fontSize: 16)),
        content: Text(
          '"${item.judul}" akan dihapus.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() => topik.items.remove(item));
    }
  }

  // -------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final daftar = _hasil;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Materi Pembelajaran',
                style: AppTextStyle.headingSmall.copyWith(fontSize: 16),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _Dropdown(
                      value: _kelas,
                      items: _kelasList,
                      onChanged: (v) => setState(() => _kelas = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Dropdown(
                      value: _mapel,
                      items: _mapelList,
                      onChanged: (v) => setState(() => _mapel = v),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _Kotak(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v.trim()),
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, size: 20),
                    hintText: 'Cari Materi....',
                    hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: daftar.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada topik.',
                          style: AppTextStyle.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: daftar.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _buildTopik(daftar[i]),
                      ),
              ),
            ],
          ),
        ),

        // Tombol tambah topik.
        Positioned(
          right: 20,
          bottom: 16,
          child: ElevatedButton(
            onPressed: _tambahTopik,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              elevation: 3,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              '+ Tambah Topik',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // CARD TOPIK
  // -------------------------------------------------------------------
  Widget _buildTopik(_Topik t) {
    final terbuka = _terbuka.contains(t) || _query.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _topikBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() {
              terbuka ? _terbuka.remove(t) : _terbuka.add(t);
            }),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Topik',
                        style: AppTextStyle.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        t.judul,
                        style: AppTextStyle.headingSmall.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (terbuka)
                  GestureDetector(
                    onTap: () => _pilihJenisUpload(t),
                    child: const Icon(Icons.add, size: 30),
                  )
                else
                  const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),

          if (terbuka) ...[
            const SizedBox(height: 10),

            if (t.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Belum ada materi/tugas. Tekan + untuk menambah.',
                  style: AppTextStyle.bodySmall.copyWith(fontSize: 11),
                ),
              ),

            ...t.items.map((item) => _buildItem(t, item)),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // ITEM MATERI / TUGAS DI DALAM TOPIK
  // -------------------------------------------------------------------
  Widget _buildItem(_Topik t, _Item item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            item.isTugas ? Icons.assignment : Icons.description,
            size: 28,
            color: item.isTugas ? const Color(0xFF2F80ED) : _green,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.judul,
                  style: AppTextStyle.headingSmall.copyWith(fontSize: 13),
                ),
                if (item.sub.isNotEmpty)
                  Text(
                    item.sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.bodySmall.copyWith(fontSize: 10),
                  ),
              ],
            ),
          ),

          // EDIT
          InkWell(
            onTap: () {
              if (item.isTugas) {
                _bukaEditTugas(t, item);
              } else {
                _bukaEditMateri(t, item);
              }
            },
            child: const Icon(Icons.edit_outlined, size: 20),
          ),

          const SizedBox(width: 10),

          // HAPUS
          InkWell(
            onTap: () => _hapusItem(t, item),
            child: const Icon(Icons.delete_outline, size: 20),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// DIALOG TAMBAH TOPIK
// =====================================================================
class _TambahTopikDialog extends StatefulWidget {
  const _TambahTopikDialog();

  @override
  State<_TambahTopikDialog> createState() => _TambahTopikDialogState();
}

class _TambahTopikDialogState extends State<_TambahTopikDialog> {
  final _minggu = TextEditingController();
  final _nama = TextEditingController();

  DateTime _tanggal = DateTime.now();
  TimeOfDay _jam = TimeOfDay.now();

  @override
  void dispose() {
    _minggu.dispose();
    _nama.dispose();
    super.dispose();
  }

  String _formatTanggal(DateTime d) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (hasil != null) setState(() => _tanggal = hasil);
  }

  Future<void> _pilihJam() async {
    final hasil = await showTimePicker(context: context, initialTime: _jam);
    if (hasil != null) setState(() => _jam = hasil);
  }

  void _simpan() {
    final minggu = int.tryParse(_minggu.text.trim());

    if (minggu == null || _nama.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi minggu ke- dan nama topik dulu')),
      );
      return;
    }

    Navigator.pop(
      context,
      _Topik(
        minggu: minggu,
        nama: _nama.text.trim(),
        waktu: DateTime(
          _tanggal.year,
          _tanggal.month,
          _tanggal.day,
          _jam.hour,
          _jam.minute,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Minggu ke -',
                  style: AppTextStyle.headingSmall.copyWith(fontSize: 16),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 70,
                  child: _Kotak(
                    child: TextField(
                      controller: _minggu,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: '1',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const _Label('Nama Topik'),

            _Kotak(
              child: TextField(
                controller: _nama,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  hintText: 'Contoh: Persamaan Linear',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),

            const _Label('Tanggal dan Waktu'),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: _pilihTanggal,
                    borderRadius: BorderRadius.circular(10),
                    child: _Kotak(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          _formatTanggal(_tanggal),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: _pilihJam,
                    borderRadius: BorderRadius.circular(10),
                    child: _Kotak(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          '${_jam.hour.toString().padLeft(2, '0')}.'
                          '${_jam.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Center(
              child: SizedBox(
                width: 140,
                height: 42,
                child: ElevatedButton(
                  onPressed: _simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF219653),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// WIDGET KECIL PENDUKUNG
// =====================================================================

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

// Kotak putih dengan bayangan (dipakai input, dropdown, search).
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

class _Dropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _Kotak(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          style: const TextStyle(fontSize: 12, color: Colors.black),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _PilihanUpload extends StatelessWidget {
  final IconData icon;
  final Color warna;
  final String label;
  final VoidCallback onTap;

  const _PilihanUpload({
    required this.icon,
    required this.warna,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1EDEC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: warna),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}