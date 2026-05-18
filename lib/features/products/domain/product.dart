import 'package:cloud_firestore/cloud_firestore.dart';

import 'guarantee_type.dart';

class Product {
  Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.purchaseDate,
    required this.warrantyEndDate,
    required this.guaranteeType,
    this.noteImageUrl,
    this.description,
  });

  final String id;
  final String name;
  final String categoryId;
  final DateTime purchaseDate;
  final DateTime warrantyEndDate;
  final GuaranteeType guaranteeType;
  final String? noteImageUrl;
  final String? description;

  bool get isExpired => warrantyEndDate.isBefore(DateTime.now());

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    return Product(
      id: doc.id,
      name: (data['name'] as String?)?.trim() ?? 'Produto sem nome',
      categoryId: data['categoryId'] as String? ?? '',
      purchaseDate: (data['purchaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      warrantyEndDate: (data['warrantyEndDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      guaranteeType: GuaranteeType.values.firstWhere(
        (e) => e.name == ((data['guaranteeType'] as String?) ?? ''),
        orElse: () => GuaranteeType.standard,
      ),
      noteImageUrl: data['noteImageUrl'] as String?,
      description: data['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'categoryId': categoryId,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'warrantyEndDate': Timestamp.fromDate(warrantyEndDate),
      'guaranteeType': guaranteeType.name,
      'noteImageUrl': noteImageUrl,
      'description': description,
    };
  }
}
