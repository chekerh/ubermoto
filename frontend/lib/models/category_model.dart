class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? parentId;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      parentId: json['parentId']?.toString(),
    );
  }
}
