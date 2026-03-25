import 'dart:convert';

import '../core/errors/app_exception.dart';
import 'api_service.dart';

class SupportService {
  Future<Map<String, dynamic>> createTicket({
    required String subject,
    required String description,
    String priority = 'medium',
    String? referenceId,
    String? referenceType,
  }) async {
    try {
      final body = <String, dynamic>{
        'subject': subject,
        'description': description,
        'priority': priority,
        if (referenceId != null) 'referenceId': referenceId,
        if (referenceType != null) 'referenceType': referenceType,
      };

      final response = await ApiService.post(
        '/support/tickets',
        body,
        requiresAuth: true,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to create support ticket: ${e.toString()}');
    }
  }

  Future<List<dynamic>> getMyTickets() async {
    try {
      final response = await ApiService.get('/support/tickets', requiresAuth: true);
      final decoded = jsonDecode(response.body);
      if (decoded is List) return decoded;
      return const [];
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch support tickets: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getTicketById(String ticketId) async {
    try {
      final response = await ApiService.get('/support/tickets/$ticketId', requiresAuth: true);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch support ticket: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> submitFeedback({
    required String message,
    String type = 'app',
    int? rating,
    String? referenceId,
    String? referenceType,
  }) async {
    try {
      final body = <String, dynamic>{
        'message': message,
        'type': type,
        if (rating != null) 'rating': rating,
        if (referenceId != null) 'referenceId': referenceId,
        if (referenceType != null) 'referenceType': referenceType,
      };

      final response = await ApiService.post('/feedback', body, requiresAuth: true);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to submit feedback: ${e.toString()}');
    }
  }

  Future<List<dynamic>> getFaqs({String? category}) async {
    try {
      final endpoint = category == null ? '/faqs' : '/faqs?category=$category';
      final response = await ApiService.get(endpoint, requiresAuth: true);
      final decoded = jsonDecode(response.body);
      if (decoded is List) return decoded;
      return const [];
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch FAQs: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getSystemVersion() async {
    try {
      final response = await ApiService.get('/system/version');
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch system version: ${e.toString()}');
    }
  }
}
