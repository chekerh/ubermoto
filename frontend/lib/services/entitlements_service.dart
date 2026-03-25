import 'dart:convert';
import '../core/errors/app_exception.dart';
import 'api_service.dart';

class EntitlementsService {
  Future<Map<String, dynamic>> getMyEntitlements({String? merchantId}) async {
    try {
      final endpoint = merchantId == null || merchantId.isEmpty
          ? '/billing/me/entitlements'
          : '/billing/me/entitlements?merchantId=$merchantId';
      final res = await ApiService.get(endpoint, requiresAuth: true);
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const ServerException('Invalid entitlements response');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to load entitlements: ${e.toString()}');
    }
  }
}

