class MerchantModel {
  final String id;
  final String name;
  final String region;
  final String? logoUrl;
  final bool isActive;

  MerchantModel({
    required this.id,
    required this.name,
    required this.region,
    this.logoUrl,
    this.isActive = true,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      region: json['region'] ?? '',
      logoUrl: json['logoUrl'],
      isActive: json['isActive'] ?? true,
    );
  }
}
