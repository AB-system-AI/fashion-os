import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/approval.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/approval_template.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/notification.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/notification_queue.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/scheduler.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/workflow_execution.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/workflow_instance.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/workflow_template.dart';

abstract class TenantWorkflowDefinitionRepository implements BaseLocalRepository<TenantWorkflowDefinition> {
  Future<List<TenantWorkflowDefinition>> listActive(String tenantId);
}

abstract class TenantWorkflowInstanceRepository implements BaseLocalRepository<TenantWorkflowInstance> {
  Future<List<TenantWorkflowInstance>> listActive(String tenantId);
  Future<TenantWorkflowInstance?> getByEntity(String tenantId, String entityId);
}

abstract class ApprovalTemplateRepository implements BaseLocalRepository<ApprovalTemplate> {
  Future<List<ApprovalTemplate>> listActive(String tenantId, {String? entityType});
}

abstract class ApprovalMatrixRepository implements BaseLocalRepository<ApprovalMatrix> {
  Future<List<ApprovalMatrix>> listByTemplate(String tenantId, String templateId);
}

abstract class ApprovalRequestRepository implements BaseLocalRepository<ApprovalRequest> {
  Future<List<ApprovalRequest>> listPending(String tenantId, {String? assignedTo});
  Future<PaginatedResult<ApprovalRequest>> listByStatus(String tenantId, String status, {int page = 1, int pageSize = 50});
}

abstract class ApprovalHistoryRepository implements BaseLocalRepository<ApprovalHistory> {
  Future<List<ApprovalHistory>> listByRequest(String tenantId, String requestId);
}

abstract class ApprovalDelegationRepository implements BaseLocalRepository<ApprovalDelegation> {
  Future<List<ApprovalDelegation>> listActive(String tenantId, {String? fromUserId});
}

abstract class NotificationCenterRepository implements BaseLocalRepository<NotificationCenterItem> {
  Future<List<NotificationCenterItem>> listUnread(String tenantId, String recipientId);
  Future<int> countUnread(String tenantId, String recipientId);
}

abstract class ReminderRuleRepository implements BaseLocalRepository<ReminderRule> {
  Future<List<ReminderRule>> listActive(String tenantId);
}

abstract class EscalationRuleRepository implements BaseLocalRepository<EscalationRule> {
  Future<List<EscalationRule>> listActive(String tenantId, {String? entityType});
}

abstract class WorkflowTemplateRepository implements BaseLocalRepository<WorkflowTemplate> {
  Future<List<WorkflowTemplate>> listByTenant(String tenantId);
}

abstract class WorkflowVersionRepository implements BaseLocalRepository<WorkflowVersion> {
  Future<List<WorkflowVersion>> listByTemplate(String tenantId, String templateId);
  Future<WorkflowVersion?> getLatestPublished(String tenantId, String templateId);
}

abstract class WorkflowCategoryRepository implements BaseLocalRepository<WorkflowCategory> {
  Future<List<WorkflowCategory>> listByTenant(String tenantId);
}

abstract class WorkflowExecutionRepository implements BaseLocalRepository<WorkflowExecution> {
  Future<List<WorkflowExecution>> listByTemplate(String tenantId, String templateId);
  Future<List<WorkflowExecution>> listActive(String tenantId);
}

abstract class WorkflowStatisticsRepository implements BaseLocalRepository<WorkflowStatistics> {
  Future<List<WorkflowStatistics>> listByTenant(String tenantId, {String? templateId});
}

abstract class NotificationQueueRepository implements BaseLocalRepository<NotificationQueueItem> {
  Future<List<NotificationQueueItem>> listPending(String tenantId, {int limit = 50});
}

abstract class DeadLetterRepository implements BaseLocalRepository<DeadLetterItem> {
  Future<List<DeadLetterItem>> listByTenant(String tenantId);
}

abstract class NotificationPreferenceRepository implements BaseLocalRepository<NotificationPreference> {
  Future<NotificationPreference?> getByUser(String tenantId, String userId);
}

abstract class SchedulerJobRepository implements BaseLocalRepository<ScheduledJobRecord> {
  Future<List<ScheduledJobRecord>> listActive(String tenantId);
}

abstract class SchedulerExecutionLogRepository implements BaseLocalRepository<JobExecutionLog> {
  Future<List<JobExecutionLog>> listRecent(String tenantId, {int limit = 100});
}
