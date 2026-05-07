class ProductCategory {
  ProductCategory({
    required this.id,
    required this.name,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final bool isDefault;

  factory ProductCategory.fromMap(String id, Map<String, dynamic> map) {
    return ProductCategory(
      id: id,
      name: (map['name'] as String?)?.trim() ?? 'Sem nome',
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isDefault': isDefault,
    };
  }
}
