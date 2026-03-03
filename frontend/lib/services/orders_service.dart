import 'dart:convert';

import '../core/errors/app_exception.dart';
import '../models/order_model.dart';
import 'api_service.dart';

class OrdersService {
  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> items,
    String? address,
    String? region,
    String? type, // MARKET|DELIVERY|RIDE|PARTS
    String? paymentMethod, // COD etc
  }) async {
    try {
      final res = await ApiService.post('/orders', {
        'items': items,
        if (address != null) 'address': address,
        if (region != null) 'region': region,
        if (type != null) 'type': type,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
      }, requiresAuth: true);
      return OrderModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } on AppException {
      rethrow;
    }
  }

  Future<List<OrderModel>> listMine() async {
    try {
      final res = await ApiService.get('/orders', requiresAuth: true);
      final data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    } on AppException {
      rethrow;
    }
  }

  Future<OrderModel> getOrder(String id) async {
    try {
      final res = await ApiService.get('/orders/$id', requiresAuth: true);
      return OrderModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } on AppException {
      rethrow;
    }
  }
}
