import 'dart:convert';
import '../config/app_config.dart';
import '../core/errors/app_exception.dart';
import '../models/address_model.dart';
import 'api_service.dart';

class AddressService {
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await ApiService.get('/users/addresses', requiresAuth: true);
      final json = jsonDecode(response.body) as List<dynamic>;
      return json.map((item) => AddressModel.fromJson(item as Map<String, dynamic>)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get addresses: ${e.toString()}');
    }
  }

  Future<AddressModel> getAddress(String id) async {
    try {
      final response = await ApiService.get('/users/addresses/$id', requiresAuth: true);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AddressModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get address: ${e.toString()}');
    }
  }

  Future<AddressModel> createAddress({
    required String label,
    required String address,
    required String city,
    String? postalCode,
    Coordinates? coordinates,
    bool isDefault = false,
  }) async {
    try {
      final body = <String, dynamic>{
        'label': label,
        'address': address,
        'city': city,
        'isDefault': isDefault,
      };
      if (postalCode != null) body['postalCode'] = postalCode;
      if (coordinates != null) body['coordinates'] = coordinates.toJson();

      final response = await ApiService.post(
        '/users/addresses',
        body,
        requiresAuth: true,
      );
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AddressModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to create address: ${e.toString()}');
    }
  }

  Future<AddressModel> updateAddress(
    String id, {
    String? label,
    String? address,
    String? city,
    String? postalCode,
    Coordinates? coordinates,
    bool? isDefault,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (label != null) body['label'] = label;
      if (address != null) body['address'] = address;
      if (city != null) body['city'] = city;
      if (postalCode != null) body['postalCode'] = postalCode;
      if (coordinates != null) body['coordinates'] = coordinates.toJson();
      if (isDefault != null) body['isDefault'] = isDefault;

      final response = await ApiService.patch(
        '/users/addresses/$id',
        body,
        requiresAuth: true,
      );
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AddressModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to update address: ${e.toString()}');
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await ApiService.delete('/users/addresses/$id', requiresAuth: true);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to delete address: ${e.toString()}');
    }
  }

  Future<AddressModel> setDefaultAddress(String id) async {
    try {
      final response = await ApiService.patch(
        '/users/addresses/$id/set-default',
        {},
        requiresAuth: true,
      );
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AddressModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to set default address: ${e.toString()}');
    }
  }
}
