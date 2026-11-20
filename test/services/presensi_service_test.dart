import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasimadrasahku/models/presensi_model.dart';
import 'package:aplikasimadrasahku/services/api_client.dart';
import 'package:aplikasimadrasahku/services/presensi_service.dart';

void main() {
  test('hanya menerima token QR resmi sekolah', () {
    final service = PresensiService.instance;

    expect(service.validasiQr(PresensiService.kodeQr), isTrue);
    expect(service.validasiQr('MTS-ALHUDA barcode palsu'), isFalse);
    expect(service.validasiQr(null), isFalse);
  });

  test('presensi tidak dianggap berhasil tanpa sesi API online', () async {
    ApiClient.instance.clearTokens();
    const guru = 'Guru Tes Rekap Lokal';

    final hasil = await PresensiService.instance.simpan(
      guru,
      const HasilLokasi(
        valid: true,
        pesan: 'Lokasi valid',
        latitude: -7.5,
        longitude: 111.8,
      ),
      qrToken: PresensiService.kodeQr,
    );

    expect(hasil.berhasil, isFalse);
    expect(hasil.pesan, contains('Sesi online'));

    final catatan = PresensiService.instance
        .ambilRekapLokal()
        .where((item) => item['teacher_name'] == guru)
        .toList();
    expect(catatan, isEmpty);
  });
}
