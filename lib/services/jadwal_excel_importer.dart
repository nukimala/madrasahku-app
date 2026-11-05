import 'dart:typed_data';
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import '../models/jadwal_model.dart';

class JadwalImportHasil {
  final List<JadwalPelajaran> jadwal;
  final String tahunAjaran;
  final Semester semester;
  final String namaSheet;
  final List<String> catatan;

  const JadwalImportHasil({
    required this.jadwal,
    required this.tahunAjaran,
    required this.semester,
    required this.namaSheet,
    required this.catatan,
  });
}

class JadwalExcelImporter {
  static const _mapelByCode = {
    'A': 'Qur’an Hadits',
    'B': 'Akidah Akhlaq',
    'C': 'Fikih',
    'D': 'SKI',
    'E': 'Bahasa Arab',
    'F': 'PPKn',
    'G': 'Bahasa Indonesia',
    'H': 'IPS Terpadu',
    'I': 'IPA Terpadu',
    'J': 'Matematika',
    'K': 'Bahasa Inggris',
    'L': 'Penjaskes',
    'M': 'SBK/Prakarya',
    'N': 'Bahasa Jawa',
    'O': 'Tahfidzul Qur’an/QH-B',
    'P': 'TIK',
    'R': 'BTA',
    'S': 'Ta’lim Muta’alim',
    'T': 'Aswaja',
    'U': 'Mabadiul Fiqiyah',
    'W': 'Nariyahan',
    'X': 'Upacara',
    'Y': 'Tahlilan',
  };

  static JadwalImportHasil parse(Uint8List bytes) {
    final sheets = _decodeWorkbook(bytes);
    for (final entry in sheets.entries) {
      final rows = entry.value;
      final matrixHeader = _findMatrixHeader(rows);
      if (matrixHeader != null) {
        return _parseMatrix(entry.key, rows, matrixHeader);
      }

      final flatHeader = _findFlatHeader(rows);
      if (flatHeader != null) {
        return _parseFlat(entry.key, rows, flatHeader);
      }
    }

    throw const FormatException(
      'Format jadwal tidak dikenali. Pastikan file memiliki kolom HARI dan JAM.',
    );
  }

  static _MatrixHeader? _findMatrixHeader(List<List<String>> rows) {
    for (var rowIndex = 0; rowIndex + 1 < rows.length; rowIndex++) {
      final headers = rows[rowIndex].map(_normalizeHeader).toList();
      if (headers.contains('hari') &&
          headers.contains('jam') &&
          headers.contains('kelas')) {
        final dayColumn = headers.indexOf('hari');
        final periodColumn = headers.indexOf('jam');
        final classColumns = <_ClassColumn>[];
        for (var column = 2; column < rows[rowIndex + 1].length; column++) {
          final label = _normalizeCode(rows[rowIndex + 1][column]);
          if (label.isEmpty) continue;
          if (headers.length > column &&
              _normalizeHeader(headers[column]) == 'keterangan') {
            break;
          }
          if (column > 16) break;
          if (column.isEven) {
            classColumns.add(_ClassColumn(column, label));
          }
        }
        if (classColumns.isNotEmpty) {
          return _MatrixHeader(
            headerRow: rowIndex,
            dayColumn: dayColumn,
            periodColumn: periodColumn,
            classColumns: classColumns,
          );
        }
      }
    }
    return null;
  }

  static _FlatHeader? _findFlatHeader(List<List<String>> rows) {
    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final headers = <String, int>{};
      for (var column = 0; column < rows[rowIndex].length; column++) {
        final label = _normalizeHeader(rows[rowIndex][column]);
        if (label.isNotEmpty) headers[label] = column;
      }
      if (headers.containsKey('hari') &&
          headers.containsKey('jam ke') &&
          headers.containsKey('nama mata pelajaran')) {
        return _FlatHeader(rowIndex, headers);
      }
    }
    return null;
  }

  static JadwalImportHasil _parseFlat(
    String sheetName,
    List<List<String>> rows,
    _FlatHeader header,
  ) {
    final catatan = <String>[];
    final schedules = <JadwalPelajaran>[];
    String? schoolYear;
    Semester? semester;
    final column = header.columns;

    for (var rowIndex = header.row + 1; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      final dayText = _valueAt(row, column['hari']);
      final lesson = _valueAt(row, column['jam ke']);
      final subject = _valueAt(row, column['nama mata pelajaran']);
      if (dayText.isEmpty && lesson.isEmpty && subject.isEmpty) continue;

      final day = _parseDay(dayText);
      if (day == null) {
        catatan.add('Baris ${rowIndex + 1}: hari tidak dikenali ($dayText).');
        continue;
      }

      final rawStart = _valueAt(row, column['jam mulai']);
      final rawEnd = _valueAt(row, column['jam selesai']);
      final start = rawStart.isEmpty ? null : _parseTime(rawStart);
      final end = rawEnd.isEmpty ? null : _parseTime(rawEnd);
      if ((rawStart.isEmpty != rawEnd.isEmpty) ||
          (rawStart.isNotEmpty &&
              (start == null || end == null || end <= start))) {
        catatan.add('Baris ${rowIndex + 1}: waktu pelajaran tidak valid.');
        continue;
      }

      final rowYear = _valueAt(row, column['tahun ajaran']);
      final rowSemester = _parseSemester(
        _valueAt(row, column['semester ganjil/genap']),
      );
      schoolYear ??= rowYear.isEmpty ? null : rowYear;
      semester ??= rowSemester;
      if (rowYear.isNotEmpty && schoolYear != rowYear) {
        catatan.add(
          'Baris ${rowIndex + 1}: tahun ajaran berbeda dari baris sebelumnya.',
        );
        continue;
      }
      if (rowSemester != null && semester != rowSemester) {
        catatan.add(
          'Baris ${rowIndex + 1}: semester berbeda dari baris sebelumnya.',
        );
        continue;
      }

      final teacher = _valueAt(row, column['nama guru']);
      final teacherCode = _valueAt(row, column['kode guru']);
      schedules.add(
        JadwalPelajaran(
          id: 0,
          tahunAjaran: rowYear.isEmpty ? (schoolYear ?? '') : rowYear,
          semester: rowSemester ?? semester ?? Semester.ganjil,
          kelas: _nullableValue(_valueAt(row, column['kelas'])),
          hari: day,
          mulaiMenit: start,
          selesaiMenit: end,
          jamKe: lesson,
          mataPelajaran: subject,
          kodeMapel: _nullableValue(
            _valueAt(row, column['kode mata pelajaran']),
          ),
          guru: teacher.isEmpty ? 'Guru belum ditentukan' : teacher,
          kodeGuru: _nullableValue(teacherCode),
          ruang: null,
        ),
      );
      if (teacher.isEmpty) {
        catatan.add('Baris ${rowIndex + 1}: nama guru belum dicantumkan.');
      }
      if (_valueAt(row, column['kelas']).isEmpty) {
        catatan.add('Baris ${rowIndex + 1}: kelas tidak dicantumkan.');
      }
    }

    if (schedules.isEmpty) {
      throw const FormatException('Tidak ada baris jadwal valid di file.');
    }
    if (schoolYear == null || semester == null) {
      throw const FormatException(
        'Tahun ajaran dan semester harus tersedia di file.',
      );
    }
    return JadwalImportHasil(
      jadwal: schedules,
      tahunAjaran: schoolYear,
      semester: semester,
      namaSheet: sheetName,
      catatan: catatan,
    );
  }

  static JadwalImportHasil _parseMatrix(
    String sheetName,
    List<List<String>> rows,
    _MatrixHeader header,
  ) {
    final catatan = <String>[];
    final schedules = <JadwalPelajaran>[];
    final teacherNames = <String, String>{};
    var schoolYear = '';
    var semester = Semester.ganjil;

    for (final row in rows) {
      final joined = row.join(' ');
      final yearMatch = RegExp(r'20\d{2}\s*[/\-]\s*20\d{2}').firstMatch(joined);
      if (schoolYear.isEmpty && yearMatch != null) {
        schoolYear = yearMatch
            .group(0)!
            .replaceAll(' ', '')
            .replaceAll('-', '/');
      }
      if (joined.toLowerCase().contains('semester genap')) {
        semester = Semester.genap;
      } else if (joined.toLowerCase().contains('semester ganjil')) {
        semester = Semester.ganjil;
      }

      final code = _normalizeCode(_valueAt(row, 17));
      final name = _valueAt(row, 18);
      if (code.isNotEmpty && name.isNotEmpty) {
        teacherNames[code] = name;
      }
    }
    if (schoolYear.isEmpty) {
      throw const FormatException(
        'Tahun ajaran tidak ditemukan pada file jadwal.',
      );
    }

    HariSekolah? currentDay;
    for (
      var rowIndex = header.headerRow + 2;
      rowIndex < rows.length;
      rowIndex++
    ) {
      final row = rows[rowIndex];
      final dayText = _valueAt(row, header.dayColumn);
      if (dayText.isNotEmpty) {
        final parsedDay = _parseDay(dayText);
        if (parsedDay == null) {
          if (currentDay == HariSekolah.sabtu && schedules.isNotEmpty) break;
          catatan.add('Baris ${rowIndex + 1}: hari tidak dikenali ($dayText).');
          currentDay = null;
          continue;
        }
        currentDay = parsedDay;
      }
      if (currentDay == null) continue;

      final lesson = _normalizeCode(_valueAt(row, header.periodColumn));
      if (lesson.isEmpty) continue;
      for (final classColumn in header.classColumns) {
        final subjectCode = _normalizeCode(_valueAt(row, classColumn.column));
        if (subjectCode.isEmpty) continue;
        final rawTeacherCode = _valueAt(row, classColumn.column + 1);
        final teacherCodes = _teacherCodes(rawTeacherCode, teacherNames);
        final teachers = teacherCodes
            .map((teacherCode) => teacherNames[teacherCode])
            .whereType<String>()
            .toList();
        final unknownCodes = teacherCodes
            .where((teacherCode) => !teacherNames.containsKey(teacherCode))
            .toList();
        if (unknownCodes.isNotEmpty) {
          catatan.add(
            'Baris ${rowIndex + 1}, kelas ${classColumn.name}: '
            'kode guru ${unknownCodes.join(', ')} tidak ditemukan.',
          );
        }
        if (rawTeacherCode.isEmpty) {
          catatan.add(
            'Baris ${rowIndex + 1}, kelas ${classColumn.name}: '
            'kode guru tidak dicantumkan.',
          );
        }

        schedules.add(
          JadwalPelajaran(
            id: 0,
            tahunAjaran: schoolYear,
            semester: semester,
            kelas: classColumn.name,
            hari: currentDay,
            mulaiMenit: null,
            selesaiMenit: null,
            jamKe: lesson,
            mataPelajaran:
                _mapelByCode[subjectCode] ?? 'Kode mapel $subjectCode',
            kodeMapel: subjectCode,
            guru: teachers.isEmpty
                ? (rawTeacherCode.isEmpty
                      ? 'Guru belum ditentukan'
                      : 'Kode guru ${rawTeacherCode.trim()}')
                : teachers.join(' / '),
            kodeGuru: _nullableValue(rawTeacherCode),
            ruang: null,
          ),
        );
      }
    }

    if (schedules.isEmpty) {
      throw const FormatException('Tidak ada jadwal valid di lembar ini.');
    }
    return JadwalImportHasil(
      jadwal: schedules,
      tahunAjaran: schoolYear,
      semester: semester,
      namaSheet: sheetName,
      catatan: catatan,
    );
  }

  static List<String> _teacherCodes(
    String rawCode,
    Map<String, String> teacherNames,
  ) {
    final normalized = _normalizeCode(rawCode);
    if (normalized.isEmpty) return [];
    final combined = RegExp(r'^(\d+)\.(\d+)$').firstMatch(normalized);
    if (combined != null) {
      final first = combined.group(1)!;
      final second = combined.group(2)!;
      if (teacherNames.containsKey(first) && teacherNames.containsKey(second)) {
        return [first, second];
      }
    }
    return [normalized];
  }

  static HariSekolah? _parseDay(String value) {
    final day = value
        .trim()
        .toUpperCase()
        .replaceAll('’', "'")
        .replaceAll('.', '');
    return switch (day) {
      'SENIN' => HariSekolah.senin,
      'SELASA' => HariSekolah.selasa,
      'RABU' => HariSekolah.rabu,
      'KAMIS' => HariSekolah.kamis,
      "JUM'AT" || 'JUMAT' || 'JUM’AT' => HariSekolah.jumat,
      'SABTU' => HariSekolah.sabtu,
      _ => null,
    };
  }

  static Semester? _parseSemester(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.contains('ganjil')) return Semester.ganjil;
    if (normalized.contains('genap')) return Semester.genap;
    return null;
  }

  static int? _parseTime(String value) {
    final match = RegExp(r'(\d{1,2})[.:](\d{2})').firstMatch(value);
    if (match == null) return null;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      return null;
    }
    return hour * 60 + minute;
  }

  static String _normalizeCode(String value) {
    final trimmed = value.trim();
    final numeric = double.tryParse(trimmed);
    if (numeric != null && numeric == numeric.truncateToDouble()) {
      return numeric.toInt().toString();
    }
    return trimmed.toUpperCase();
  }

  static String _normalizeHeader(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static String _valueAt(List<String> row, int? column) {
    if (column == null || column < 0 || column >= row.length) return '';
    return row[column].trim();
  }

  static String? _nullableValue(String value) =>
      value.trim().isEmpty ? null : value.trim();

  static Map<String, List<List<String>>> _decodeWorkbook(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final workbookDocument = _readXml(archive, 'xl/workbook.xml');
    final relationshipsDocument = _readXml(
      archive,
      'xl/_rels/workbook.xml.rels',
    );
    final relationships = <String, String>{};
    for (final relationship in relationshipsDocument.findAllElements(
      'Relationship',
      namespace: '*',
    )) {
      final id = _attribute(relationship, 'Id');
      final target = _attribute(relationship, 'Target');
      if (id.isNotEmpty && target.isNotEmpty) {
        relationships[id] = _resolveWorkbookPath(target);
      }
    }

    final sharedStrings = <String>[];
    final sharedStringsFile = archive.findFile('xl/sharedStrings.xml');
    if (sharedStringsFile != null) {
      final document = XmlDocument.parse(
        utf8.decode(sharedStringsFile.content as List<int>),
      );
      for (final item in document.findAllElements('si', namespace: '*')) {
        sharedStrings.add(
          item
              .findAllElements('t', namespace: '*')
              .map((text) => text.innerText)
              .join(),
        );
      }
    }

    final sheets = <String, List<List<String>>>{};
    for (final sheet in workbookDocument.findAllElements(
      'sheet',
      namespace: '*',
    )) {
      final name = _attribute(sheet, 'name');
      final relationshipId = _attribute(sheet, 'id');
      final path = relationships[relationshipId];
      if (name.isEmpty || path == null) continue;
      final document = _readXml(archive, path);
      sheets[name] = _readRows(document, sharedStrings);
    }
    if (sheets.isEmpty) {
      throw const FormatException('File tidak memiliki lembar jadwal.');
    }
    return sheets;
  }

  static XmlDocument _readXml(Archive archive, String path) {
    final file = archive.findFile(path);
    if (file == null) {
      throw FormatException('Bagian file Excel tidak ditemukan: $path');
    }
    return XmlDocument.parse(utf8.decode(file.content as List<int>));
  }

  static List<List<String>> _readRows(
    XmlDocument document,
    List<String> sharedStrings,
  ) {
    final rows = <List<String>>[];
    final sheetData = document.findAllElements('sheetData', namespace: '*');
    if (sheetData.isEmpty) return rows;
    for (final xmlRow in sheetData.first.findElements('row', namespace: '*')) {
      final rowNumber =
          int.tryParse(_attribute(xmlRow, 'r')) ?? rows.length + 1;
      while (rows.length < rowNumber) {
        rows.add([]);
      }

      final values = <int, String>{};
      var maxColumn = -1;
      for (final cell in xmlRow.findElements('c', namespace: '*')) {
        final reference = _attribute(cell, 'r');
        final column = _columnIndex(reference);
        if (column == null) continue;
        maxColumn = column > maxColumn ? column : maxColumn;
        final type = _attribute(cell, 't');
        final valueNodes = cell.findElements('v', namespace: '*');
        final valueNode = valueNodes.isEmpty ? null : valueNodes.first;
        var value = valueNode?.innerText ?? '';
        if (type == 's' && value.isNotEmpty) {
          final index = int.tryParse(value);
          if (index == null || index < 0 || index >= sharedStrings.length) {
            throw FormatException(
              'Referensi teks Excel tidak valid pada sel $reference.',
            );
          }
          value = sharedStrings[index];
        } else if (type == 'inlineStr') {
          value = cell
              .findAllElements('t', namespace: '*')
              .map((text) => text.innerText)
              .join();
        }
        values[column] = value.trim();
      }

      rows[rowNumber - 1] = maxColumn < 0
          ? []
          : List.generate(maxColumn + 1, (column) => values[column] ?? '');
    }
    return rows;
  }

  static String _attribute(XmlElement element, String name) =>
      _findAttribute(element, name);

  static String _findAttribute(XmlElement element, String name) {
    for (final attribute in element.attributes) {
      if (attribute.name.local == name) return attribute.value;
    }
    return '';
  }

  static int? _columnIndex(String reference) {
    final letters = RegExp(r'^[A-Z]+').firstMatch(reference)?.group(0);
    if (letters == null) return null;
    var column = 0;
    for (final letter in letters.codeUnits) {
      column = column * 26 + letter - 64;
    }
    return column - 1;
  }

  static String _resolveWorkbookPath(String target) {
    final path = target.startsWith('/') ? target.substring(1) : 'xl/$target';
    final segments = <String>[];
    for (final segment in path.replaceAll('\\', '/').split('/')) {
      if (segment.isEmpty || segment == '.') continue;
      if (segment == '..') {
        if (segments.isNotEmpty) segments.removeLast();
      } else {
        segments.add(segment);
      }
    }
    return segments.join('/');
  }
}

class _FlatHeader {
  final int row;
  final Map<String, int> columns;

  const _FlatHeader(this.row, this.columns);
}

class _MatrixHeader {
  final int headerRow;
  final int dayColumn;
  final int periodColumn;
  final List<_ClassColumn> classColumns;

  const _MatrixHeader({
    required this.headerRow,
    required this.dayColumn,
    required this.periodColumn,
    required this.classColumns,
  });
}

class _ClassColumn {
  final int column;
  final String name;

  const _ClassColumn(this.column, this.name);
}
