import 'package:flutter_test/flutter_test.dart';
import 'package:soyyo/models/warranty.dart';

void main() {
  group('Warranty model', () {
    late Warranty warranty;

    setUp(() {
      warranty = Warranty(
        id: 'test-id-001',
        productName: 'Geladeira Samsung',
        brand: 'Samsung',
        serialNumber: 'SN123456',
        purchaseDate: DateTime(2023, 1, 15),
        expirationDate: DateTime.now().add(const Duration(days: 60)),
        notes: 'Comprada na Loja XYZ',
        imagePaths: ['path/to/nota.jpg'],
      );
    });

    test('toMap and fromMap roundtrip', () {
      final map = warranty.toMap();
      final restored = Warranty.fromMap(map);

      expect(restored.id, equals(warranty.id));
      expect(restored.productName, equals(warranty.productName));
      expect(restored.brand, equals(warranty.brand));
      expect(restored.serialNumber, equals(warranty.serialNumber));
      expect(
        restored.purchaseDate.toIso8601String(),
        equals(warranty.purchaseDate.toIso8601String()),
      );
      expect(
        restored.expirationDate.toIso8601String(),
        equals(warranty.expirationDate.toIso8601String()),
      );
      expect(restored.notes, equals(warranty.notes));
      expect(restored.imagePaths, equals(warranty.imagePaths));
    });

    test('isExpired returns false for future expiration', () {
      expect(warranty.isExpired, isFalse);
    });

    test('isExpired returns true for past expiration', () {
      final expired = warranty.copyWith(
        expirationDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(expired.isExpired, isTrue);
    });

    test('isExpiringSoon returns true when expiring within 30 days', () {
      final soon = warranty.copyWith(
        expirationDate: DateTime.now().add(const Duration(days: 15)),
      );
      expect(soon.isExpiringSoon, isTrue);
    });

    test('isExpiringSoon returns false when expiring after 30 days', () {
      final notSoon = warranty.copyWith(
        expirationDate: DateTime.now().add(const Duration(days: 60)),
      );
      expect(notSoon.isExpiringSoon, isFalse);
    });

    test('daysUntilExpiry is correct', () {
      final w = warranty.copyWith(
        expirationDate: DateTime.now().add(const Duration(days: 10)),
      );
      expect(w.daysUntilExpiry, closeTo(10, 1));
    });

    test('copyWith updates only specified fields', () {
      final updated = warranty.copyWith(productName: 'Televisão LG');
      expect(updated.productName, equals('Televisão LG'));
      expect(updated.brand, equals(warranty.brand));
      expect(updated.id, equals(warranty.id));
    });

    test('imagePaths roundtrip with multiple paths', () {
      final multi = warranty.copyWith(
        imagePaths: ['path/a.jpg', 'path/b.jpg', 'path/c.jpg'],
      );
      final map = multi.toMap();
      final restored = Warranty.fromMap(map);
      expect(restored.imagePaths, equals(['path/a.jpg', 'path/b.jpg', 'path/c.jpg']));
    });

    test('empty imagePaths roundtrip', () {
      final noPhotos = warranty.copyWith(imagePaths: []);
      final map = noPhotos.toMap();
      final restored = Warranty.fromMap(map);
      expect(restored.imagePaths, isEmpty);
    });

    test('optional fields can be null', () {
      final minimal = Warranty(
        id: 'min-id',
        productName: 'Produto',
        brand: 'Marca',
        purchaseDate: DateTime(2024, 1, 1),
        expirationDate: DateTime(2025, 1, 1),
      );
      expect(minimal.serialNumber, isNull);
      expect(minimal.notes, isNull);
      expect(minimal.imagePaths, isEmpty);

      final map = minimal.toMap();
      final restored = Warranty.fromMap(map);
      expect(restored.serialNumber, isNull);
      expect(restored.notes, isNull);
    });
  });
}
