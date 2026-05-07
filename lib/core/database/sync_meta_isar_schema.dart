import 'package:isar/isar.dart';

part 'sync_meta_isar_schema.g.dart';

@Collection()
class SyncMetaIsarSchema {
  // Fixed ID = 1: there is always exactly one record in this collection.
  Id id = 1;

  DateTime? lastSyncAt;
}
