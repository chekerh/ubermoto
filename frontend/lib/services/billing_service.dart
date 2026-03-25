import 'dart:convert';
import '../core/errors/app_exception.dart';
import 'api_service.dart';

class BillingService {
  Future<List<dynamic>> listPlans() async {
    try {
      final res = await ApiService.get('/billing/plans');
      final decoded = jsonDecode(res.body);
      if (decoded is List<dynamic>) return decoded;
      throw const ServerException('Invalid plans response');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to load plans: ${e.toString()}');
    }
  }

  Future<String> createCheckoutSession({
    required String merchantId,
    required String planKey,
    required String successUrl,
    required String cancelUrl,
  }) async {
    try {
      final res = await ApiService.post(
        '/billing/merchant/checkout-session',
        {
          'merchantId': merchantId,
          'planKey': planKey,
          'successUrl': successUrl,
          'cancelUrl': cancelUrl,
        },
        requiresAuth: true,
      );
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final url = decoded['url'] as String?;
      if (url == null || url.isEmpty) {
        throw const ServerException('Missing checkout URL');
      }
      return url;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to create checkout session: ${e.toString()}');
    }
  }

  Future<String> createPortalSession({
    required String merchantId,
    required String returnUrl,
  }) async {
    try {
      final res = await ApiService.post(
        '/billing/merchant/portal-session',
        {
          'merchantId': merchantId,
          'returnUrl': returnUrl,
        },
        requiresAuth: true,
      );
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final url = decoded['url'] as String?;
      if (url == null || url.isEmpty) {
        throw const ServerException('Missing portal URL');
      }
      return url;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to create portal session: ${e.toString()}');
    }
  }

  Future<String> createCheckoutSessionForMe({
    required String planKey,
    required String successUrl,
    required String cancelUrl,
  }) async {
    try {
      final res = await ApiService.post(
        '/billing/merchant/me/checkout-session',
        {
          'planKey': planKey,
          'successUrl': successUrl,
          'cancelUrl': cancelUrl,
        },
        requiresAuth: true,
      );
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final url = decoded['url'] as String?;
      if (url == null || url.isEmpty) {
        throw const ServerException('Missing checkout URL');
      }
      return url;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to create self checkout session: ${e.toString()}');
    }
  }

  Future<String> createPortalSessionForMe({required String returnUrl}) async {
    try {
      final res = await ApiService.post(
        '/billing/merchant/me/portal-session',
        {
          'returnUrl': returnUrl,
        },
        requiresAuth: true,
      );
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final url = decoded['url'] as String?;
      if (url == null || url.isEmpty) {
        throw const ServerException('Missing portal URL');
      }
      return url;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to create self portal session: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getMerchantSummaryForMe() async {
    try {
      final res = await ApiService.get('/billing/merchant/me/summary', requiresAuth: true);
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const ServerException('Invalid merchant summary response');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to load merchant summary: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getMyMemberships() async {
    try {
      final res = await ApiService.get('/billing/me/memberships', requiresAuth: true);
      final decoded = jsonDecode(res.body);
      if (decoded is! List) {
        throw const ServerException('Invalid memberships response');
      }
      return decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to load memberships: ${e.toString()}');
    }
  }
}

