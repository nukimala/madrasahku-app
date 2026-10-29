import 'package:flutter_test/flutter_test.dart';
import 'package:aplikasimadrasahku/main.dart';

void main() {
  testWidgets('App renders splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MadrasahkuApp());
    expect(find.byType(MadrasahkuApp), findsOneWidget);
  });
}
