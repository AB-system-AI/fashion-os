import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/automation/data/datasources/automation_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/automation/data/sync/automation_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/automation_rule.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/scheduled_job.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/workflow.dart';

void main() {
  test('automation sync processors map entity types to remote tables', () {
    final remote = AutomationRemoteDataSource();
    expect(
      AutomationSyncProcessor(remote: remote, entityTypeName: AutomationRule.entityTypeName, remoteTable: 'automation_rules').entityType,
      'automation_rule',
    );
    expect(
      AutomationSyncProcessor(remote: remote, entityTypeName: AutomationWorkflow.entityTypeName, remoteTable: 'automation_workflows').entityType,
      'automation_workflow',
    );
    expect(
      AutomationSyncProcessor(remote: remote, entityTypeName: ScheduledJob.entityTypeName, remoteTable: 'scheduled_jobs').entityType,
      'scheduled_job',
    );
    expect(
      AutomationSyncProcessor(remote: remote, entityTypeName: WorkflowStep.entityTypeName, remoteTable: 'workflow_steps').entityType,
      'workflow_step',
    );
  });
}
