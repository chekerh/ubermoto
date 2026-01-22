import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../core/errors/app_exception.dart';
import '../core/utils/storage_service.dart';
import '../core/utils/retry_helper.dart';

class ApiService {
  static Future<Map<String, String>> _getHeaders({
    bool requiresAuth = false,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await StorageService.getToken();
      print('API Service - Token for auth: ${token != null ? 'present (${token.length} chars)' : 'null'}');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<http.Response> get(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    return RetryHelper.withTimeout(
      () => RetryHelper.retry(
        () async {
          try {
            final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
            final headers = await _getHeaders(requiresAuth: requiresAuth);

            final response = await http.get(uri, headers: headers);

            if (response.statusCode >= 200 && response.statusCode < 300) {
              return response;
            } else {
              throw _handleError(response);
            }
          } catch (e) {
            if (e is AppException) {
              rethrow;
            }
            throw NetworkException('Network error: ${e.toString()}');
          }
        },
        shouldRetry: (e) => e is NetworkException,
      ),
    );
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    return RetryHelper.withTimeout(
      () => RetryHelper.retry(
        () async {
          try {
            final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
            final headers = await _getHeaders(requiresAuth: requiresAuth);

            final response = await http.post(
              uri,
              headers: headers,
              body: jsonEncode(body),
            );

            if (response.statusCode >= 200 && response.statusCode < 300) {
              return response;
            } else {
              throw _handleError(response);
            }
          } catch (e) {
            if (e is AppException) {
              rethrow;
            }
            throw NetworkException('Network error: ${e.toString()}');
          }
        },
        shouldRetry: (e) => e is NetworkException,
      ),
    );
  }

  static Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await http.patch(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  static Future<http.Response> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  static AppException _handleError(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final message = json['message'] as String? ?? 'An error occurred';
      
      if (statusCode == 401) {
        return AuthenticationException(message);
      } else if (statusCode >= 500) {
        return ServerException(message);
      } else {
        return ValidationException(message);
      }
    } catch (_) {
      if (statusCode == 401) {
        return const AuthenticationException('Unauthorized');
      } else if (statusCode >= 500) {
        return const ServerException('Server error');
      } else {
        return ValidationException('Error: $body');
      }
    }
  }
}
