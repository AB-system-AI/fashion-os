import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/workflow_execution.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/enums/workflow_enums.dart';

void main() {
  test('WorkflowStatistics computes success rate', () {
    final stats = WorkflowStatistics(
      id: 'stat-1',
      tenantId: 'tenant-1',
      templateId: 'tpl-1',
      periodStart: _t,
      periodEnd: _t,
      totalExecutions: 10,
      completedCount: 8,
      failedCount: 2,
      avgDurationSeconds: 120,
      version: 1,
      createdAt: _t,
      updatedAt: _t,
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    expect(stats.successRate, closeTo(0.8, 0.001));
  });

  test('WorkflowExecution isActive for pending and running', () {
    final pending = WorkflowExecution(
      id: 'ex-1',
      tenantId: 'tenant-1',
      templateId: 'tpl-1',
      versionId: 'ver-1',
      status: WorkflowExecutionStatus.pending,
      version: 1,
      createdAt: _t,
      updatedAt: _t,
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    expect(pending.isActive, isTrue);

    final completed = WorkflowExecution(
      id: 'ex-2',
      tenantId: 'tenant-1',
      templateId: 'tpl-1',
      versionId: 'ver-1',
      status: WorkflowExecutionStatus.completed,
      version: 1,
      createdAt: _t,
      updatedAt: _t,
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    expect(completed.isActive, isFalse);
  });

  test('WorkflowExecutionLog duration when completed', () {
    final log = WorkflowExecutionLog(
      id: 'log-1',
      tenantId: 'tenant-1',
      executionId: 'ex-1',
      message: 'Done',
      occurredAt: DateTime.utc(2025, 1, 1, 10, 5),
      version: 1,
      createdAt: _t,
      updatedAt: _t,
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    expect(log.duration, isNull);
  });
}

final _t = DateTime.utc(2025, 1, 1);
