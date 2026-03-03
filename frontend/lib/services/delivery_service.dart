import 'dart:convert';
import '../config/app_config.dart';
import '../core/errors/app_exception.dart';
import '../models/delivery_model.dart';
import 'api_service.dart';

class DeliveryService {
  Future<List<DeliveryModel>> getDeliveries() async {
    try {
      final response = await ApiService.get(
        AppConfig.deliveriesEndpoint,
        requiresAuth: true,
      );

      final decoded = jsonDecode(response.body);

      // Backend returns a raw array, not wrapped in {data: [...]}
      List<dynamic> deliveriesList;
      if (decoded is List) {
        deliveriesList = decoded;
      } else if (decoded is Map<String, dynamic>) {
        deliveriesList = decoded['data'] as List<dynamic>? ?? decoded['deliveries'] as List<dynamic>? ?? [];
      } else {
        deliveriesList = [];
      }

      return deliveriesList
          .map((item) => DeliveryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch deliveries: ${e.toString()}');
    }
  }

  Future<DeliveryModel> createDelivery({
    required String pickupLocation,
    required String deliveryAddress,
    required String deliveryType,
    double? distance,
    String? motorcycleId,
  }) async {
    try {
      final body = <String, dynamic>{
        'pickupLocation': pickupLocation,
        'deliveryAddress': deliveryAddress,
        'deliveryType': deliveryType,
      };
      
      if (distance != null) {
        body['distance'] = distance;
      }
      
      if (motorcycleId != null) {
        body['motorcycleId'] = motorcycleId;
      }

      final response = await ApiService.post(
        AppConfig.deliveriesEndpoint,
        body,
        requiresAuth: true,
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DeliveryModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to create delivery: ${e.toString()}');
    }
  }

  Future<double> calculateCost({
    required String deliveryId,
    required double distance,
    required String motorcycleId,
  }) async {
    try {
      final response = await ApiService.post(
        '${AppConfig.deliveriesEndpoint}/$deliveryId/calculate-cost',
        {
          'distance': distance,
          'motorcycleId': motorcycleId,
        },
        requiresAuth: true,
      );

      final decoded = jsonDecode(response.body);
      // Backend may return a raw number or a JSON object
      if (decoded is num) return decoded.toDouble();
      if (decoded is Map<String, dynamic>) {
        return (decoded['cost'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to calculate cost: ${e.toString()}');
    }
  }

  Future<DeliveryModel> updateDeliveryStatus(
    String deliveryId,
    String status,
  ) async {
    try {
      final response = await ApiService.patch(
        '${AppConfig.deliveriesEndpoint}/$deliveryId/status',
        {'status': status},
        requiresAuth: true,
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DeliveryModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to update delivery: ${e.toString()}');
    }
  }

  Future<DeliveryModel> acceptDelivery(String deliveryId) async {
    try {
      final response = await ApiService.post(
        '${AppConfig.deliveriesEndpoint}/$deliveryId/accept',
        {},
        requiresAuth: true,
      );
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DeliveryModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to accept delivery: ${e.toString()}');
    }
  }

  Future<DeliveryModel> startDelivery(String deliveryId) async {
    try {
      final response = await ApiService.post(
        '${AppConfig.deliveriesEndpoint}/$deliveryId/start',
        {},
        requiresAuth: true,
      );
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DeliveryModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to start delivery: ${e.toString()}');
    }
  }

  Future<DeliveryModel> completeDelivery(String deliveryId, {double? actualCost}) async {
    try {
      final body = <String, dynamic>{};
      if (actualCost != null) body['actualCost'] = actualCost;
      final response = await ApiService.post(
        '${AppConfig.deliveriesEndpoint}/$deliveryId/complete',
        body,
        requiresAuth: true,
      );
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DeliveryModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to complete delivery: ${e.toString()}');
    }
  }

  Future<DeliveryModel> cancelDelivery(String deliveryId) async {
    try {
      final response = await ApiService.post(
        '${AppConfig.deliveriesEndpoint}/$deliveryId/cancel',
        {},
        requiresAuth: true,
      );
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return DeliveryModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to cancel delivery: ${e.toString()}');
    }
  }

  Future<List<DeliveryModel>> getAvailableDeliveries() async {
    try {
      final response = await ApiService.get(
        '${AppConfig.deliveriesEndpoint}/driver/available',
        requiresAuth: true,
      );
      final decoded = jsonDecode(response.body);
      final list = decoded is List ? decoded : [];
      return list
          .map((item) => DeliveryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch available deliveries: ${e.toString()}');
    }
  }

  Future<List<DeliveryModel>> getActiveDriverDeliveries() async {
    try {
      final response = await ApiService.get(
        '${AppConfig.deliveriesEndpoint}/driver/active',
        requiresAuth: true,
      );
      final decoded = jsonDecode(response.body);
      final list = decoded is List ? decoded : [];
      return list
          .map((item) => DeliveryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch active deliveries: ${e.toString()}');
    }
  }
}
