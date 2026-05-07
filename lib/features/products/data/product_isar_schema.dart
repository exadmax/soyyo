import 'package:isar/isar.dart';

import '../../../core/database/fast_hash.dart';
import '../domain/guarantee_type.dart';
import '../domain/product.dart';

part 'product_isar_schema.g.dart';

@Collection()
class ProductIsarSchema {
  Id get id => fastHash(firestoreId);

  @Index(unique: true)
  late String firestoreId;

  late String name;
  late String categoryId;
  late DateTime purchaseDate;
  late DateTime warrantyEndDate;
  late String guaranteeTypeName;
  String? noteImageUrl;
  String? description;

  Product toDomain() => Product(
        id: firestoreId,
        name: name,
        categoryId: categoryId,
        purchaseDate: purchaseDate,
        warrantyEndDate: warrantyEndDate,
        guaranteeType: GuaranteeType.values.byName(guaranteeTypeName),
        noteImageUrl: noteImageUrl,
        description: description,
      );

  static ProductIsarSchema fromDomain(Product product) {
    return ProductIsarSchema()
      ..firestoreId = product.id
      ..name = product.name
      ..categoryId = product.categoryId
      ..purchaseDate = product.purchaseDate
      ..warrantyEndDate = product.warrantyEndDate
      ..guaranteeTypeName = product.guaranteeType.name
      ..noteImageUrl = product.noteImageUrl
      ..description = product.description;
  }
}
