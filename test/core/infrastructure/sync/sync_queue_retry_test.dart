import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';

void main() {
  late AppDatabase db;
  late SyncQueueWriter writer;

  setUp(() async {
    db = AppDatabase.inMemory();
    await db.executor.ensureOpen(db);
    writer = SyncQueueWriter(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('getPending respects scheduled_at backoff', () async {
    final id = await writer.enqueue(
      tenantId: 't1',
      entityType: 'product',
      entityId: 'p1',
      operation: SyncOperation.update,
      payload: {'name': 'Shirt'},
    );

    await db.syncQueueDao.markFailed(id, 'network', 2);

    final pendingNow = await db.syncQueueDao.getPending();
    expect(pendingNow.where((e) => e.id == id), isEmpty);

    final row = await (db.select(db.syncQueueItems)..where((t) => t.id.equals(id))).getSingle();
    expect(row.scheduledAt, isNotNull);
    expect(row.scheduledAt!.isAfter(DateTime.now().toUtc()), isTrue);
  });

  test('resetStuckProcessing returns processing items to pending', () async {
    final id = await writer.enqueue(
      tenantId: 't1',
      entityType: 'product',
      entityId: 'p2',
      operation: SyncOperation.create,
      payload: {'name': 'Pants'},
    );

    await db.syncQueueDao.markProcessing(id);
    await db.customStatement(
      "UPDATE sync_queue_items SET updated_at = datetime('now', '-20 minutes') WHERE id = ?",
      [id],
    );

    final reset = await db.syncQueueDao.resetStuckProcessing();
    expect(reset, greaterThanOrEqualTo(1));

    final row = await (db.select(db.syncQueueItems)..where((t) => t.id.equals(id))).getSingle();
    expect(row.status, 'pending');
  });
}
