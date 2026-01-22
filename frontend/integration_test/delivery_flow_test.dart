import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubertaxi_frontend/main.dart';
import 'package:ubertaxi_frontend/core/navigation/app_router.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Delivery Flow Integration Tests', () {
    testWidgets('Complete delivery creation flow', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );

      // Wait for app to initialize
      await tester.pumpAndSettle();

      // Navigate to role selection
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Select customer role
      await tester.tap(find.text('Customer'));
      await tester.pumpAndSettle();

      // Fill customer registration form
      await tester.enterText(find.bySemanticsLabel('Full Name'), 'Test Customer');
      await tester.enterText(find.bySemanticsLabel('Email'), 'test@example.com');
      await tester.enterText(find.bySemanticsLabel('Password'), 'password123');
      await tester.enterText(find.bySemanticsLabel('Confirm Password'), 'password123');

      // Submit registration
      await tester.tap(find.text('Create Customer Account'));
      await tester.pumpAndSettle();

      // Navigate to delivery creation
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill delivery form
      await tester.enterText(find.bySemanticsLabel('Pickup Location'), 'Downtown Mall');
      await tester.enterText(find.bySemanticsLabel('Delivery Address'), 'Residential Area');
      await tester.enterText(find.bySemanticsLabel('Delivery Type'), 'Food Delivery');
      await tester.enterText(find.bySemanticsLabel('Distance (km)'), '5.2');

      // Select motorcycle (if dropdown is available)
      // This would depend on if motorcycles are loaded

      // Submit delivery
      await tester.tap(find.text('Create Delivery'));
      await tester.pumpAndSettle();

      // Verify delivery was created
      expect(find.text('My Deliveries'), findsOneWidget);
    });

    testWidgets('Driver registration and availability toggle', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );

      // Wait for app to initialize
      await tester.pumpAndSettle();

      // Navigate to role selection
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Select driver role
      await tester.tap(find.text('Delivery Driver'));
      await tester.pumpAndSettle();

      // Fill driver registration form
      await tester.enterText(find.bySemanticsLabel('Full Name'), 'Test Driver');
      await tester.enterText(find.bySemanticsLabel('Email'), 'driver@example.com');
      await tester.enterText(find.bySemanticsLabel('Phone Number'), '+21612345678');
      await tester.enterText(find.bySemanticsLabel('Driver License Number'), 'DRV123456');
      await tester.enterText(find.bySemanticsLabel('Password'), 'password123');
      await tester.enterText(find.bySemanticsLabel('Confirm Password'), 'password123');

      // Submit registration
      await tester.tap(find.text('Create Driver Account'));
      await tester.pumpAndSettle();

      // Navigate to availability screen
      await tester.tap(find.text('Availability'));
      await tester.pumpAndSettle();

      // Toggle availability
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Verify availability changed
      expect(find.text('You are Online'), findsOneWidget);
    });
  });
}