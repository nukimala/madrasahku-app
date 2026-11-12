import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aplikasimadrasahku/models/jadwal_model.dart';
import 'package:aplikasimadrasahku/screens/admin/jadwal/data_jadwal_page.dart';
import 'package:aplikasimadrasahku/services/jadwal_service.dart';

void main() {
  testWidgets('shows schedules without requiring class or room', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = JadwalService.instance;
    await service.load();
    await service.gantiJadwal(
      tahunAjaran: '2026/2027',
      semester: Semester.ganjil,
      jadwalBaru: const [
        JadwalPelajaran(
          id: 0,
          tahunAjaran: '2026/2027',
          semester: Semester.ganjil,
          hari: HariSekolah.senin,
          mulaiMenit: null,
          selesaiMenit: null,
          jamKe: 'UPC',
          mataPelajaran: 'Upacara',
          guru: 'Guru Piket',
        ),
      ],
    );

    await tester.pumpWidget(const MaterialApp(home: DataJadwalPage()));
    await tester.pumpAndSettle();

    expect(find.text('Atur dan tinjau jadwal pelajaran'), findsOneWidget);
    expect(find.text('Upacara'), findsOneWidget);
    expect(find.text('Jam UPC'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('admin can add an academic year from the year selector', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = JadwalService.instance;
    await service.load();

    await tester.pumpWidget(const MaterialApp(home: DataJadwalPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tambah tahun ajaran'));
    await tester.pumpAndSettle();

    expect(find.text('Tambah tahun ajaran'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '2030/2031');
    await tester.tap(find.text('Tambah').last);
    await tester.pumpAndSettle();

    expect(service.daftarTahunAjaran, contains('2030/2031'));
    expect(find.text('2030/2031'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('admin can delete all schedules from the schedule page', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final service = JadwalService.instance;
    await service.load();
    await service.gantiJadwal(
      tahunAjaran: '2026/2027',
      semester: Semester.ganjil,
      jadwalBaru: const [
        JadwalPelajaran(
          id: 0,
          tahunAjaran: '2026/2027',
          semester: Semester.ganjil,
          hari: HariSekolah.senin,
          mulaiMenit: 420,
          selesaiMenit: 460,
          mataPelajaran: 'Matematika',
          guru: 'Guru Matematika',
        ),
      ],
    );

    await tester.pumpWidget(const MaterialApp(home: DataJadwalPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Hapus semua jadwal'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<AlertDialog>(find.byType(AlertDialog)).backgroundColor,
      Colors.white,
    );
    expect(
      find.text(
        'Semua jadwal dari seluruh tahun ajaran dan semester akan dihapus.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Hapus semua'));
    await tester.pumpAndSettle();

    expect(service.jumlahJadwalTersimpan, 0);
    expect(find.text('1 jadwal berhasil dihapus.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
