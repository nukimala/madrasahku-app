import 'package:aplikasimadrasahku/screens/admin/siswa/data_siswa_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('editing legacy student data opens valid dropdowns', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DataSiswaPage()));

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Data Siswa'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('can add and edit a student', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DataSiswaPage()));

    await tester.tap(find.text('+ Tambah'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Dewi Siswa');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();

    final dropdowns = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(dropdowns.at(0));
    await tester.pumpAndSettle();
    await tester.tap(dropdowns.at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('VII A').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(dropdowns.at(1));
    await tester.pumpAndSettle();
    await tester.tap(dropdowns.at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perempuan').last);
    await tester.pumpAndSettle();

    final dateField = find.byType(TextFormField).at(2);
    await tester.ensureVisible(dateField);
    await tester.pumpAndSettle();
    await tester.tap(dateField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('+ Tambah Data Siswa'));
    await tester.pumpAndSettle();

    expect(find.text('Dewi Siswa'), findsOneWidget);
    expect(find.text('Kelas VII A'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Data Siswa'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      'Dewi Siswa',
    );
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(1))
          .controller!
          .text,
      '123456',
    );

    await tester.enterText(
      find.byType(TextFormField).first,
      'Dewi Siswa Updated',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pumpAndSettle();

    expect(find.text('Dewi Siswa Updated'), findsOneWidget);
    expect(find.text('Dewi Siswa'), findsNothing);

    await tester.pump(const Duration(seconds: 5));
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus').last);
    await tester.pumpAndSettle();

    expect(find.text('Dewi Siswa Updated'), findsNothing);
  });
}
