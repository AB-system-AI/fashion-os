import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/hr/data/repositories/hr_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/entities/employee.dart';
import 'package:fashion_pos_enterprise/features/hr/domain/enums/hr_enums.dart';

void main() {
  late AppDatabase db;
  late EmployeeLocalRepository repository;

  setUp(() async {
    db = AppDatabase.inMemory();
    await db.executor.ensureOpen(db);
    repository = EmployeeLocalRepository(database: db, syncQueue: SyncQueueWriter(db));
  });

  tearDown(() async {
    await db.close();
  });

  test('create employee persists offline with sync queue', () async {
    final now = DateTime.now().toUtc();
    final created = await repository.create(
      Employee(
        id: 'e1',
        tenantId: 't1',
        employeeCode: 'EMP-00001',
        firstName: 'Jane',
        lastName: 'Doe',
        status: EmployeeStatus.active,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    expect(created.fullName, 'Jane Doe');

    final loaded = await repository.findByCode('t1', 'EMP-00001');
    expect(loaded?.firstName, 'Jane');

    final pending = await db.syncQueueDao.getPending();
    expect(pending.any((e) => e.entityType == Employee.entityTypeName), isTrue);
  });
}
