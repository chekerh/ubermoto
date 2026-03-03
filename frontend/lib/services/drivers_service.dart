import 'dart:convert';
import '../config/app_config.dart';
import '../core/errors/app_exception.dart';
import 'api_service.dart';

class DriversService {
  /// Get driver profile by user ID (uses /drivers/user/:userId)
  Future<Map<String, dynamic>> getDriverProfile(String userId) async {
    try {
      final response = await ApiService.get(
        '${AppConfig.driversEndpoint}/user/$userId',
        requiresAuth: true,
      );
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get driver profile: ${e.toString()}');
    }
  }

  /// Update driver availability by driver document ID (uses /drivers/:id/availability)
  Future<void> updateAvailability(String driverId, bool isAvailable) async {
    try {
      await ApiService.patch(
        '${AppConfig.driversEndpoint}/$driverId/availability',
        {'isAvailable': isAvailable},
        requiresAuth: true,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to update availability: ${e.toString()}');
    }
  }

  /// Update driver motorcycle by driver document ID
  Future<void> updateMotorcycle(String driverId, String motorcycleId) async {
    try {
      await ApiService.patch(
        '${AppConfig.driversEndpoint}/$driverId/motorcycle',
        {'motorcycleId': motorcycleId},
        requiresAuth: true,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to update motorcycle: ${e.toString()}');
    }
  }

  /// Upload driver documents by driver document ID
  Future<void> uploadDocuments(String driverId, Map<String, String> documents) async {
    try {
      await ApiService.post(
        '${AppConfig.driversEndpoint}/$driverId/documents',
        documents,
        requiresAuth: true,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to upload documents: ${e.toString()}');
    }
  }
}
