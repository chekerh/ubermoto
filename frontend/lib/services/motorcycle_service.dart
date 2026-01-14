import 'dart:convert';
import '../config/app_config.dart';
import '../core/errors/app_exception.dart';
import '../models/motorcycle_model.dart';
import 'api_service.dart';

class MotorcycleService {
  Future<List<MotorcycleModel>> getMotorcycles() async {
    try {
      final response = await ApiService.get(
        '/motorcycles',
        requiresAuth: true,
      );

      final json = jsonDecode(response.body) as List<dynamic>;
      return json
          .map((item) =>
              MotorcycleModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch motorcycles: ${e.toString()}');
    }
  }

  Future<MotorcycleModel> createMotorcycle(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post(
        '/motorcycles',
        data,
        requiresAuth: true,
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return MotorcycleModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to create motorcycle: ${e.toString()}');
    }
  }

  Future<MotorcycleModel> updateMotorcycle(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await ApiService.patch(
        '/motorcycles/$id',
        data,
        requiresAuth: true,
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return MotorcycleModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to update motorcycle: ${e.toString()}');
    }
  }

  Future<MotorcycleModel> getMotorcycle(String id) async {
    try {
      final response = await ApiService.get(
        '/motorcycles/$id',
        requiresAuth: true,
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return MotorcycleModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch motorcycle: ${e.toString()}');
    }
  }
}
