import 'package:drift/drift.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/tables.dart';

part of 'app_database.dart';

@DriftAccessor(tables: [SyncConflictHistory])
class SyncConflictDao extends DatabaseAccessor<AppDatabase> with _$SyncConflictDaoMixin {
  SyncConflictDao(super.db);

  Future<void> insertConflict(SyncConflictHistoryCompanion entry) {
    return into(syncConflictHistory).insert(entry);
  }

  Future<List<SyncConflictHistoryData>> listForEntity({
    required String tenantId,
    required String entityType,
    required String entityId,
    int limit = 20,
  }) {
    return (select(syncConflictHistory)
          ..where((t) => t.tenantId.equals(tenantId))
          ..where((t) => t.entityType.equals(entityType))
          ..where((t) => t.entityId.equals(entityId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }
}
