import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasimadrasahku/models/jadwal_model.dart';
import 'package:aplikasimadrasahku/services/jadwal_excel_importer.dart';

void main() {
  test('reads a class-matrix schedule without inventing clock times', () {
    final workbook = Excel.createExcel();
    final sheet = workbook['Sheet1'];

    void setCell(String address, String value) {
      sheet.cell(CellIndex.indexByString(address)).value = TextCellValue(value);
    }

    setCell('A1', 'HARI');
    setCell('B1', 'JAM');
    setCell('C1', 'KELAS');
    setCell('C2', '7');
    setCell('E2', '8A');
    setCell('A3', 'SENIN');
    setCell('B3', '1');
    setCell('C3', 'W');
    setCell('D3', '1');
    setCell('E3', 'J');
    setCell('F3', '2');
    setCell('R4', '1');
    setCell('S4', 'Guru Satu');
    setCell('R5', '2');
    setCell('S5', 'Guru Dua');
    setCell('A6', 'TAHUN AJARAN 2026/2027 SEMESTER GANJIL');

    final result = JadwalExcelImporter.parse(
      Uint8List.fromList(workbook.encode()!),
    );

    expect(result.tahunAjaran, '2026/2027');
    expect(result.semester, Semester.ganjil);
    expect(result.jadwal, hasLength(2));
    expect(result.jadwal.first.jamKe, '1');
    expect(result.jadwal.first.mulaiMenit, isNull);
    expect(result.jadwal.first.kelas, '7');
    expect(result.jadwal.first.mataPelajaran, 'Nariyahan');
    expect(result.jadwal.first.guru, 'Guru Satu');
    expect(result.jadwal.first.ruang, isNull);
    expect(result.jadwal.last.kelas, '8A');
    expect(result.jadwal.last.mataPelajaran, 'Matematika');
    expect(result.jadwal.last.guru, 'Guru Dua');
  });

  test('rejects workbooks without a supported schedule layout', () {
    final workbook = Excel.createExcel();
    workbook['Sheet1'].cell(CellIndex.indexByString('A1')).value =
        TextCellValue('Daftar siswa');

    expect(
      () => JadwalExcelImporter.parse(Uint8List.fromList(workbook.encode()!)),
      throwsA(isA<FormatException>()),
    );
  });

  test('accepts flat rows without class, room, or clock-time values', () {
    final workbook = Excel.createExcel();
    final sheet = workbook['Sheet1'];
    const headers = [
      'HARI',
      'JAM KE',
      'JAM MULAI',
      'JAM SELESAI',
      'KELAS',
      'KODE MATA PELAJARAN',
      'NAMA MATA PELAJARAN',
      'KODE GURU',
      'NAMA GURU',
      'TAHUN AJARAN',
      'SEMESTER GANJIL/GENAP',
    ];

    void setCell(String address, String value) {
      sheet.cell(CellIndex.indexByString(address)).value = TextCellValue(value);
    }

    for (var index = 0; index < headers.length; index++) {
      setCell('${String.fromCharCode(65 + index)}1', headers[index]);
    }
    final firstRow = [
      'SENIN',
      '1',
      '06.45 WIB',
      '07.30 WIB',
      '',
      'J',
      'Matematika',
      '1',
      'Guru Satu',
      '2026/2027',
      'Ganjil',
    ];
    final secondRow = [
      "JUM'AT",
      'THL',
      '',
      '',
      '',
      'W',
      'Nariyahan',
      '2',
      'Guru Dua',
      '2026/2027',
      'Ganjil',
    ];
    for (var index = 0; index < headers.length; index++) {
      setCell('${String.fromCharCode(65 + index)}2', firstRow[index]);
      setCell('${String.fromCharCode(65 + index)}3', secondRow[index]);
    }

    final result = JadwalExcelImporter.parse(
      Uint8List.fromList(workbook.encode()!),
    );

    expect(result.jadwal, hasLength(2));
    expect(result.jadwal.first.kelas, isNull);
    expect(result.jadwal.first.ruang, isNull);
    expect(result.jadwal.first.mulaiMenit, 6 * 60 + 45);
    expect(result.jadwal.last.hari, HariSekolah.jumat);
    expect(result.jadwal.last.jamKe, 'THL');
    expect(result.jadwal.last.mulaiMenit, isNull);
  });
}
