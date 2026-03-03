import 'dart:convert';

import '../core/errors/app_exception.dart';
import '../models/product_model.dart';
import 'api_service.dart';

class RecommendationsService {
  Future<List<ProductModel>> getMine() async {
    try {
      final res = await ApiService.get('/recommendations', requiresAuth: true);
      final data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    } on AppException {
      rethrow;
    }
  }

  Future<List<ProductModel>> getFrequentlyBoughtTogether(String productId) async {
    try {
      final res = await ApiService.get('/products/$productId/fbt', requiresAuth: true);
      final data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    } on AppException {
      rethrow;
    }
  }
}
