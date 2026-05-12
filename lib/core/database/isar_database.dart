import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/categories/data/category_isar_schema.dart';
import '../../features/products/data/product_isar_schema.dart';
import 'sync_meta_isar_schema.dart';

class IsarDatabase {
  IsarDatabase._();

  static late Isar _isar;

  static Future<void> initialize() async {
    final schemas = [
      ProductIsarSchemaSchema,
      CategoryIsarSchemaSchema,
      SyncMetaIsarSchemaSchema,
    ];

    if (kIsWeb) {
      _isar = await Isar.open(schemas, directory: '.');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(schemas, directory: dir.path);
    }
  }

  static Isar get instance => _isar;
}
