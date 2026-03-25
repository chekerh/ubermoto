import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../core/errors/app_exception.dart';
import '../core/utils/storage_service.dart';
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

  /// Driver document upload (`multipart/form-data`). Requires DRIVER role.
  Future<void> uploadDocument({
    required String documentType,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      throw const AuthenticationException('Not authenticated');
    }

    final uri = Uri.parse('${AppConfig.baseUrl}/documents/upload');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['documentType'] = documentType
      ..files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
      );

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }
      throw NetworkException(
        'Document upload failed (${response.statusCode}): ${response.body}',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Document upload failed: ${e.toString()}');
    }
  }
}
