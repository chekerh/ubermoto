import 'dart:convert';

import '../core/errors/app_exception.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import 'api_service.dart';

class CatalogService {
  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await ApiService.get('/catalog/categories');
      final data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } on AppException {
      rethrow;
    }
  }

  Future<List<ProductModel>> getProducts({String? categoryId, String? search, String? region}) async {
    final params = <String, String>{};
    if (categoryId != null) params['categoryId'] = categoryId;
    if (search != null) params['search'] = search;
    if (region != null) params['region'] = region;
    final query = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    final path = query.isEmpty ? '/catalog/products' : '/catalog/products?$query';
    try {
      final res = await ApiService.get(path);
      final data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    } on AppException {
      rethrow;
    }
  }

  Future<ProductModel?> getProduct(String id) async {
    try {
      final res = await ApiService.get('/catalog/products/$id');
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    } on AppException {
      rethrow;
    }
  }

  Future<List<ProductModel>> getRelated(String id) async {
    try {
      final res = await ApiService.get('/catalog/products/$id/related');
      final data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    } on AppException {
      rethrow;
    }
  }

  /// Authenticated inventory for the signed-in merchant (or admin with `merchantId`).
  Future<List<ProductModel>> getMerchantProducts({String? merchantId}) async {
    try {
      final path = merchantId == null || merchantId.isEmpty
          ? '/catalog/merchant/products'
          : '/catalog/merchant/products?merchantId=${Uri.encodeComponent(merchantId)}';
      final res = await ApiService.get(path, requiresAuth: true);
      final data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to load merchant products: ${e.toString()}');
    }
  }

  Future<ProductModel> createProductAuthenticated(Map<String, dynamic> body) async {
    try {
      final res = await ApiService.post('/catalog/products', body, requiresAuth: true);
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to create product: ${e.toString()}');
    }
  }

  Future<ProductModel> updateProductAuthenticated(
    String id,
    Map<String, dynamic> body, {
    String? merchantIdQuery,
  }) async {
    try {
      final path = merchantIdQuery != null && merchantIdQuery.isNotEmpty
          ? '/catalog/products/$id?merchantId=${Uri.encodeComponent(merchantIdQuery)}'
          : '/catalog/products/$id';
      final res = await ApiService.patch(path, body, requiresAuth: true);
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to update product: ${e.toString()}');
    }
  }

  Future<void> deleteProductAuthenticated(String id, {String? merchantIdQuery}) async {
    try {
      final path = merchantIdQuery != null && merchantIdQuery.isNotEmpty
          ? '/catalog/products/$id?merchantId=${Uri.encodeComponent(merchantIdQuery)}'
          : '/catalog/products/$id';
      await ApiService.delete(path, requiresAuth: true);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to delete product: ${e.toString()}');
    }
  }
}
