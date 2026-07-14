import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/business/di/business_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/automation/data/datasources/automation_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/automation/data/repositories/automation_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/automation/data/sync/automation_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/approval.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/automation_rule.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/execution.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/scheduled_job.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/settings.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/template.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/workflow.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/repositories/automation_repositories.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/services/ai/forecast_service.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/services/ai/insights_service.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/services/ai/prompt_service.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/services/ai/recommendation_service.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/services/ai/natural_language_query_service.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/services/ai/ai_provider.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/services/automation_services.dart';

final automationRemoteDataSourceProvider = Provider<AutomationRemoteDataSource>((ref) => AutomationRemoteDataSource());

final automationRuleRepositoryProvider = Provider<AutomationRuleRepository>((ref) {
  return AutomationRuleLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final automationWorkflowRepositoryProvider = Provider<AutomationWorkflowRepository>((ref) {
  return AutomationWorkflowLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final scheduledJobRepositoryProvider = Provider<ScheduledJobRepository>((ref) {
  return ScheduledJobLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final jobQueueRepositoryProvider = Provider<JobQueueRepository>((ref) {
  return JobQueueLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final automationExecutionRepositoryProvider = Provider<AutomationExecutionRepository>((ref) {
  return AutomationExecutionLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final automationLogRepositoryProvider = Provider<AutomationLogRepository>((ref) {
  return AutomationLogLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final approvalWorkflowRepositoryProvider = Provider<ApprovalWorkflowRepository>((ref) {
  return ApprovalWorkflowLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final approvalRequestRepositoryProvider = Provider<ApprovalRequestRepository>((ref) {
  return ApprovalRequestLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final documentTemplateRepositoryProvider = Provider<DocumentTemplateRepository>((ref) {
  return DocumentTemplateLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final automationSettingsRepositoryProvider = Provider<AutomationSettingsRepository>((ref) {
  return AutomationSettingsLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final aiProviderProvider = Provider<AIProvider>((ref) => NoOpAIProvider());
final promptServiceProvider = Provider<PromptService>((ref) => DefaultPromptService(provider: ref.watch(aiProviderProvider)));
final recommendationServiceProvider = Provider<RecommendationService>((ref) => DefaultRecommendationService());
final forecastServiceProvider = Provider<ForecastService>((ref) => DefaultForecastService());
final insightsServiceProvider = Provider<InsightsService>((ref) => DefaultInsightsService());
final naturalLanguageQueryServiceProvider = Provider<NaturalLanguageQueryService>((ref) => DefaultNaturalLanguageQueryService());

final ruleAutomationServiceProvider = Provider<RuleAutomationService>((ref) => RuleAutomationService(
      repository: ref.watch(automationRuleRepositoryProvider),
      engine: ref.watch(automationEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final workflowAutomationServiceProvider = Provider<WorkflowAutomationService>((ref) => WorkflowAutomationService(
      repository: ref.watch(automationWorkflowRepositoryProvider),
      engine: ref.watch(automationEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final schedulerServiceProvider = Provider<SchedulerService>((ref) => SchedulerService(
      jobs: ref.watch(scheduledJobRepositoryProvider),
      queue: ref.watch(jobQueueRepositoryProvider),
      scheduler: ref.watch(schedulerEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final approvalServiceProvider = Provider<ApprovalService>((ref) => ApprovalService(
      workflows: ref.watch(approvalWorkflowRepositoryProvider),
      requests: ref.watch(approvalRequestRepositoryProvider),
      engine: ref.watch(automationEngineProvider),
      settings: ref.watch(automationSettingsRepositoryProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final templateServiceProvider = Provider<TemplateService>((ref) => TemplateService(
      repository: ref.watch(documentTemplateRepositoryProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final notificationAutomationServiceProvider = Provider<NotificationAutomationService>((ref) => NotificationAutomationService(
      notificationEngine: ref.watch(notificationEngineProvider),
      templates: ref.watch(templateServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final smartSuggestionServiceProvider = Provider<SmartSuggestionService>((ref) => SmartSuggestionService(
      rules: ref.watch(automationRuleRepositoryProvider),
      workflows: ref.watch(automationWorkflowRepositoryProvider),
      executions: ref.watch(automationExecutionRepositoryProvider),
      jobs: ref.watch(scheduledJobRepositoryProvider),
      engine: ref.watch(automationEngineProvider),
      recommendations: ref.watch(recommendationServiceProvider),
      insights: ref.watch(insightsServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final automationServiceProvider = Provider<AutomationService>((ref) => AutomationService(
      rules: ref.watch(automationRuleRepositoryProvider),
      workflows: ref.watch(automationWorkflowRepositoryProvider),
      executions: ref.watch(automationExecutionRepositoryProvider),
      jobs: ref.watch(scheduledJobRepositoryProvider),
      queue: ref.watch(jobQueueRepositoryProvider),
      settings: ref.watch(automationSettingsRepositoryProvider),
      engine: ref.watch(automationEngineProvider),
      scheduler: ref.watch(schedulerEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

AutomationSyncProcessor _processor(Ref ref, String entityType, String table) => AutomationSyncProcessor(
      remote: ref.watch(automationRemoteDataSourceProvider),
      entityTypeName: entityType,
      remoteTable: table,
    );

final automationRuleSyncProcessorProvider = Provider<AutomationRuleSyncProcessor>((ref) => _processor(ref, AutomationRule.entityTypeName, 'automation_rules'));
final automationWorkflowSyncProcessorProvider = Provider<AutomationWorkflowSyncProcessor>((ref) => _processor(ref, AutomationWorkflow.entityTypeName, 'automation_workflows'));
final workflowStepSyncProcessorProvider = Provider<WorkflowStepSyncProcessor>((ref) => _processor(ref, WorkflowStep.entityTypeName, 'workflow_steps'));
final scheduledJobSyncProcessorProvider = Provider<ScheduledJobSyncProcessor>((ref) => _processor(ref, ScheduledJob.entityTypeName, 'scheduled_jobs'));
final jobQueueItemSyncProcessorProvider = Provider<JobQueueItemSyncProcessor>((ref) => _processor(ref, JobQueueItem.entityTypeName, 'job_queue'));
final automationExecutionSyncProcessorProvider = Provider<AutomationExecutionSyncProcessor>((ref) => _processor(ref, AutomationExecution.entityTypeName, 'automation_executions'));
final automationLogSyncProcessorProvider = Provider<AutomationLogSyncProcessor>((ref) => _processor(ref, AutomationLog.entityTypeName, 'automation_logs'));
final approvalWorkflowSyncProcessorProvider = Provider<ApprovalWorkflowSyncProcessor>((ref) => _processor(ref, ApprovalWorkflow.entityTypeName, 'approval_workflows'));
final approvalRequestSyncProcessorProvider = Provider<ApprovalRequestSyncProcessor>((ref) => _processor(ref, ApprovalRequest.entityTypeName, 'approval_requests'));
final documentTemplateSyncProcessorProvider = Provider<DocumentTemplateSyncProcessor>((ref) => _processor(ref, DocumentTemplate.entityTypeName, 'document_templates'));
final automationSettingsSyncProcessorProvider = Provider<AutomationSettingsSyncProcessor>((ref) => _processor(ref, AutomationSettings.entityTypeName, 'automation_settings'));
