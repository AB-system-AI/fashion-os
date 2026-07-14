import 'package:drift/drift.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/tables.dart';

part of 'app_database.dart';

@DriftAccessor(tables: [SyncLogs])
class SyncLogDao extends DatabaseAccessor<AppDatabase> with _$SyncLogDaoMixin {
  SyncLogDao(super.db);

  Future<void> append(SyncLogsCompanion entry) {
    return into(syncLogs).insert(entry);
  }

  Future<List<SyncLog>> getRecent({int limit = 200, String? tenantId}) {
    final query = select(syncLogs)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit);
    if (tenantId != null) {
      query.where((t) => t.tenantId.equals(tenantId));
    }
    return query.get();
  }

  Future<void> pruneOlderThan(Duration maxAge) {
    final cutoff = DateTime.now().toUtc().subtract(maxAge);
    return (delete(syncLogs)..where((t) => t.createdAt.isSmallerThanValue(cutoff))).go();
  }
}
