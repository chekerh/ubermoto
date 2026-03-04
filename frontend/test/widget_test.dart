import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Basic app smoke test', (WidgetTester tester) async {
    // Build a simple test app
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Nassib Test'),
            ),
            body: const Center(
              child: Text('Testing'),
            ),
          ),
        ),
      ),
    );

    // Verify the test widget is displayed
    expect(find.text('Nassib Test'), findsOneWidget);
    expect(find.text('Testing'), findsOneWidget);
  });

  group('Riverpod Provider Tests', () {
    test('StateProvider basic test', () {
      final container = ProviderContainer();
      final testProvider = StateProvider<int>((ref) => 0);

      expect(container.read(testProvider), 0);

      container.read(testProvider.notifier).state = 42;
      expect(container.read(testProvider), 42);

      container.dispose();
    });
  });
}
