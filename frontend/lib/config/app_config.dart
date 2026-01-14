class AppConfig {
  // Update this URL based on your backend location
  // For Android emulator: http://10.0.2.2:3000
  // For iOS simulator: http://localhost:3000
  // For physical device: http://<your-ip>:3000
  static const String baseUrl = 'http://localhost:3000';
  
  static const String apiVersion = '/api';
  
  static String get apiBaseUrl => '$baseUrl$apiVersion';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String deliveriesEndpoint = '/deliveries';
}
