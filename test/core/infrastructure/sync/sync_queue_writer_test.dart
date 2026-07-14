import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:flutter_test/flutter_test.dart';

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

  test('enqueue creates pending sync item', () async {
    final id = await writer.enqueue(
      tenantId: 'tenant-1',
      entityType: 'product',
      entityId: 'prod-1',
      operation: SyncOperation.create,
      payload: {'name': 'Shirt'},
    );

    final pending = await db.syncQueueDao.getPending();
    expect(pending.length, 1);
    expect(pending.first.id, id);
    expect(pending.first.status, 'pending');
  });

  test('markCompleted removes item from pending processing', () async {
    final id = await writer.enqueue(
      tenantId: 'tenant-1',
      entityType: 'product',
      entityId: 'prod-1',
      operation: SyncOperation.update,
      payload: {'name': 'Shirt'},
    );
    await db.syncQueueDao.markCompleted(id);
    final count = await db.syncQueueDao.countPending();
    expect(count, 0);
  });
}
