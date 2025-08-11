// This is a basic Flutter widget test for Stock Signal App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pulse/main.dart';

void main() {
  testWidgets('App compiles successfully', (WidgetTester tester) async {
    // This test ensures the app compiles without critical errors
    expect(() => const ProviderScope(child: StockSignalApp()), returnsNormally);
  });
}
