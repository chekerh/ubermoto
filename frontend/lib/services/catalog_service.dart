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
}
