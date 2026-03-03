import 'dart:convert';

import '../core/errors/app_exception.dart';
import 'api_service.dart';

class NotificationPreferencesService {
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final res = await ApiService.get('/notification-preferences', requiresAuth: true);
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on AppException {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updatePreferences(List<String> categories) async {
    try {
      final res = await ApiService.post(
        '/notification-preferences',
        {'categories': categories},
        requiresAuth: true,
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on AppException {
      rethrow;
    }
  }
}
