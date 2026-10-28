import 'package:aplikasimadrasahku/screens/admin/guru/data_guru_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NIP/NUPTK is optional and new teacher appears in the list', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DataGuruPage()));

    await tester.tap(find.text('+ Tambah'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Dewi Guru');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    final mapelDropdown = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(mapelDropdown);
    await tester.pumpAndSettle();
    await tester.tap(mapelDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Matematika').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'dewi@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(3), '08123456789');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.text('+ Tambah Data Guru'));
    await tester.pumpAndSettle();

    expect(find.text('Nama wajib diisi'), findsNothing);
    expect(find.text('Pilih mata pelajaran'), findsNothing);
    expect(find.text('Email wajib diisi'), findsNothing);
    expect(find.text('No. telepon wajib diisi'), findsNothing);
    expect(find.text('Dewi Guru'), findsOneWidget);
    expect(find.text('Guru Matematika'), findsWidgets);

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Data Guru'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      'Dewi Guru',
    );
    await tester.enterText(
      find.byType(TextFormField).first,
      'Dewi Guru Updated',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pumpAndSettle();

    expect(find.text('Dewi Guru Updated'), findsOneWidget);
    expect(find.text('Dewi Guru'), findsNothing);
  });
}
