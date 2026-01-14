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

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final deliveriesList = json['data'] as List<dynamic>? ?? json['deliveries'] as List<dynamic>? ?? [];

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

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return (json['cost'] as num?)?.toDouble() ?? 0.0;
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
      final response = await ApiService.post(
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
}
