enum StatusPresensi { belumPresensi, tepatWaktu, terlambat }

enum JenisScan { datang, pulang }

/// Satu kali scan QR (bukti untuk audit).
class ScanLog {
  final DateTime waktu;
  final double latitude;
  final double longitude;
  final double jarakMeter;

  const ScanLog({
    required this.waktu,
    required this.latitude,
    required this.longitude,
    required this.jarakMeter,
  });
}

/// Satu hari = satu dokumen presensi berisi daftar scan log.
/// Scan pertama = datang, scan terakhir (setelahnya) = pulang.
class PresensiHarian {
  final String guru;
  final DateTime tanggal;
  final List<ScanLog> logs;
  StatusPresensi status;

  PresensiHarian({
    required this.guru,
    required this.tanggal,
    List<ScanLog>? logs,
    this.status = StatusPresensi.belumPresensi,
  }) : logs = logs ?? [];

  DateTime? get jamDatang => logs.isEmpty ? null : logs.first.waktu;
  DateTime? get jamPulang => logs.length > 1 ? logs.last.waktu : null;
}

/// Hasil pengecekan lokasi.
class HasilLokasi {
  final bool valid;
  final String pesan;
  final double? jarakMeter;
  final double? latitude;
  final double? longitude;

  const HasilLokasi({
    required this.valid,
    required this.pesan,
    this.jarakMeter,
    this.latitude,
    this.longitude,
  });

  factory HasilLokasi.gagal(String pesan, {double? jarakMeter}) =>
      HasilLokasi(valid: false, pesan: pesan, jarakMeter: jarakMeter);
}

/// Hasil menyimpan presensi.
class HasilSimpan {
  final bool berhasil;
  final String pesan;
  final JenisScan? jenis;

  const HasilSimpan({required this.berhasil, required this.pesan, this.jenis});
}