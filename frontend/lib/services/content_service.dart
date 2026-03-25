import 'dart:convert';
import '../core/errors/app_exception.dart';
import 'api_service.dart';

class ContentService {
  Future<Map<String, dynamic>> getContent(String key) async {
    try {
      final res = await ApiService.get('/content/$key');
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const ServerException('Invalid content response');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to load content: ${e.toString()}');
    }
  }
}

