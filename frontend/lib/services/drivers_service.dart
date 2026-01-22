import 'dart:convert';
import '../config/app_config.dart';
import '../core/errors/app_exception.dart';
import 'api_service.dart';

class DriversService {
  Future<Map<String, dynamic>> getDriverProfile() async {
    try {
      final response = await ApiService.get('/drivers/me', requiresAuth: true);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get driver profile: ${e.toString()}');
    }
  }

  Future<void> updateAvailability(bool isAvailable) async {
    try {
      await ApiService.patch(
        '/drivers/me/availability',
        {'isAvailable': isAvailable},
        requiresAuth: true,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to update availability: ${e.toString()}');
    }
  }
}
