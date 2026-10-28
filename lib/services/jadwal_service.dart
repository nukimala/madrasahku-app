import '../models/jadwal_model.dart';

class JadwalService {
  JadwalService._();

  static final JadwalService instance = JadwalService._();

  static const tahunAjaranTersedia = ['2026/2027', '2027/2028'];
  static const daftarKelas = [
    'VII A',
    'VII B',
    'VIII A',
    'VIII B',
    'VIII C',
    'IX A',
    'IX B',
  ];
  static const daftarMapel = [
    'Al-Qur’an Hadis',
    'Akidah Akhlak',
    'Fikih',
    'Sejarah Kebudayaan Islam (SKI)',
    'Bahasa Arab',
    'Pendidikan Pancasila',
    'Bahasa Indonesia',
    'Matematika',
    'Ilmu Pengetahuan Alam (IPA)',
    'Ilmu Pengetahuan Sosial (IPS)',
    'Bahasa Inggris',
    'Seni Budaya',
    'Pendidikan Jasmani, Olahraga, dan Kesehatan (PJOK)',
    'Informatika/Keterampilan',
  ];
  static const daftarGuru = [
    'Ahmad Fauzi',
    'Siti Nurhaliza',
    'Budi Santoso',
    'Nur Aini',
    'Rizky Maulana',
  ];
  static const daftarRuang = [
    'Ruang 1',
    'Ruang 2',
    'Ruang 3',
    'Ruang 4',
    'Ruang 5',
  ];

  final List<JadwalPelajaran> _jadwal = [];
  int _nextId = 1;

  List<JadwalPelajaran> semuaJadwal({
    required String tahunAjaran,
    required Semester semester,
  }) =>
      _jadwal
          .where(
            (item) =>
                item.tahunAjaran == tahunAjaran && item.semester == semester,
          )
          .toList()
        ..sort(_compareTime);

  List<JadwalPelajaran> jadwalKelas({
    required String tahunAjaran,
    required Semester semester,
    required String kelas,
    HariSekolah? hari,
  }) => semuaJadwal(tahunAjaran: tahunAjaran, semester: semester)
      .where(
        (item) => item.kelas == kelas && (hari == null || item.hari == hari),
      )
      .toList();

  List<JadwalPelajaran> jadwalGuru({
    required String tahunAjaran,
    required Semester semester,
    required String guru,
    HariSekolah? hari,
  }) => semuaJadwal(tahunAjaran: tahunAjaran, semester: semester)
      .where((item) => item.guru == guru && (hari == null || item.hari == hari))
      .toList();

  String? simpan(JadwalPelajaran jadwal, {int? kecualiId}) {
    final error = _cekBentrok(jadwal, kecualiId: kecualiId);
    if (error != null) return error;

    final saved = jadwal.copyWith(id: kecualiId ?? _nextId++);
    final index = _jadwal.indexWhere((item) => item.id == saved.id);
    if (index == -1) {
      _jadwal.add(saved);
    } else {
      _jadwal[index] = saved;
    }
    return null;
  }

  void hapus(int id) {
    _jadwal.removeWhere((item) => item.id == id);
  }

  JadwalSalinHasil salinHari({
    required String tahunAjaran,
    required Semester semester,
    required String kelas,
    required HariSekolah dariHari,
    required HariSekolah keHari,
  }) {
    if (dariHari == keHari) {
      return const JadwalSalinHasil(tersalin: 0, dilewati: 0);
    }

    final sumber = jadwalKelas(
      tahunAjaran: tahunAjaran,
      semester: semester,
      kelas: kelas,
      hari: dariHari,
    );
    var tersalin = 0;
    var dilewati = 0;

    for (final item in sumber) {
      final kandidat = item.copyWith(id: _nextId, hari: keHari);
      if (_cekBentrok(kandidat) != null) {
        dilewati++;
        continue;
      }
      _jadwal.add(kandidat);
      _nextId++;
      tersalin++;
    }

    return JadwalSalinHasil(tersalin: tersalin, dilewati: dilewati);
  }

  String? _cekBentrok(JadwalPelajaran jadwal, {int? kecualiId}) {
    if (jadwal.selesaiMenit <= jadwal.mulaiMenit) {
      return 'Jam selesai harus setelah jam mulai.';
    }

    for (final existing in _jadwal) {
      if (existing.id == kecualiId ||
          existing.tahunAjaran != jadwal.tahunAjaran ||
          existing.semester != jadwal.semester ||
          existing.hari != jadwal.hari) {
        continue;
      }

      final waktunyaBertumpuk =
          jadwal.mulaiMenit < existing.selesaiMenit &&
          existing.mulaiMenit < jadwal.selesaiMenit;
      if (!waktunyaBertumpuk) continue;

      if (existing.kelas == jadwal.kelas) {
        return 'Kelas ${jadwal.kelas} sudah memiliki jadwal pada waktu tersebut.';
      }
      if (existing.guru == jadwal.guru) {
        return '${jadwal.guru} sudah mengajar kelas ${existing.kelas} pada waktu tersebut.';
      }
      if (existing.ruang == jadwal.ruang) {
        return '${jadwal.ruang} sedang digunakan kelas ${existing.kelas} pada waktu tersebut.';
      }
    }

    return null;
  }

  static int _compareTime(JadwalPelajaran a, JadwalPelajaran b) {
    final dayOrder = a.hari.index.compareTo(b.hari.index);
    return dayOrder != 0 ? dayOrder : a.mulaiMenit.compareTo(b.mulaiMenit);
  }
}

class JadwalSalinHasil {
  final int tersalin;
  final int dilewati;

  const JadwalSalinHasil({required this.tersalin, required this.dilewati});
}
