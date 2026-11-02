import 'package:geolocator/geolocator.dart';

import '../models/presensi_model.dart';

/// Service presensi guru (data dummy, tersimpan di memori).
/// Nanti tinggal diganti ke Firebase/API tanpa mengubah UI.
class PresensiService {
  PresensiService._();
  static final PresensiService instance = PresensiService._();

  // ===== KONFIGURASI (ganti sesuai sekolah) =====

  /// true = lokasi disimulasikan "di sekolah" (untuk emulator/testing).
  /// WAJIB diubah ke false sebelum dipakai sungguhan.
  static const bool modeDemo = true;

  /// Isi QR yang dicetak di ruang guru.
  static const String kodeQr = 'SEKOLAH-PRESENSI-GURU-2026';

  /// Koordinat sekolah (DUMMY: sekitar Nganjuk). Ganti dengan koordinat asli
  /// dari Google Maps (klik kanan di titik ruang guru -> salin koordinat).
  static const double latSekolah = -7.6051;
  static const double lngSekolah = 111.9035;

  /// Radius yang direkomendasikan.
  static const double radiusMeter = 100;

  /// Akurasi GPS terburuk yang masih diterima.
  static const double akurasiMaksMeter = 50;

  /// Batas jam masuk 07.00 (dalam menit).
  static const int batasMasukMenit = 7 * 60;

  /// Jeda minimal antara presensi datang dan presensi pulang.
  static const Duration jedaMinimal = Duration(minutes: 5);

  // ===== DATA DUMMY =====
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

  bool validasiQr(String? raw) => raw?.trim() == kodeQr;

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
      return HasilLokasi.gagal('GPS belum aktif. Nyalakan lokasi lalu coba lagi.');
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

    await Future.delayed(const Duration(milliseconds: 400));

    final jenis = jenisScanBerikutnya(guru);
    final status = statusJikaScanSekarang(guru);
    final now = DateTime.now();
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
          ? 'Presensi datang berhasil dicatat.'
          : 'Presensi pulang berhasil dicatat.',
    );
  }
}