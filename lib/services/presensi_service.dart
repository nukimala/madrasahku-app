import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:geolocator/geolocator.dart';
import '../models/presensi_model.dart';
import 'api_client.dart';
import 'auth_service.dart';

/// Service presensi guru yang terhubung ke REST API & database.
class PresensiService {
  PresensiService._();
  static final PresensiService instance = PresensiService._();

  // ===== KONFIGURASI =====
  /// Isi QR yang dicetak di ruang guru (sesuai database / blueprint)
  static const String kodeQr = 'MTS-ALHUDA-ABSENSI-2026-SECURE';

  /// Koordinat sekolah MTs Al-Huda Gondang (Nganjuk)
  static const double latSekolah = -7.606797;
  static const double lngSekolah = 111.902016;

  /// Radius toleransi maksimal sesuai konfigurasi lokasi sekolah di database.
  static const double radiusMeter = 20;

  /// Akurasi GPS terburuk yang masih diterima
  static const double akurasiMaksMeter = 50;

  /// Batas jam masuk 07.00 WIB (dalam menit: 7 * 60 = 420)
  static const int batasMasukMenit = 7 * 60;

  /// Jeda minimal antara presensi datang dan presensi pulang (5 menit)
  static const Duration jedaMinimal = Duration(minutes: 5);
  static const bool _abaikanBatasHarian = kDebugMode;

  // ===== DATA CACHE HARIAN =====
  final Map<String, PresensiHarian> _data = {};

  String _key(String guru, DateTime t) => '$guru|${t.year}-${t.month}-${t.day}';

  PresensiHarian? hariIni(String guru) => _data[_key(guru, DateTime.now())];

  List<Map<String, dynamic>> ambilRekapLokal() {
    return _data.values.map((presensi) {
      return {
        'teacher_name': presensi.guru,
        'attendance_date':
            '${presensi.tanggal.year}-${presensi.tanggal.month.toString().padLeft(2, '0')}-${presensi.tanggal.day.toString().padLeft(2, '0')}',
        'check_in_at': presensi.jamDatang?.toIso8601String(),
        'check_out_at': presensi.jamPulang?.toIso8601String(),
        'mapel': 'Umum',
        'kelas': 'Semua Kelas',
      };
    }).toList();
  }

  JenisScan jenisScanBerikutnya(String guru) {
    final p = hariIni(guru);
    return (p == null || p.logs.isEmpty) ? JenisScan.datang : JenisScan.pulang;
  }

  /// true jika hari ini sudah datang DAN pulang (maksimal 2 scan per hari).
  bool sudahLengkap(String guru) {
    if (_abaikanBatasHarian) return false;
    final p = hariIni(guru);
    return p != null && p.logs.length >= 2;
  }

  /// Format sisa jeda, contoh: "4 menit 30 detik".
  String formatSisa(Duration d) {
    final menit = d.inMinutes;
    final detik = d.inSeconds % 60;
    if (menit == 0) return '$detik detik';
    return '$menit menit $detik detik';
  }

  /// Status jika guru scan sekarang (dipakai untuk tampilan konfirmasi).
  StatusPresensi statusJikaScanSekarang(String guru) {
    final p = hariIni(guru);
    if (p != null && p.logs.isNotEmpty) return p.status;
    final now = DateTime.now();
    final menit = now.hour * 60 + now.minute;
    return menit <= batasMasukMenit
        ? StatusPresensi.tepatWaktu
        : StatusPresensi.terlambat;
  }

  /// Sisa waktu tunggu sebelum boleh scan lagi (null = boleh).
  Duration? sisaJeda(String guru) {
    final p = hariIni(guru);
    if (p == null || p.logs.isEmpty) return null;
    final selisih = DateTime.now().difference(p.logs.last.waktu);
    return selisih >= jedaMinimal ? null : jedaMinimal - selisih;
  }

  bool validasiQr(String? raw) {
    return raw != null && raw.trim() == kodeQr;
  }

  Future<HasilLokasi> cekLokasi() async {
    try {
      return await _cekLokasi().timeout(
        const Duration(seconds: 12),
        onTimeout: () => HasilLokasi.gagal(
          'Pemeriksaan lokasi melewati 12 detik. Pastikan GPS dan izin lokasi aktif, lalu coba lagi.',
        ),
      );
    } catch (e) {
      return HasilLokasi.gagal('Gagal memeriksa lokasi: $e');
    }
  }

  Future<HasilLokasi> _cekLokasi() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return HasilLokasi.gagal(
        'GPS belum aktif. Nyalakan lokasi lalu coba lagi.',
      );
    }

    var izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied) {
      izin = await Geolocator.requestPermission();
    }
    if (izin == LocationPermission.denied ||
        izin == LocationPermission.deniedForever) {
      return HasilLokasi.gagal('Izin lokasi ditolak. Aktifkan di pengaturan.');
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );

    if (pos.isMocked) {
      return HasilLokasi.gagal('Lokasi palsu (fake GPS) terdeteksi.');
    }
    if (pos.accuracy > akurasiMaksMeter) {
      return HasilLokasi.gagal(
        'Sinyal GPS lemah (akurasi ${pos.accuracy.round()} m). '
        'Coba lagi di tempat terbuka.',
      );
    }

    final jarak = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      latSekolah,
      lngSekolah,
    );

    if (jarak > radiusMeter) {
      return HasilLokasi.gagal(
        'Anda ${jarak.round()} m dari sekolah (maks ${radiusMeter.round()} m).',
        jarakMeter: jarak,
      );
    }

    return HasilLokasi(
      valid: true,
      pesan: 'Berada di lingkungan sekolah',
      jarakMeter: jarak,
      latitude: pos.latitude,
      longitude: pos.longitude,
    );
  }

  /// Simpan presensi melalui API `/attendance/check-in` atau `/attendance/check-out`.
  Future<HasilSimpan> simpan(
    String guru,
    HasilLokasi lokasi, {
    required String qrToken,
  }) async {
    if (!lokasi.valid) {
      return HasilSimpan(berhasil: false, pesan: lokasi.pesan);
    }
    if (!validasiQr(qrToken)) {
      return const HasilSimpan(
        berhasil: false,
        pesan: 'QR presensi tidak valid. Scan ulang QR resmi sekolah.',
      );
    }
    final accessToken = ApiClient.instance.accessToken;
    if (accessToken == null || accessToken.trim().isEmpty) {
      return const HasilSimpan(
        berhasil: false,
        pesan: 'Sesi online tidak tersedia. Login kembali saat internet aktif.',
      );
    }
    if (sudahLengkap(guru)) {
      return const HasilSimpan(
        berhasil: false,
        pesan: 'Presensi hari ini sudah lengkap (datang dan pulang).',
      );
    }
    final sisa = sisaJeda(guru);
    if (sisa != null) {
      return HasilSimpan(
        berhasil: false,
        pesan: 'Tunggu ${formatSisa(sisa)} sebelum presensi pulang.',
      );
    }

    final jenis = jenisScanBerikutnya(guru);
    final status = statusJikaScanSekarang(guru);
    final now = DateTime.now();

    final endpoint = jenis == JenisScan.datang
        ? '/attendance/check-in'
        : '/attendance/check-out';

    try {
      final res = await ApiClient.instance.post(
        endpoint,
        body: {
          'qr_token': qrToken.trim(),
          'latitude': lokasi.latitude ?? latSekolah,
          'longitude': lokasi.longitude ?? lngSekolah,
          'notes': 'Presensi via Aplikasi Madrasahku Mobile',
        },
      );

      if (!res.success) {
        return HasilSimpan(
          berhasil: false,
          pesan: res.errorMessage ?? 'Gagal mencatat presensi di server.',
        );
      }

      // Simpan status server ke cache agar alur scan berikutnya tetap konsisten.
      final p = _data.putIfAbsent(
        _key(guru, now),
        () => PresensiHarian(guru: guru, tanggal: now),
      );
      if (jenis == JenisScan.datang) p.status = status;
      p.logs.add(
        ScanLog(
          waktu: now,
          latitude: lokasi.latitude ?? latSekolah,
          longitude: lokasi.longitude ?? lngSekolah,
          jarakMeter: lokasi.jarakMeter ?? 0,
        ),
      );

      final serverMsg = (res.data is Map && res.data['message'] != null)
          ? res.data['message'].toString()
          : null;
      return HasilSimpan(
        berhasil: true,
        jenis: jenis,
        pesan:
            serverMsg ??
            (jenis == JenisScan.datang
                ? 'Presensi datang berhasil dicatat di server!'
                : 'Presensi pulang berhasil dicatat di server!'),
      );
    } catch (e) {
      return HasilSimpan(
        berhasil: false,
        pesan: 'Gagal terhubung ke server: $e',
      );
    }
  }

  /// Sinkronkan status presensi hari ini dari database server ke cache lokal
  Future<void> sinkronkanHariIni() async {
    if (ApiClient.instance.accessToken == null) return;
    try {
      final res = await ApiClient.instance.get('/attendance/today');
      if (res.success && res.data is Map<String, dynamic>) {
        final d = res.data as Map<String, dynamic>;
        final att = d['daily_attendance'] ?? d['today_attendance'];
        final guru = AuthService.instance.currentTeacherName ?? 'Guru';
        final now = DateTime.now();

        if (att is Map<String, dynamic>) {
          final statusStr = (att['status'] ?? '').toString().toLowerCase();
          final status = statusStr.contains('tepat')
              ? StatusPresensi.tepatWaktu
              : StatusPresensi.terlambat;

          final p = PresensiHarian(guru: guru, tanggal: now, status: status);

          if (att['check_in_at'] != null) {
            final jamIn =
                DateTime.tryParse(att['check_in_at'].toString()) ?? now;
            p.logs.add(
              ScanLog(
                waktu: jamIn,
                latitude: latSekolah,
                longitude: lngSekolah,
                jarakMeter: 0,
              ),
            );
          }

          if (att['check_out_at'] != null) {
            final jamOut =
                DateTime.tryParse(att['check_out_at'].toString()) ?? now;
            p.logs.add(
              ScanLog(
                waktu: jamOut,
                latitude: latSekolah,
                longitude: lngSekolah,
                jarakMeter: 0,
              ),
            );
          }

          _data[_key(guru, now)] = p;
        }
      }
    } catch (_) {}
  }

  /// Ambil status presensi hari ini langsung dari API `/attendance/today`
  Future<Map<String, dynamic>> ambilPresensiHariIniApi() async {
    final res = await ApiClient.instance.get('/attendance/today');
    if (res.success && res.data != null) {
      return {'success': true, 'data': res.data};
    }
    return {
      'success': false,
      'message': res.errorMessage ?? 'Gagal memuat status.',
    };
  }

  /// Ambil riwayat presensi bulanan dari API `/attendance/history`
  Future<List<dynamic>> ambilRiwayatApi({int? bulan, int? tahun}) async {
    final now = DateTime.now();
    final b = (bulan ?? now.month).toString().padLeft(2, '0');
    final t = (tahun ?? now.year).toString();
    final query = {'month': '$t-$b'};

    final res = await ApiClient.instance.get(
      '/attendance/history',
      queryParams: query,
    );

    if (res.success && res.data != null) {
      if (res.data['items'] is List) return res.data['items'];
      if (res.data['history'] is List) return res.data['history'];
    }
    return [];
  }

  /// Ambil rekapitulasi presensi admin dari API `/attendance/recap`
  Future<List<dynamic>> ambilRekapAdminApi({
    String? month,
    DateTime? startDate,
    DateTime? endDate,
    String? mapel,
    String? kelas,
  }) async {
    final query = <String, String>{};
    if (month != null && month.isNotEmpty && month != 'semua') {
      query['month'] = month;
    }
    if (startDate != null) {
      query['start_date'] =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    }
    if (endDate != null) {
      query['end_date'] =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    }
    if (mapel != null && mapel.isNotEmpty && mapel != 'Semua Mapel') {
      query['mapel'] = mapel;
    }
    if (kelas != null && kelas.isNotEmpty && kelas != 'Semua Kelas') {
      query['kelas'] = kelas;
    }

    try {
      final res = await ApiClient.instance.get(
        '/attendance/recap',
        queryParams: query.isNotEmpty ? query : null,
      );

      if (res.success && res.data != null) {
        if (res.data is List) return res.data as List;
        if (res.data is Map && res.data['data'] is List) {
          return res.data['data'] as List;
        }
        if (res.data is Map && res.data['items'] is List) {
          return res.data['items'] as List;
        }
      }
    } catch (_) {}

    return [];
  }
}
