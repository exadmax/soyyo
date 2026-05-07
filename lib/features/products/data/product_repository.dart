import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/fast_hash.dart';
import '../../../core/database/isar_database.dart';
import '../../../core/database/sync_meta_isar_schema.dart';
import '../../categories/data/category_isar_schema.dart';
import '../../categories/domain/category.dart';
import '../domain/product.dart';
import 'product_isar_schema.dart';

class ProductRepository {
  ProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  static const _syncInterval = Duration(days: 14);

  Isar get _isar => IsarDatabase.instance;

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _firestore.collection('categories');

  // ── Products ──────────────────────────────────────────────────────────────

  Stream<List<Product>> watchProducts() {
    return _isar.productIsarSchemas
        .where()
        .sortByWarrantyEndDate()
        .watch(fireImmediately: true)
        .map((schemas) => schemas.map((s) => s.toDomain()).toList());
  }

  Future<String> saveProduct(Product product) async {
    final docId = product.id.isEmpty ? _uuid.v4() : product.id;
    final updated = Product(
      id: docId,
      name: product.name,
      categoryId: product.categoryId,
      purchaseDate: product.purchaseDate,
      warrantyEndDate: product.warrantyEndDate,
      guaranteeType: product.guaranteeType,
      noteImageUrl: product.noteImageUrl,
      description: product.description,
    );

    await _isar.writeTxn(() async {
      await _isar.productIsarSchemas.put(ProductIsarSchema.fromDomain(updated));
    });

    _productsRef.doc(docId).set(updated.toMap(), SetOptions(merge: true));

    return docId;
  }

  Future<void> deleteProduct(String productId) async {
    await _isar.writeTxn(() async {
      await _isar.productIsarSchemas.delete(fastHash(productId));
    });
    _productsRef.doc(productId).delete();
  }

  // ── Categories ────────────────────────────────────────────────────────────

  Stream<List<ProductCategory>> watchCategories() {
    return _isar.categoryIsarSchemas
        .where()
        .sortByName()
        .watch(fireImmediately: true)
        .map((schemas) => schemas.map((s) => s.toDomain()).toList());
  }

  Future<void> saveCategory(ProductCategory category) async {
    final docId = category.id.isEmpty ? _uuid.v4() : category.id;
    final updated = ProductCategory(id: docId, name: category.name, isDefault: category.isDefault);

    await _isar.writeTxn(() async {
      await _isar.categoryIsarSchemas.put(CategoryIsarSchema.fromDomain(updated));
    });
    _categoriesRef.doc(docId).set(updated.toMap(), SetOptions(merge: true));
  }

  Future<void> seedDefaultCategories() async {
    final defaults = [
      ProductCategory(id: 'default-eletrodomesticos', name: 'Eletrodomesticos', isDefault: true),
      ProductCategory(id: 'default-eletronicos', name: 'Eletronicos', isDefault: true),
      ProductCategory(id: 'default-servicos', name: 'Servicos', isDefault: true),
    ];

    for (final category in defaults) {
      final exists = await _isar.categoryIsarSchemas.get(fastHash(category.id));
      if (exists == null) {
        await saveCategory(category);
      }
    }
  }

  // ── Periodic Firestore sync ───────────────────────────────────────────────

  /// Syncs from Firestore only if [_syncInterval] has elapsed since the last
  /// successful sync (or if the app has never synced before).
  /// Safe to call fire-and-forget from initState.
  Future<void> syncIfNeeded() async {
    if (!await _isSyncDue()) return;
    await _fetchFromFirestore();
    await _markSynced();
  }

  Future<bool> _isSyncDue() async {
    final meta = await _isar.syncMetaIsarSchemas.get(1);
    if (meta?.lastSyncAt == null) return true;
    return DateTime.now().difference(meta!.lastSyncAt!) >= _syncInterval;
  }

  Future<void> _fetchFromFirestore() async {
    final productsSnap = await _productsRef.orderBy('warrantyEndDate').get();
    final productSchemas = productsSnap.docs
        .map((doc) => ProductIsarSchema.fromDomain(Product.fromDoc(doc)))
        .toList();

    final categoriesSnap = await _categoriesRef.orderBy('name').get();
    final categorySchemas = categoriesSnap.docs
        .map((doc) => CategoryIsarSchema.fromDomain(
              ProductCategory.fromMap(doc.id, doc.data()),
            ))
        .toList();

    await _isar.writeTxn(() async {
      await _isar.productIsarSchemas.putAll(productSchemas);
      await _isar.categoryIsarSchemas.putAll(categorySchemas);
    });
  }

  Future<void> _markSynced() async {
    await _isar.writeTxn(() async {
      await _isar.syncMetaIsarSchemas.put(
        SyncMetaIsarSchema()..lastSyncAt = DateTime.now(),
      );
    });
  }
}
