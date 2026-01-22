import 'dart:convert';
import '../config/app_config.dart';
import '../core/errors/app_exception.dart';
import '../models/document_model.dart';
import 'api_service.dart';

class DocumentsService {
  Future<List<DocumentModel>> getMyDocuments() async {
    try {
      final response = await ApiService.get('/documents/my-documents', requiresAuth: true);
      final json = jsonDecode(response.body) as List<dynamic>;
      return json.map((item) => DocumentModel.fromJson(item as Map<String, dynamic>)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get documents: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getDocumentStats() async {
    try {
      final response = await ApiService.get('/documents/stats', requiresAuth: true);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get document stats: ${e.toString()}');
    }
  }
}
