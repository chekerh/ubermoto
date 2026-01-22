import 'dart:convert';
import '../config/app_config.dart';
import '../core/errors/app_exception.dart';
import '../models/user_model.dart';
import '../models/preferences_model.dart';
import 'api_service.dart';

class UserService {
  Future<UserModel> getProfile() async {
    try {
      final response = await ApiService.get('/users/me', requiresAuth: true);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get profile: ${e.toString()}');
    }
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
      if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

      final response = await ApiService.patch(
        '/users/me',
        body,
        requiresAuth: true,
      );
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to update profile: ${e.toString()}');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await ApiService.patch(
        '/users/me/password',
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        requiresAuth: true,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to change password: ${e.toString()}');
    }
  }

  Future<PreferencesModel> getPreferences() async {
    try {
      final response = await ApiService.get('/users/me/preferences', requiresAuth: true);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PreferencesModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get preferences: ${e.toString()}');
    }
  }

  Future<PreferencesModel> updatePreferences(PreferencesModel preferences) async {
    try {
      final response = await ApiService.patch(
        '/users/me/preferences',
        preferences.toJson(),
        requiresAuth: true,
      );
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PreferencesModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to update preferences: ${e.toString()}');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await ApiService.delete('/users/me', requiresAuth: true);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to delete account: ${e.toString()}');
    }
  }
}
