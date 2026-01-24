import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import '../main.dart';

class MonitoringService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> initialize() async {
    // Initialize Sentry
    await SentryFlutter.init(
      (options) {
        options.dsn = const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
        options.tracesSampleRate = 1.0;
        options.profilesSampleRate = 1.0;
      },
      appRunner: () => runApp(const MyApp()),
    );
  }

  // Analytics methods
  static Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters?.cast<String, Object>());
  }

  static Future<void> logDeliveryCreated(String deliveryId, double cost) async {
    await logEvent('delivery_created', parameters: {
      'delivery_id': deliveryId,
      'cost': cost,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> logDeliveryStatusUpdate(String deliveryId, String status) async {
    await logEvent('delivery_status_update', parameters: {
      'delivery_id': deliveryId,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> logDriverAction(String action, {String? driverId, String? deliveryId}) async {
    await logEvent('driver_action', parameters: {
      'action': action,
      'driver_id': driverId,
      'delivery_id': deliveryId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> setUserProperties(String userId, String userType) async {
    await _analytics.setUserId(id: userId);
    await _analytics.setUserProperty(name: 'user_type', value: userType);
  }

  // Error tracking
  static Future<void> captureException(dynamic exception, {dynamic stackTrace, Map<String, dynamic>? context}) async {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (context != null) {
          for (final entry in context.entries) {
            scope.setTag(entry.key, entry.value.toString());
          }
        }
        scope.level = SentryLevel.error;
      },
    );
  }

  static Future<void> captureMessage(String message, {SentryLevel level = SentryLevel.info, Map<String, dynamic>? context}) async {
    await Sentry.captureMessage(
      message,
      level: level,
      withScope: (scope) {
        if (context != null) {
          for (final entry in context.entries) {
            scope.setTag(entry.key, entry.value.toString());
          }
        }
      },
    );
  }
}
