import 'dart:convert';

import '../core/errors/app_exception.dart';
import 'api_service.dart';

class SurgeService {
  Future<List<dynamic>> listRules() async {
    try {
      final res = await ApiService.get('/surge-rules', requiresAuth: true);
      return jsonDecode(res.body) as List<dynamic>;
    } on AppException {
      rethrow;
    }
  }

  Future<double> preview({required String region, double? lat, double? lng, DateTime? time}) async {
    try {
      final body = {
        'region': region,
        if (lat != null && lng != null) 'latitude': lat,
        if (lat != null && lng != null) 'longitude': lng,
        if (time != null) 'timestamp': time.toIso8601String(),
      };
      final res = await ApiService.post('/surge-rules/preview', body);
      final parsed = jsonDecode(res.body);
      return (parsed is num) ? parsed.toDouble() : 1.0;
    } on AppException {
      rethrow;
    }
  }
}
