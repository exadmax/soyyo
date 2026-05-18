import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

  // Only accessed on Android; never called on web (all paths guarded by kIsWeb).
  Isar get _isar => IsarDatabase.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection('users').doc(_uid).collection('products');

  CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _firestore.collection('users').doc(_uid).collection('categories');

  // ── Products ──────────────────────────────────────────────────────────────

  /// Web → Firestore real-time stream.
  /// Android → Isar local stream (instant, offline).
  Stream<List<Product>> watchProducts() {
    if (kIsWeb) {
      return _productsRef
          .orderBy('warrantyEndDate')
          .snapshots()
          .map((snap) => snap.docs.map((d) => Product.fromDoc(d)).toList());
    }
    return _isar.productIsarSchemas
        .where()
        .sortByWarrantyEndDate()
        .watch(fireImmediately: true)
        .map((list) => list.map((s) => s.toDomain()).toList());
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

    if (kIsWeb) {
      // On web, await Firestore so the stream emits the new value immediately.
      await _productsRef.doc(docId).set(updated.toMap(), SetOptions(merge: true));
    } else {
      await _isar.writeTxn(() async {
        await _isar.productIsarSchemas.put(ProductIsarSchema.fromDomain(updated));
      });
      // Fire-and-forget on Android: Isar stream already updated the UI.
      _productsRef.doc(docId).set(updated.toMap(), SetOptions(merge: true));
    }
    return docId;
  }

  Future<void> deleteProduct(String productId) async {
    if (kIsWeb) {
      await _productsRef.doc(productId).delete();
    } else {
      await _isar.writeTxn(() async {
        await _isar.productIsarSchemas.delete(fastHash(productId));
      });
      _productsRef.doc(productId).delete();
    }
  }

  // ── Categories ────────────────────────────────────────────────────────────

  /// Web → Firestore real-time stream.
  /// Android → Isar local stream.
  Stream<List<ProductCategory>> watchCategories() {
    if (kIsWeb) {
      return _categoriesRef
          .orderBy('name')
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => ProductCategory.fromMap(d.id, d.data()))
              .toList());
    }
    return _isar.categoryIsarSchemas
        .where()
        .sortByName()
        .watch(fireImmediately: true)
        .map((list) => list.map((s) => s.toDomain()).toList());
  }

  Future<void> saveCategory(ProductCategory category) async {
    final docId = category.id.isEmpty ? _uuid.v4() : category.id;
    final updated = ProductCategory(id: docId, name: category.name, isDefault: category.isDefault);

    if (kIsWeb) {
      await _categoriesRef.doc(docId).set(updated.toMap(), SetOptions(merge: true));
    } else {
      await _isar.writeTxn(() async {
        await _isar.categoryIsarSchemas.put(CategoryIsarSchema.fromDomain(updated));
      });
      _categoriesRef.doc(docId).set(updated.toMap(), SetOptions(merge: true));
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    if (kIsWeb) {
      await _categoriesRef.doc(categoryId).delete();
    } else {
      await _isar.writeTxn(() async {
        await _isar.categoryIsarSchemas.delete(fastHash(categoryId));
      });
      _categoriesRef.doc(categoryId).delete();
    }
  }

  Future<void> seedDefaultCategories() async {
    final defaults = [
      ProductCategory(id: 'default-eletrodomesticos', name: 'Eletrodomesticos', isDefault: true),
      ProductCategory(id: 'default-eletronicos', name: 'Eletronicos', isDefault: true),
      ProductCategory(id: 'default-servicos', name: 'Servicos', isDefault: true),
    ];

    for (final cat in defaults) {
      if (kIsWeb) {
        final doc = await _categoriesRef.doc(cat.id).get();
        if (!doc.exists) await saveCategory(cat);
      } else {
        final exists = await _isar.categoryIsarSchemas.get(fastHash(cat.id));
        if (exists == null) await saveCategory(cat);
      }
    }
  }

  // ── Periodic Firestore sync (Android only) ────────────────────────────────

  /// No-op on web — Firestore streams already keep the UI in sync.
  Future<void> syncIfNeeded() async {
    if (kIsWeb) return;
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
