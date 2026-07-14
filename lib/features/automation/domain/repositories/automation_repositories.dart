import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/approval.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/automation_rule.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/execution.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/scheduled_job.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/settings.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/template.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/workflow.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';

abstract class AutomationRuleRepository implements BaseLocalRepository<AutomationRule> {
  Future<List<AutomationRule>> listActive(String tenantId);
  Future<List<AutomationRule>> listByTrigger(String tenantId, TriggerEventType trigger, {String? entityType});
}

abstract class AutomationWorkflowRepository implements BaseLocalRepository<AutomationWorkflow> {
  Future<List<AutomationWorkflow>> listActive(String tenantId);
  Future<List<WorkflowStep>> listSteps(String tenantId, String workflowId);
  Future<WorkflowStep> createStep(WorkflowStep step);
}

abstract class ScheduledJobRepository implements BaseLocalRepository<ScheduledJob> {
  Future<List<ScheduledJob>> listDue(String tenantId, DateTime before);
  Future<List<ScheduledJob>> listByStatus(String tenantId, JobStatus status);
}

abstract class JobQueueRepository implements BaseLocalRepository<JobQueueItem> {
  Future<List<JobQueueItem>> listPending(String tenantId, {int limit = 50});
}

abstract class AutomationExecutionRepository implements BaseLocalRepository<AutomationExecution> {
  Future<List<AutomationExecution>> listRecent(String tenantId, {int limit = 100});
}

abstract class AutomationLogRepository implements BaseLocalRepository<AutomationLog> {
  Future<List<AutomationLog>> listByExecution(String tenantId, String executionId);
}

abstract class ApprovalWorkflowRepository implements BaseLocalRepository<ApprovalWorkflow> {
  Future<List<ApprovalWorkflow>> listActive(String tenantId);
}

abstract class ApprovalRequestRepository implements BaseLocalRepository<ApprovalRequest> {
  Future<List<ApprovalRequest>> listPending(String tenantId);
  Future<List<ApprovalRequest>> listByEntity(String tenantId, String targetEntityType, String targetEntityId);
}

abstract class DocumentTemplateRepository implements BaseLocalRepository<DocumentTemplate> {
  Future<List<DocumentTemplate>> listActive(String tenantId);
}

abstract class AutomationSettingsRepository implements BaseLocalRepository<AutomationSettings> {
  Future<AutomationSettings?> getSettings(String tenantId);
  Future<AutomationSettings> saveSettings(AutomationSettings settings);
}
