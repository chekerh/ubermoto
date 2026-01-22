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
      print('Auth Service - Saving token: ${authResponse.accessToken.substring(0, 20)}...');
      await StorageService.saveToken(authResponse.accessToken);
      await StorageService.saveUserEmail(email);
      print('Auth Service - Token saved successfully');

      return authResponse;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Login failed: ${e.toString()}');
    }
  }

  Future<AuthResponseModel> registerCustomer(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await ApiService.post(
        AppConfig.customerRegisterEndpoint,
        {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final authResponse = AuthResponseModel.fromJson(json);

      // Save token securely
      print('Auth Service - Saving token: ${authResponse.accessToken.substring(0, 20)}...');
      await StorageService.saveToken(authResponse.accessToken);
      await StorageService.saveUserEmail(email);
      print('Auth Service - Token saved successfully');

      return authResponse;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Customer registration failed: ${e.toString()}');
    }
  }

  Future<AuthResponseModel> registerDriver(
    String email,
    String password,
    String name,
    String phoneNumber,
    String licenseNumber,
  ) async {
    try {
      final response = await ApiService.post(
        AppConfig.driverRegisterEndpoint,
        {
          'email': email,
          'password': password,
          'name': name,
          'phoneNumber': phoneNumber,
          'licenseNumber': licenseNumber,
        },
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final authResponse = AuthResponseModel.fromJson(json);

      // Save token securely
      print('Auth Service - Saving token: ${authResponse.accessToken.substring(0, 20)}...');
      await StorageService.saveToken(authResponse.accessToken);
      await StorageService.saveUserEmail(email);
      print('Auth Service - Token saved successfully');

      return authResponse;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Driver registration failed: ${e.toString()}');
    }
  }

  // Keep backward compatibility (deprecated)
  Future<AuthResponseModel> register(
    String email,
    String password,
    String name,
  ) async {
    return registerCustomer(email, password, name);
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
