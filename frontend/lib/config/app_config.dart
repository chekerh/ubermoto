import 'dart:io';

class AppConfig {
  /// Override host port when backend is not on 3001, e.g.:
  /// `flutter run --dart-define=BACKEND_PORT=3010`
  static const int backendPort =
      int.fromEnvironment('BACKEND_PORT', defaultValue: 3001);

  /// Full API origin (scheme + host + port). When non-empty, overrides [baseUrl]
  /// built from [backendPort]. Example:
  /// `flutter run --dart-define=API_BASE_URL=http://10.0.0.5:3010`
  static const String _apiBaseUrlFromDefine =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  // Default URL by platform when API_BASE_URL is not set.
  // Android emulator: http://10.0.2.2:PORT — iOS simulator / desktop: localhost
  static String get baseUrl {
    final fromDefine = _apiBaseUrlFromDefine.trim();
    if (fromDefine.isNotEmpty) {
      return fromDefine.endsWith('/')
          ? fromDefine.substring(0, fromDefine.length - 1)
          : fromDefine;
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$backendPort';
    }
    return 'http://localhost:$backendPort';
  }
  
  // API Endpoints (no /api prefix - backend routes are directly on /auth, /deliveries, etc.)
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register'; // deprecated
  static const String customerRegisterEndpoint = '/auth/register/customer';
  static const String driverRegisterEndpoint = '/auth/register/driver';
  static const String deliveriesEndpoint = '/deliveries';
  static const String motorcyclesEndpoint = '/motorcycles';
  static const String driversEndpoint = '/drivers';
  static const String documentsEndpoint = '/documents';
}
