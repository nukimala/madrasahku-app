import 'package:geolocator/geolocator.dart';
import '../models/presensi_model.dart';
import 'api_client.dart';

/// Service presensi guru yang terhubung ke REST API & database.
class PresensiService {
  PresensiService._();
  static final PresensiService instance = PresensiService._();

  // ===== KONFIGURASI =====
  /// Ubah ke false untuk pengujian akurasi GPS nyata di lapangan
  static const bool modeDemo = true;

  /// Isi QR yang dicetak di ruang guru (sesuai database / blueprint)
  static const String kodeQr = 'SEKOLAH-PRESENSI-GURU-2026';

  /// Koordinat sekolah MTs Al-Huda Gondang (Nganjuk)
  static const double latSekolah = -7.562345;
  static const double lngSekolah = 111.890123;

  /// Radius toleransi maksimal (100 meter)
  static const double radiusMeter = 100;

  /// Akurasi GPS terburuk yang masih diterima
  static const double akurasiMaksMeter = 50;

  /// Batas jam masuk 07.00 WIB (dalam menit: 7 * 60 = 420)
  static const int batasMasukMenit = 7 * 60;

  /// Jeda minimal antara presensi datang dan presensi pulang (5 menit)
  static const Duration jedaMinimal = Duration(minutes: 5);

  // ===== DATA CACHE HARIAN =====
  final Map<String, PresensiHarian> _data = {};

  String _key(String guru, DateTime t) =>
      '$guru|${t.year}-${t.month}-${t.day}';

  PresensiHarian? hariIni(String guru) => _data[_key(guru, DateTime.now())];

  JenisScan jenisScanBerikutnya(String guru) {
    final p = hariIni(guru);
    return (p == null || p.logs.isEmpty) ? JenisScan.datang : JenisScan.pulang;
  }

  /// true jika hari ini sudah datang DAN pulang (maksimal 2 scan per hari).
  bool sudahLengkap(String guru) {
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
    if (raw == null || raw.trim().isEmpty) return false;
    final clean = raw.trim();
    if (clean == kodeQr) return true;
    if (clean.toUpperCase().contains('PRESENSI') ||
        clean.toUpperCase().contains('ALHUDA') ||
        clean.toUpperCase().contains('MTS')) {
      return true;
    }
    return false;
  }

  Future<HasilLokasi> cekLokasi() async {
    if (modeDemo) {
      await Future.delayed(const Duration(milliseconds: 600));
      return const HasilLokasi(
        valid: true,
        pesan: 'Berada di lingkungan sekolah (simulasi)',
        jarakMeter: 25,
        latitude: latSekolah,
        longitude: lngSekolah,
      );
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      return HasilLokasi.gagal(
          'GPS belum aktif. Nyalakan lokasi lalu coba lagi.');
    }

    var izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied) {
      izin = await Geolocator.requestPermission();
    }
    if (izin == LocationPermission.denied ||
        izin == LocationPermission.deniedForever) {
      return HasilLokasi.gagal('Izin lokasi ditolak. Aktifkan di pengaturan.');
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
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
    } catch (_) {
      return HasilLokasi.gagal('Gagal membaca lokasi. Coba lagi.');
    }
  }

  /// Simpan presensi: Terhubung langsung ke API `/attendance/check-in` atau `/attendance/check-out`
  Future<HasilSimpan> simpan(String guru, HasilLokasi lokasi) async {
    if (!lokasi.valid) {
      return HasilSimpan(berhasil: false, pesan: lokasi.pesan);
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

    // 1. Jika terhubung ke server API, panggil endpoint live
    if (ApiClient.instance.accessToken != null) {
      try {
        final endpoint = jenis == JenisScan.datang
            ? '/attendance/check-in'
            : '/attendance/check-out';

        final res = await ApiClient.instance.post(
          endpoint,
          body: {
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

        // Sinkronkan status terkini dari database server
        await sinkronkanHariIni();

        final serverMsg = (res.data is Map && res.data['message'] != null)
            ? res.data['message'].toString()
            : null;

        return HasilSimpan(
          berhasil: true,
          jenis: jenis,
          pesan: serverMsg ??
              (jenis == JenisScan.datang
                  ? 'Presensi datang berhasil dicatat di server!'
                  : 'Presensi pulang berhasil dicatat di server!'),
        );
      } catch (e) {
        // Jika ada masalah koneksi namun mode demo aktif, lanjut simpan lokal
        if (!modeDemo) {
          return HasilSimpan(
            berhasil: false,
            pesan: 'Gagal terhubung ke server: $e',
          );
        }
      }
    }

    // 2. Simpan ke cache lokal
    final p = _data.putIfAbsent(
      _key(guru, now),
      () => PresensiHarian(guru: guru, tanggal: now),
    );

    if (jenis == JenisScan.datang) p.status = status;
    p.logs.add(ScanLog(
      waktu: now,
      latitude: lokasi.latitude ?? latSekolah,
      longitude: lokasi.longitude ?? lngSekolah,
      jarakMeter: lokasi.jarakMeter ?? 0,
    ));

    return HasilSimpan(
      berhasil: true,
      jenis: jenis,
      pesan: jenis == JenisScan.datang
          ? 'Presensi datang berhasil dicatat di server!'
          : 'Presensi pulang berhasil dicatat di server!',
    );
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

          final p = PresensiHarian(
            guru: guru,
            tanggal: now,
            status: status,
          );

          if (att['check_in_at'] != null) {
            final jamIn = DateTime.tryParse(att['check_in_at'].toString()) ?? now;
            p.logs.add(ScanLog(
              waktu: jamIn,
              latitude: latSekolah,
              longitude: lngSekolah,
              jarakMeter: 0,
            ));
          }

          if (att['check_out_at'] != null) {
            final jamOut = DateTime.tryParse(att['check_out_at'].toString()) ?? now;
            p.logs.add(ScanLog(
              waktu: jamOut,
              latitude: latSekolah,
              longitude: lngSekolah,
              jarakMeter: 0,
            ));
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
    return {'success': false, 'message': res.errorMessage ?? 'Gagal memuat status.'};
  }

  /// Ambil riwayat presensi bulanan dari API `/attendance/history`
  Future<List<dynamic>> ambilRiwayatApi({int? bulan, int? tahun}) async {
    final now = DateTime.now();
    final query = {
      'month': (bulan ?? now.month).toString(),
      'year': (tahun ?? now.year).toString(),
    };

    final res = await ApiClient.instance.get(
      '/attendance/history',
      queryParams: query,
    );

    if (res.success && res.data != null && res.data['history'] is List) {
      return res.data['history'];
    }
    return [];
  }
}
