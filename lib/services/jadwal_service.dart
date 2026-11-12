import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/jadwal_model.dart';
import 'api_client.dart';

class JadwalService {
  JadwalService._();

  static final JadwalService instance = JadwalService._();
  static const _storageKey = 'jadwal_pelajaran_v1';
  static const _schoolYearsStorageKey = 'jadwal_tahun_ajaran_v1';

  static const tahunAjaranTersedia = ['2026/2027', '2027/2028'];
  static const daftarKelas = ['7', '8A', '8B', '8C', '9A', '9B', '9C'];
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
    'M. Abdul Haris J., S.Pd.I',
    'Drs. Said',
    'Sulijadi, MM',
    'Drs. Sarmin',
    'M. Musthofa, S.Pd.I',
    'Farid Kurniawan N, SH',
    'Subiyatin, S.Si.',
    'Lilik Rahmawati., S.Pd.',
    'Agus Setiawan., S.Pd.',
    'Setyo Jatmiko., S.Pd.',
    'Sodikin Muslimin., S.Pd.',
    'Ulfatul Khumaydah, S.H.I',
    'Siti Amiroh, S.Pd.I',
    'Agus Budi Irawan., S.Pd.',
    'Siti Munfarida,S.Pd.I',
    'Faridatun Nikmah, S.Pd.I',
    'Intan Rosiana devi, S.Pd.',
    'Nur Fuad, MA',
    'Oktavia U.K, S.Pd',
    'Nurul Chofifah, S.Pd',
    'M. Syaban Wulana, S.Pd',
    'Winda Triyana, S.Pd',
    'Nopi Purwanti, S.Pd',
    'Kumala Azizatul L., S.Pd',
    'Titik Yuliati, S.Pd',
  ];
  static const daftarRuang = [
    'Ruang 1',
    'Ruang 2',
    'Ruang 3',
    'Ruang 4',
    'Ruang 5',
  ];

  final List<JadwalPelajaran> _jadwal = [];
  final Set<String> _tahunAjaranTambahan = {};
  int _nextId = 1;
  bool _loaded = false;

  List<String> get daftarTahunAjaran => {
    ...tahunAjaranTersedia,
    ..._tahunAjaranTambahan,
    ..._jadwal.map((item) => item.tahunAjaran),
  }.toList()..sort(_compareSchoolYear);

  int get jumlahJadwalTersimpan => _jadwal.length;

  Future<void> load() async {
    if (_loaded) return;

    final preferences = await SharedPreferences.getInstance();
    _tahunAjaranTambahan.addAll(
      preferences.getStringList(_schoolYearsStorageKey) ?? const [],
    );
    final stored = preferences.getString(_storageKey);
    if (stored != null && stored.isNotEmpty) {
      final decoded = jsonDecode(stored);
      if (decoded is! List) {
        throw const FormatException('Data jadwal tersimpan tidak valid.');
      }
      _jadwal
        ..clear()
        ..addAll(
          decoded.map(
            (item) => JadwalPelajaran.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          ),
        );
      _nextId = _jadwal.fold<int>(
        1,
        (next, item) => item.id >= next ? item.id + 1 : next,
      );
    }
    _loaded = true;
  }

  Future<bool> tambahTahunAjaran(String tahunAjaran) async {
    _ensureLoaded();
    final normalized = tahunAjaran.trim();
    final match = RegExp(r'^(\d{4})/(\d{4})$').firstMatch(normalized);
    if (match == null) {
      throw const FormatException('Gunakan format tahun ajaran YYYY/YYYY.');
    }

    final tahunMulai = int.parse(match.group(1)!);
    final tahunSelesai = int.parse(match.group(2)!);
    if (tahunSelesai != tahunMulai + 1) {
      throw const FormatException(
        'Tahun ajaran harus mencakup dua tahun berurutan, misalnya 2028/2029.',
      );
    }
    if (daftarTahunAjaran.contains(normalized)) return false;

    final updatedYears = {..._tahunAjaranTambahan, normalized};
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setStringList(
      _schoolYearsStorageKey,
      updatedYears.toList()..sort(_compareSchoolYear),
    );
    if (!saved) {
      throw StateError('Tahun ajaran tidak berhasil disimpan.');
    }
    _tahunAjaranTambahan
      ..clear()
      ..addAll(updatedYears);
    return true;
  }

  /// Ambil jadwal live dari REST API backend `/schedules`
  Future<List<JadwalPelajaran>> ambilJadwalApi({int? hari}) async {
    final params = <String, String>{};
    if (hari != null) params['day'] = hari.toString();

    final res = await ApiClient.instance.get('/schedules', queryParams: params);

    if (res.success && res.data != null && res.data['schedules'] is List) {
      final list = res.data['schedules'] as List;
      final result = list.map((item) => _parseJadwalJson(item)).toList();
      result.sort(_compareTime);
      return result;
    }

    return [];
  }

  JadwalPelajaran _parseJadwalJson(dynamic json) {
    int parseMenit(String? timeStr) {
      if (timeStr == null || !timeStr.contains(':')) return 0;
      final parts = timeStr.split(':');
      return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
    }

    HariSekolah parseHari(dynamic h) {
      final str = h.toString().toLowerCase();
      if (str.contains('senin') || str == '1') return HariSekolah.senin;
      if (str.contains('selasa') || str == '2') return HariSekolah.selasa;
      if (str.contains('rabu') || str == '3') return HariSekolah.rabu;
      if (str.contains('kamis') || str == '4') return HariSekolah.kamis;
      if (str.contains('jumat') || str == '5') return HariSekolah.jumat;
      return HariSekolah.sabtu;
    }

    return JadwalPelajaran(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      tahunAjaran: json['academic_year'] ?? '2026/2027',
      semester: (json['semester'] == '2' || json['semester'] == 'genap')
          ? Semester.genap
          : Semester.ganjil,
      kelas: json['class_name'] ?? json['kelas'] ?? '',
      hari: parseHari(json['day_name'] ?? json['day_of_week']),
      mulaiMenit: parseMenit(json['start_time']),
      selesaiMenit: parseMenit(json['end_time']),
      mataPelajaran: json['subject_name'] ?? json['mapel'] ?? '',
      guru: json['teacher_name'] ?? json['guru'] ?? '',
      ruang: json['room'] ?? 'Ruang Kelas',
    );
  }

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
      .where(
        (item) =>
            item.guru.split('/').map((nama) => nama.trim()).contains(guru) &&
            (hari == null || item.hari == hari),
      )
      .toList();

  Future<String?> simpan(JadwalPelajaran jadwal, {int? kecualiId}) async {
    _ensureLoaded();
    final saved = jadwal.copyWith(id: kecualiId ?? _nextId);
    final error = _cekBentrok(saved, kecualiId: kecualiId);
    if (error != null) return error;

    final schedules = [..._jadwal];
    final index = schedules.indexWhere((item) => item.id == saved.id);
    if (index == -1) {
      schedules.add(saved);
    } else {
      schedules[index] = saved;
    }
    await _save(schedules);
    if (kecualiId == null) _nextId++;
    return null;
  }

  Future<void> hapus(int id) async {
    _ensureLoaded();
    final schedules = _jadwal.where((item) => item.id != id).toList();
    if (schedules.length == _jadwal.length) return;
    await _save(schedules);
  }

  Future<int> hapusSemua() async {
    _ensureLoaded();
    final deleted = _jadwal.length;
    if (deleted == 0) return 0;
    await _save([]);
    return deleted;
  }

  Future<JadwalSalinHasil> salinHari({
    required String tahunAjaran,
    required Semester semester,
    required String kelas,
    required HariSekolah dariHari,
    required HariSekolah keHari,
  }) async {
    _ensureLoaded();
    if (dariHari == keHari) {
      return const JadwalSalinHasil(tersalin: 0, dilewati: 0);
    }

    final sources = jadwalKelas(
      tahunAjaran: tahunAjaran,
      semester: semester,
      kelas: kelas,
      hari: dariHari,
    );
    final schedules = [..._jadwal];
    var nextId = _nextId;
    var copied = 0;
    var skipped = 0;

    for (final item in sources) {
      final candidate = item.copyWith(id: nextId, hari: keHari);
      if (_cekBentrok(candidate, jadwalTerdaftar: schedules) != null) {
        skipped++;
        continue;
      }
      schedules.add(candidate);
      nextId++;
      copied++;
    }

    if (copied > 0) {
      await _save(schedules);
      _nextId = nextId;
    }
    return JadwalSalinHasil(tersalin: copied, dilewati: skipped);
  }

  Future<int> gantiJadwal({
    required String tahunAjaran,
    required Semester semester,
    required List<JadwalPelajaran> jadwalBaru,
  }) async {
    _ensureLoaded();
    if (jadwalBaru.isEmpty) {
      throw const FormatException('Tidak ada jadwal valid untuk diimpor.');
    }
    if (jadwalBaru.any(
      (item) => item.tahunAjaran != tahunAjaran || item.semester != semester,
    )) {
      throw const FormatException(
        'Periode jadwal impor tidak sesuai dengan pilihan.',
      );
    }

    final schedules = _jadwal
        .where(
          (item) =>
              item.tahunAjaran != tahunAjaran || item.semester != semester,
        )
        .toList();
    var nextId = _nextId;
    for (final item in jadwalBaru) {
      schedules.add(item.copyWith(id: nextId++));
    }

    _tahunAjaranTambahan.add(tahunAjaran);
    await _save(schedules);
    _nextId = nextId;
    return jadwalBaru.length;
  }

  Future<void> _save(List<JadwalPelajaran> schedules) async {
    final preferences = await SharedPreferences.getInstance();
    final savedYears = await preferences.setStringList(
      _schoolYearsStorageKey,
      _tahunAjaranTambahan.toList()..sort(_compareSchoolYear),
    );
    if (!savedYears) {
      throw StateError('Daftar tahun ajaran tidak berhasil disimpan.');
    }
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(schedules.map((item) => item.toJson()).toList()),
    );
    if (!saved) {
      throw StateError('Jadwal tidak berhasil disimpan ke perangkat.');
    }
    _jadwal
      ..clear()
      ..addAll(schedules);
  }

  String? _cekBentrok(
    JadwalPelajaran jadwal, {
    int? kecualiId,
    List<JadwalPelajaran>? jadwalTerdaftar,
  }) {
    if (jadwal.mulaiMenit != null &&
        jadwal.selesaiMenit != null &&
        jadwal.selesaiMenit! <= jadwal.mulaiMenit!) {
      return 'Jam selesai harus setelah jam mulai.';
    }

    for (final existing in jadwalTerdaftar ?? _jadwal) {
      if (existing.id == kecualiId ||
          existing.tahunAjaran != jadwal.tahunAjaran ||
          existing.semester != jadwal.semester ||
          existing.hari != jadwal.hari ||
          jadwal.mulaiMenit == null ||
          jadwal.selesaiMenit == null ||
          existing.mulaiMenit == null ||
          existing.selesaiMenit == null) {
        continue;
      }

      final overlaps =
          jadwal.mulaiMenit! < existing.selesaiMenit! &&
          existing.mulaiMenit! < jadwal.selesaiMenit!;
      if (!overlaps) continue;

      if (jadwal.kelas != null &&
          jadwal.kelas == existing.kelas &&
          jadwal.kelas!.isNotEmpty) {
        return 'Kelas ${jadwal.kelas} sudah memiliki jadwal pada waktu tersebut.';
      }
      if (jadwal.guru == existing.guru) {
        return '${jadwal.guru} sudah mengajar pada waktu tersebut.';
      }
      if (jadwal.ruang != null &&
          jadwal.ruang == existing.ruang &&
          jadwal.ruang!.isNotEmpty) {
        return '${jadwal.ruang} sedang digunakan pada waktu tersebut.';
      }
    }

    return null;
  }

  void _ensureLoaded() {
    if (!_loaded) {
      throw StateError('JadwalService.load() harus selesai sebelum digunakan.');
    }
  }

  static int _compareTime(JadwalPelajaran a, JadwalPelajaran b) {
    final dayOrder = a.hari.index.compareTo(b.hari.index);
    if (dayOrder != 0) return dayOrder;
    if (a.mulaiMenit != null && b.mulaiMenit != null) {
      return a.mulaiMenit!.compareTo(b.mulaiMenit!);
    }
    if (a.jamKe != null && b.jamKe != null) {
      final aPeriod = int.tryParse(a.jamKe!);
      final bPeriod = int.tryParse(b.jamKe!);
      if (aPeriod != null && bPeriod != null) {
        return aPeriod.compareTo(bPeriod);
      }
      return a.jamKe!.compareTo(b.jamKe!);
    }
    return a.mataPelajaran.compareTo(b.mataPelajaran);
  }

  static int _compareSchoolYear(String a, String b) {
    final aStart = int.tryParse(a.split('/').first);
    final bStart = int.tryParse(b.split('/').first);
    if (aStart != null && bStart != null) return aStart.compareTo(bStart);
    return a.compareTo(b);
  }
}

class JadwalSalinHasil {
  final int tersalin;
  final int dilewati;

  const JadwalSalinHasil({required this.tersalin, required this.dilewati});
}
