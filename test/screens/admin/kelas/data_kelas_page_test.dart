import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasimadrasahku/screens/admin/kelas/data_kelas_page.dart';
import 'package:aplikasimadrasahku/screens/admin/kelas/tambah_kelas_page.dart';

void main() {
  testWidgets('filters the real class list by grade level', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DataKelasPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('filter-tingkat')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('filter-tingkat-8')));
    await tester.pumpAndSettle();

    expect(find.text('8A'), findsOneWidget);
    expect(find.text('8B'), findsOneWidget);
    expect(find.text('8C'), findsOneWidget);
    expect(find.text('9A'), findsNothing);
    expect(find.text('Nonaktif'), findsNothing);
  });

  testWidgets('wali kelas can be left unassigned and uses real teacher names', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DataKelasPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+ Tambah'));
    await tester.pumpAndSettle();

    expect(find.text('Belum ditentukan'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();

    expect(find.text('M. Abdul Haris J., S.Pd.I'), findsOneWidget);
    expect(find.text('Drs. Said'), findsOneWidget);
    expect(find.byType(TambahKelasPage), findsOneWidget);
  });
}
