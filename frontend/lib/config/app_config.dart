import 'dart:io';

class AppConfig {
  // Backend port configuration
  // Change this port to match your backend PORT in .env
  // Available ports: 3001, 3002, 3003, 3004
  static const int backendPort = 3003;
  
  // Update this URL based on your backend location
  // For Android emulator: http://10.0.2.2:PORT
  // For iOS simulator: http://localhost:PORT
  // For physical device: http://<your-ip>:PORT
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine's localhost
      return 'http://10.0.2.2:$backendPort';
    } else {
      // iOS simulator and other platforms use localhost
      return 'http://localhost:$backendPort';
    }
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
