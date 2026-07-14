import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/workflow/data/datasources/workflow_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/workflow/data/sync/workflow_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/approval.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/notification.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/workflow_instance.dart';

void main() {
  test('workflow sync processors map entity types to remote tables', () {
    final remote = WorkflowRemoteDataSource();
    expect(
      WorkflowSyncProcessor(remote: remote, entityTypeName: TenantWorkflowDefinition.entityTypeName, remoteTable: 'wf_definitions').entityType,
      'wf_definition',
    );
    expect(
      WorkflowSyncProcessor(remote: remote, entityTypeName: ApprovalRequest.entityTypeName, remoteTable: 'wf_approval_requests').entityType,
      'wf_approval_request',
    );
    expect(
      WorkflowSyncProcessor(remote: remote, entityTypeName: NotificationCenterItem.entityTypeName, remoteTable: 'wf_notifications').entityType,
      'wf_notification',
    );
  });
}
