import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubertaxi_frontend/main.dart';

void main() {
  testWidgets('App should start', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(isAuthenticated: false),
      ),
    );

    expect(find.text('Login'), findsOneWidget);
  });
}
