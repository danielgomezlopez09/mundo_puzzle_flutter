// This is a basic Flutter widget test.
//
// To perform an interaction with a widget, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:mundo_puzzle_flutter/main.dart';

void main() {
  testWidgets('Mundo Puzzle app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MundoPuzzleApp());

    // Verify that the app starts
    expect(find.byType(MundoPuzzleApp), findsOneWidget);
  });
}
