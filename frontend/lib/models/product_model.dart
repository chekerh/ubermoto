import 'merchant_model.dart';
import 'category_model.dart';

class ProductModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final MerchantModel? merchant;
  final List<CategoryModel> categories;
  final List<String> images;
  final List<String> tags;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    this.merchant,
    this.categories = const [],
    this.images = const [],
    this.tags = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      merchant: json['merchantId'] != null ? MerchantModel.fromJson(json['merchantId']) : null,
      categories: (json['categoryIds'] as List<dynamic>? ?? [])
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      tags: (json['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }
}
