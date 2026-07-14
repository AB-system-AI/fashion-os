import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/workflow/scheduler_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/scheduler.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/enums/workflow_enums.dart';

void main() {
  late WorkflowSchedulerEngine engine;

  setUp(() => engine = WorkflowSchedulerEngine());

  ScheduledJobRecord job({
    JobScheduleType type = JobScheduleType.recurring,
    int? intervalSeconds,
    String? cron,
    DateTime? nextRunAt,
    JobStatus status = JobStatus.pending,
  }) =>
      ScheduledJobRecord(
        id: 'job-1',
        tenantId: 'tenant-1',
        name: 'Reminder',
        jobType: 'workflow',
        scheduleType: type,
        status: status,
        intervalSeconds: intervalSeconds ?? 3600,
        cronExpression: cron,
        nextRunAt: nextRunAt,
        version: 1,
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      );

  test('validateCron accepts 5-field expression', () {
    expect(engine.validateCron('0 9 * * *').isValid, isTrue);
  });

  test('validateCron rejects invalid field count', () {
    expect(engine.validateCron('0 9 *').isValid, isFalse);
  });

  test('isDue returns true when next run is in the past', () {
    final past = DateTime.utc(2025, 1, 1, 8);
    expect(engine.isDue(job: job(nextRunAt: past), now: DateTime.utc(2025, 1, 1, 10)), isTrue);
  });

  test('markFailed schedules retry with backoff', () {
    final failed = engine.markFailed(job(), retry: true);
    expect(failed.retryCount, 1);
    expect(failed.nextRunAt, isNotNull);
    expect(failed.status, JobStatus.pending);
  });

  test('evaluateHealth reports degraded when failures exist', () {
    final health = engine.evaluateHealth(
      jobs: [job(status: JobStatus.failed)],
      recentLogs: [
        JobExecutionLog(
          id: 'log-1',
          tenantId: 'tenant-1',
          jobId: 'job-1',
          startedAt: DateTime.utc(2025, 1, 1),
          success: false,
          version: 1,
          createdAt: DateTime.utc(2025, 1, 1),
          updatedAt: DateTime.utc(2025, 1, 1),
          syncStatus: LocalSyncStatus.synced,
          isDirty: false,
        ),
      ],
    );
    expect(health.isHealthy, isFalse);
    expect(health.failedJobCount, 1);
  });
}
