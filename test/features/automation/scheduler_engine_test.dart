import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/automation/scheduler_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/scheduled_job.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/value_objects/automation_value_objects.dart';

void main() {
  late SchedulerEngine engine;

  setUp(() => engine = SchedulerEngine());

  test('validateCron accepts 5-field expression', () {
    expect(engine.validateCron('0 8 * * *').isValid, isTrue);
  });

  test('validateCron rejects empty expression', () {
    expect(engine.validateCron('').isValid, isFalse);
  });

  test('computeNextRun for recurring interval', () {
    final now = DateTime.utc(2025, 6, 1, 10);
    final result = engine.computeNextRun(
      spec: const ScheduleSpec(scheduleType: JobScheduleType.recurring, intervalSeconds: 3600),
      now: now,
    );
    expect(result.nextRunAt, now.add(const Duration(hours: 1)));
  });

  test('isDue returns true when next run is in the past', () {
    final now = DateTime.utc(2025, 6, 1, 12);
    final job = ScheduledJob(
      id: 'j1',
      tenantId: 't1',
      name: 'Test',
      nextRunAt: DateTime.utc(2025, 6, 1, 11),
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    expect(engine.isDue(job: job, now: now), isTrue);
  });

  test('sortByPriority puts due jobs first', () {
    final now = DateTime.utc(2025, 6, 1, 12);
    final due = ScheduledJob(
      id: 'due',
      tenantId: 't1',
      name: 'Due',
      nextRunAt: DateTime.utc(2025, 6, 1, 11),
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    final future = ScheduledJob(
      id: 'future',
      tenantId: 't1',
      name: 'Future',
      nextRunAt: DateTime.utc(2025, 6, 2),
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    final sorted = engine.sortByPriority([future, due], now: now);
    expect(sorted.first.id, 'due');
  });
}
