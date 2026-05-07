import 'package:isar/isar.dart';

import '../../../core/database/fast_hash.dart';
import '../domain/category.dart';

part 'category_isar_schema.g.dart';

@Collection()
class CategoryIsarSchema {
  Id get id => fastHash(firestoreId);

  @Index(unique: true)
  late String firestoreId;

  late String name;
  late bool isDefault;

  ProductCategory toDomain() => ProductCategory(
        id: firestoreId,
        name: name,
        isDefault: isDefault,
      );

  static CategoryIsarSchema fromDomain(ProductCategory category) {
    return CategoryIsarSchema()
      ..firestoreId = category.id
      ..name = category.name
      ..isDefault = category.isDefault;
  }
}
