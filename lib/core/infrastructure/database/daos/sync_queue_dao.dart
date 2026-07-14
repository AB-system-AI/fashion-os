import 'package:drift/drift.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/tables.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';

part of 'app_database.dart';

@DriftAccessor(tables: [SyncQueueItems])
class SyncQueueDao extends DatabaseAccessor<AppDatabase> with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<void> enqueue(SyncQueueItemsCompanion item) {
    return into(syncQueueItems).insert(item, mode: InsertMode.insertOrReplace);
  }

  Future<List<SyncQueueItem>> getPending({int limit = 50, int maxRetries = 10}) {
    final now = DateTime.now().toUtc();
    return (select(syncQueueItems)
          ..where((t) => t.status.isIn(['pending', 'failed']))
          ..where((t) => t.retryCount.isSmallerThanValue(maxRetries))
          ..where((t) => t.scheduledAt.isNull() | t.scheduledAt.isSmallerOrEqualValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)])
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<int> resetStuckProcessing({Duration maxAge = const Duration(minutes: 15)}) async {
    final cutoff = DateTime.now().toUtc().subtract(maxAge);
    return (update(syncQueueItems)
          ..where((t) => t.status.equals('processing'))
          ..where((t) => t.updatedAt.isSmallerThanValue(cutoff)))
        .write(
      const SyncQueueItemsCompanion(
        status: Value('pending'),
      ),
    );
  }

  Future<void> markProcessing(String id) {
    return (update(syncQueueItems)..where((t) => t.id.equals(id))).write(
      SyncQueueItemsCompanion(
        status: const Value('processing'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> markCompleted(String id) {
    return (update(syncQueueItems)..where((t) => t.id.equals(id))).write(
      SyncQueueItemsCompanion(
        status: const Value('completed'),
        updatedAt: Value(DateTime.now().toUtc()),
        errorMessage: const Value(null),
      ),
    );
  }

  Future<void> markFailed(String id, String error, int retryCount) {
    final backoffMinutes = _backoffMinutes(retryCount);
    return (update(syncQueueItems)..where((t) => t.id.equals(id))).write(
      SyncQueueItemsCompanion(
        status: const Value('failed'),
        retryCount: Value(retryCount),
        errorMessage: Value(error),
        updatedAt: Value(DateTime.now().toUtc()),
        scheduledAt: Value(DateTime.now().toUtc().add(Duration(minutes: backoffMinutes))),
      ),
    );
  }

  Future<void> cancel(String id) {
    return (update(syncQueueItems)..where((t) => t.id.equals(id))).write(
      SyncQueueItemsCompanion(
        status: const Value('cancelled'),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<int> countPending() async {
    final count = syncQueueItems.id.count();
    final now = DateTime.now().toUtc();
    final query = selectOnly(syncQueueItems)
      ..addColumns([count])
      ..where(syncQueueItems.status.isIn(['pending', 'failed', 'processing']))
      ..where(
        syncQueueItems.scheduledAt.isNull() |
            syncQueueItems.scheduledAt.isSmallerOrEqualValue(now),
      );
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Stream<int> watchPendingCount() {
    final count = syncQueueItems.id.count();
    final now = DateTime.now().toUtc();
    final query = selectOnly(syncQueueItems)
      ..addColumns([count])
      ..where(syncQueueItems.status.isIn(['pending', 'failed']))
      ..where(
        syncQueueItems.scheduledAt.isNull() |
            syncQueueItems.scheduledAt.isSmallerOrEqualValue(now),
      );
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  int _backoffMinutes(int retryCount) {
    final minutes = 1 << retryCount.clamp(0, 6);
    return minutes.clamp(1, 60);
  }
}
