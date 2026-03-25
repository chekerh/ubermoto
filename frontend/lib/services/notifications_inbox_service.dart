import 'dart:convert';

import '../core/errors/app_exception.dart';
import 'api_service.dart';

class NotificationsInboxService {
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await ApiService.get(
        '/notifications?page=$page&limit=$limit',
        requiresAuth: true,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch notifications: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    try {
      final response = await ApiService.post(
        '/notifications/$notificationId/read',
        const {},
        requiresAuth: true,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to mark notification as read: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final response = await ApiService.post(
        '/notifications/read-all',
        const {},
        requiresAuth: true,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to mark all notifications as read: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    try {
      final response = await ApiService.delete(
        '/notifications/$notificationId',
        requiresAuth: true,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to delete notification: ${e.toString()}');
    }
  }
}
