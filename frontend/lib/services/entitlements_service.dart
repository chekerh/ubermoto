import 'dart:convert';
import '../core/errors/app_exception.dart';
import 'api_service.dart';

class EntitlementsService {
  Future<Map<String, dynamic>> getMyEntitlements() async {
    try {
      final res = await ApiService.get('/users/me/entitlements', requiresAuth: true);
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

