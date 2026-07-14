import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/business/di/business_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/core/di/providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/workflow/data/datasources/workflow_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/workflow/data/repositories/workflow_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/workflow/data/sync/workflow_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/approval.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/approval_template.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/notification.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/notification_queue.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/scheduler.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/workflow_execution.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/workflow_instance.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/workflow_template.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/repositories/workflow_repositories.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/services/workflow_services.dart';

final workflowRemoteDataSourceProvider = Provider<WorkflowRemoteDataSource>((ref) => WorkflowRemoteDataSource());

final tenantWorkflowDefinitionRepositoryProvider = Provider<TenantWorkflowDefinitionRepository>((ref) {
  return TenantWorkflowDefinitionLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final tenantWorkflowInstanceRepositoryProvider = Provider<TenantWorkflowInstanceRepository>((ref) {
  return TenantWorkflowInstanceLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final approvalTemplateRepositoryProvider = Provider<ApprovalTemplateRepository>((ref) {
  return ApprovalTemplateLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final approvalMatrixRepositoryProvider = Provider<ApprovalMatrixRepository>((ref) {
  return ApprovalMatrixLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final wfApprovalRequestRepositoryProvider = Provider<ApprovalRequestRepository>((ref) {
  return ApprovalRequestLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final approvalHistoryRepositoryProvider = Provider<ApprovalHistoryRepository>((ref) {
  return ApprovalHistoryLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final approvalDelegationRepositoryProvider = Provider<ApprovalDelegationRepository>((ref) {
  return ApprovalDelegationLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final notificationCenterRepositoryProvider = Provider<NotificationCenterRepository>((ref) {
  return NotificationCenterLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final reminderRuleRepositoryProvider = Provider<ReminderRuleRepository>((ref) {
  return ReminderRuleLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final escalationRuleRepositoryProvider = Provider<EscalationRuleRepository>((ref) {
  return EscalationRuleLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final workflowTemplateRepositoryProvider = Provider<WorkflowTemplateRepository>((ref) {
  return WorkflowTemplateLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final workflowVersionRepositoryProvider = Provider<WorkflowVersionRepository>((ref) {
  return WorkflowVersionLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final workflowCategoryRepositoryProvider = Provider<WorkflowCategoryRepository>((ref) {
  return WorkflowCategoryLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final workflowExecutionRepositoryProvider = Provider<WorkflowExecutionRepository>((ref) {
  return WorkflowExecutionLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final workflowStatisticsRepositoryProvider = Provider<WorkflowStatisticsRepository>((ref) {
  return WorkflowStatisticsLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final notificationQueueRepositoryProvider = Provider<NotificationQueueRepository>((ref) {
  return NotificationQueueLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final deadLetterRepositoryProvider = Provider<DeadLetterRepository>((ref) {
  return DeadLetterLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final notificationPreferenceRepositoryProvider = Provider<NotificationPreferenceRepository>((ref) {
  return NotificationPreferenceLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final schedulerJobRepositoryProvider = Provider<SchedulerJobRepository>((ref) {
  return SchedulerJobLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final schedulerExecutionLogRepositoryProvider = Provider<SchedulerExecutionLogRepository>((ref) {
  return SchedulerExecutionLogLocalRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final workflowAdminServiceProvider = Provider<WorkflowAdminService>((ref) => WorkflowAdminService(
      definitions: ref.watch(tenantWorkflowDefinitionRepositoryProvider),
      instances: ref.watch(tenantWorkflowInstanceRepositoryProvider),
      approvals: ref.watch(wfApprovalRequestRepositoryProvider),
      workflowEngine: ref.watch(workflowEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final approvalServiceProvider = Provider<ApprovalService>((ref) => ApprovalService(
      templates: ref.watch(approvalTemplateRepositoryProvider),
      matrices: ref.watch(approvalMatrixRepositoryProvider),
      requests: ref.watch(wfApprovalRequestRepositoryProvider),
      history: ref.watch(approvalHistoryRepositoryProvider),
      delegations: ref.watch(approvalDelegationRepositoryProvider),
      approvalEngine: ref.watch(approvalEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final notificationCenterServiceProvider = Provider<NotificationCenterService>((ref) => NotificationCenterService(
      repository: ref.watch(notificationCenterRepositoryProvider),
      notificationEngine: ref.watch(notificationEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final reminderSchedulerServiceProvider = Provider<ReminderSchedulerService>((ref) => ReminderSchedulerService(
      rules: ref.watch(reminderRuleRepositoryProvider),
      requests: ref.watch(wfApprovalRequestRepositoryProvider),
      notificationCenter: ref.watch(notificationCenterServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final escalationServiceProvider = Provider<EscalationService>((ref) => EscalationService(
      rules: ref.watch(escalationRuleRepositoryProvider),
      requests: ref.watch(wfApprovalRequestRepositoryProvider),
      approvalEngine: ref.watch(approvalEngineProvider),
      notificationCenter: ref.watch(notificationCenterServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final workflowDesignerServiceProvider = Provider<WorkflowDesignerService>((ref) => WorkflowDesignerService(
      templates: ref.watch(workflowTemplateRepositoryProvider),
      versions: ref.watch(workflowVersionRepositoryProvider),
      designerEngine: ref.watch(workflowDesignerEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final approvalExtendedServiceProvider = Provider<ApprovalExtendedService>((ref) => ApprovalExtendedService(
      requests: ref.watch(wfApprovalRequestRepositoryProvider),
      history: ref.watch(approvalHistoryRepositoryProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final notificationDispatchServiceProvider = Provider<NotificationDispatchService>((ref) => NotificationDispatchService(
      queue: ref.watch(notificationQueueRepositoryProvider),
      deadLetter: ref.watch(deadLetterRepositoryProvider),
      preferences: ref.watch(notificationPreferenceRepositoryProvider),
      notificationEngine: ref.watch(notificationEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final schedulerServiceProvider = Provider<SchedulerService>((ref) => SchedulerService(
      jobs: ref.watch(schedulerJobRepositoryProvider),
      logs: ref.watch(schedulerExecutionLogRepositoryProvider),
      schedulerEngine: ref.watch(workflowSchedulerEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final workflowReportServiceProvider = Provider<WorkflowReportService>((ref) => WorkflowReportService(
      executions: ref.watch(workflowExecutionRepositoryProvider),
      statistics: ref.watch(workflowStatisticsRepositoryProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

WorkflowSyncProcessor _processor(Ref ref, String entityType, String table) => WorkflowSyncProcessor(
      remote: ref.watch(workflowRemoteDataSourceProvider),
      entityTypeName: entityType,
      remoteTable: table,
    );

final wfDefinitionSyncProcessorProvider = Provider<WfDefinitionSyncProcessor>(
  (ref) => _processor(ref, TenantWorkflowDefinition.entityTypeName, 'wf_definitions'),
);
final wfInstanceSyncProcessorProvider = Provider<WfInstanceSyncProcessor>(
  (ref) => _processor(ref, TenantWorkflowInstance.entityTypeName, 'wf_instances'),
);
final approvalTemplateSyncProcessorProvider = Provider<ApprovalTemplateSyncProcessor>(
  (ref) => _processor(ref, ApprovalTemplate.entityTypeName, 'wf_approval_templates'),
);
final approvalMatrixSyncProcessorProvider = Provider<ApprovalMatrixSyncProcessor>(
  (ref) => _processor(ref, ApprovalMatrix.entityTypeName, 'wf_approval_matrices'),
);
final wfApprovalRequestSyncProcessorProvider = Provider<WfApprovalRequestSyncProcessor>(
  (ref) => _processor(ref, ApprovalRequest.entityTypeName, 'wf_approval_requests'),
);
final wfApprovalHistorySyncProcessorProvider = Provider<WfApprovalHistorySyncProcessor>(
  (ref) => _processor(ref, ApprovalHistory.entityTypeName, 'wf_approval_history'),
);
final wfApprovalDelegationSyncProcessorProvider = Provider<WfApprovalDelegationSyncProcessor>(
  (ref) => _processor(ref, ApprovalDelegation.entityTypeName, 'wf_approval_delegations'),
);
final wfNotificationSyncProcessorProvider = Provider<WfNotificationSyncProcessor>(
  (ref) => _processor(ref, NotificationCenterItem.entityTypeName, 'wf_notifications'),
);
final reminderRuleSyncProcessorProvider = Provider<ReminderRuleSyncProcessor>(
  (ref) => _processor(ref, ReminderRule.entityTypeName, 'wf_reminder_rules'),
);
final escalationRuleSyncProcessorProvider = Provider<EscalationRuleSyncProcessor>(
  (ref) => _processor(ref, EscalationRule.entityTypeName, 'wf_escalation_rules'),
);
final wfTemplateSyncProcessorProvider = Provider<WfTemplateSyncProcessor>(
  (ref) => _processor(ref, WorkflowTemplate.entityTypeName, 'wf_templates'),
);
final wfTemplateVersionSyncProcessorProvider = Provider<WfTemplateVersionSyncProcessor>(
  (ref) => _processor(ref, WorkflowVersion.entityTypeName, 'wf_template_versions'),
);
final wfCategorySyncProcessorProvider = Provider<WfCategorySyncProcessor>(
  (ref) => _processor(ref, WorkflowCategory.entityTypeName, 'wf_categories'),
);
final wfExecutionSyncProcessorProvider = Provider<WfExecutionSyncProcessor>(
  (ref) => _processor(ref, WorkflowExecution.entityTypeName, 'wf_executions'),
);
final wfExecutionLogSyncProcessorProvider = Provider<WfExecutionLogSyncProcessor>(
  (ref) => _processor(ref, WorkflowExecutionLog.entityTypeName, 'wf_execution_logs'),
);
final wfStatisticsSyncProcessorProvider = Provider<WfStatisticsSyncProcessor>(
  (ref) => _processor(ref, WorkflowStatistics.entityTypeName, 'wf_statistics'),
);
final notificationQueueSyncProcessorProvider = Provider<NotificationQueueSyncProcessor>(
  (ref) => _processor(ref, NotificationQueueItem.entityTypeName, 'notification_queue'),
);
final notificationDeadLetterSyncProcessorProvider = Provider<NotificationDeadLetterSyncProcessor>(
  (ref) => _processor(ref, DeadLetterItem.entityTypeName, 'notification_dead_letter'),
);
final notificationPreferenceSyncProcessorProvider = Provider<NotificationPreferenceSyncProcessor>(
  (ref) => _processor(ref, NotificationPreference.entityTypeName, 'notification_preferences'),
);
final schedulerJobSyncProcessorProvider = Provider<SchedulerJobSyncProcessor>(
  (ref) => _processor(ref, ScheduledJobRecord.entityTypeName, 'scheduler_jobs'),
);
final schedulerExecutionLogSyncProcessorProvider = Provider<SchedulerExecutionLogSyncProcessor>(
  (ref) => _processor(ref, JobExecutionLog.entityTypeName, 'scheduler_execution_logs'),
);
