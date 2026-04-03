class Warranty {
  final String id;
  final String productName;
  final String brand;
  final String? serialNumber;
  final DateTime purchaseDate;
  final DateTime expirationDate;
  final String? notes;
  final List<String> imagePaths;

  Warranty({
    required this.id,
    required this.productName,
    required this.brand,
    this.serialNumber,
    required this.purchaseDate,
    required this.expirationDate,
    this.notes,
    this.imagePaths = const [],
  });

  bool get isExpired => expirationDate.isBefore(DateTime.now());

  bool get isExpiringSoon {
    final daysUntilExpiry = expirationDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= 30;
  }

  int get daysUntilExpiry => expirationDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'brand': brand,
      'serialNumber': serialNumber,
      'purchaseDate': purchaseDate.toIso8601String(),
      'expirationDate': expirationDate.toIso8601String(),
      'notes': notes,
      'imagePaths': imagePaths.join('|'),
    };
  }

  factory Warranty.fromMap(Map<String, dynamic> map) {
    return Warranty(
      id: map['id'] as String,
      productName: map['productName'] as String,
      brand: map['brand'] as String,
      serialNumber: map['serialNumber'] as String?,
      purchaseDate: DateTime.parse(map['purchaseDate'] as String),
      expirationDate: DateTime.parse(map['expirationDate'] as String),
      notes: map['notes'] as String?,
      imagePaths: (map['imagePaths'] as String?)
              ?.split('|')
              .where((p) => p.isNotEmpty)
              .toList() ??
          [],
    );
  }

  Warranty copyWith({
    String? id,
    String? productName,
    String? brand,
    String? serialNumber,
    DateTime? purchaseDate,
    DateTime? expirationDate,
    String? notes,
    List<String>? imagePaths,
  }) {
    return Warranty(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      serialNumber: serialNumber ?? this.serialNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expirationDate: expirationDate ?? this.expirationDate,
      notes: notes ?? this.notes,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }
}
