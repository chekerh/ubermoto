import 'dart:async';
import '../errors/app_exception.dart';

class RetryHelper {
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(AppException)? shouldRetry,
  }) async {
    AppException? lastException;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation();
      } on AppException catch (e) {
        lastException = e;

        // Don't retry on authentication errors
        if (e is AuthenticationException) {
          rethrow;
        }

        // Check if we should retry this specific error
        if (shouldRetry != null && !shouldRetry(e)) {
          rethrow;
        }

        // Don't retry on the last attempt
        if (attempt == maxAttempts) {
          break;
        }

        // Wait before retrying with exponential backoff
        await Future.delayed(delay * attempt);
      }
    }

    throw lastException ?? NetworkException('Operation failed after $maxAttempts attempts');
  }

  static Future<T> withTimeout<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 30),
    String timeoutMessage = 'Operation timed out',
  }) async {
    try {
      return await operation().timeout(timeout);
    } on TimeoutException {
      throw NetworkException(timeoutMessage);
    }
  }
}