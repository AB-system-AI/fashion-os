import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/pos/data/repositories/pos_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/sale.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';

void main() {
  late AppDatabase db;
  late SaleLocalRepository repository;

  setUp(() async {
    db = AppDatabase.inMemory();
    await db.executor.ensureOpen(db);
    repository = SaleLocalRepository(database: db, syncQueue: SyncQueueWriter(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('creates and loads sale by order number', () async {
    final now = DateTime.utc(2025, 7, 12);
    final created = await repository.create(
      Sale(
        id: 'sale-1',
        tenantId: 't1',
        storeId: 'st1',
        orderNumber: 'SO-000001',
        employeeId: 'e1',
        status: SaleStatus.draft,
        lines: const [],
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );

    final loaded = await repository.findByOrderNumber('t1', 'SO-000001');
    expect(loaded?.id, created.id);
    expect(loaded?.orderNumber, 'SO-000001');
  });
}
