import 'dart:convert';
import '../config/app_config.dart';
import '../core/errors/app_exception.dart';
import '../core/utils/storage_service.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await ApiService.post(
        AppConfig.loginEndpoint,
        {
          'email': email,
          'password': password,
        },
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final authResponse = AuthResponseModel.fromJson(json);

      // Save token securely
      await StorageService.saveToken(authResponse.accessToken);
      await StorageService.saveUserEmail(email);

      return authResponse;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Login failed: ${e.toString()}');
    }
  }

  Future<AuthResponseModel> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await ApiService.post(
        AppConfig.registerEndpoint,
        {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final authResponse = AuthResponseModel.fromJson(json);

      // Save token securely
      await StorageService.saveToken(authResponse.accessToken);
      await StorageService.saveUserEmail(email);

      return authResponse;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Registration failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await StorageService.clearAll();
  }

  Future<bool> isAuthenticated() async {
    final token = await StorageService.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    return await StorageService.getToken();
  }
}
