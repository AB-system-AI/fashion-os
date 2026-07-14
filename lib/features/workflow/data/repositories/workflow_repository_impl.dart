import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/approval.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/approval_template.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/notification.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/notification_queue.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/scheduler.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/workflow_execution.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/workflow_instance.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/workflow_template.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/enums/workflow_enums.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/repositories/workflow_repositories.dart';

typedef WorkflowEntityMapper<T> = T Function(Map<String, dynamic> json, LocalRecord record);

class WorkflowRepositoryImpl<T extends SyncableEntity> extends BaseLocalRepository<T> {
  WorkflowRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
    required String entityType,
    required this.fromPayload,
    required this.toSearchFields,
  })  : _database = database,
        _syncQueue = syncQueue,
        super(database: database, entityType: entityType, syncQueue: syncQueue);

  final AppDatabase _database;
  final SyncQueueWriter _syncQueue;
  final WorkflowEntityMapper<T> fromPayload;
  final ({String? name, String? sku, String? barcode, String? storeId}) Function(T entity) toSearchFields;

  @override
  T mapFromLocalRecord(LocalRecord record) => fromPayload(record.payload, record);

  @override
  LocalRecord mapToLocalRecord(T entity) {
    final search = toSearchFields(entity);
    return LocalRecord(
      id: entity.id,
      tenantId: entity.tenantId,
      entityType: entity.entityType,
      storeId: search.storeId,
      payload: entity.toPayload(),
      version: entity.version,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      syncStatus: entity.syncStatus,
      isDirty: entity.isDirty,
      searchName: search.name,
      searchSku: search.sku,
      searchBarcode: search.barcode,
    );
  }
}

class TenantWorkflowDefinitionLocalRepository extends WorkflowRepositoryImpl<TenantWorkflowDefinition>
    implements TenantWorkflowDefinitionRepository {
  TenantWorkflowDefinitionLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: TenantWorkflowDefinition.entityTypeName,
          fromPayload: TenantWorkflowDefinition.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<TenantWorkflowDefinition>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((d) => d.isActive).toList();
  }
}

class TenantWorkflowInstanceLocalRepository extends WorkflowRepositoryImpl<TenantWorkflowInstance>
    implements TenantWorkflowInstanceRepository {
  TenantWorkflowInstanceLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: TenantWorkflowInstance.entityTypeName,
          fromPayload: TenantWorkflowInstance.fromPayload,
          toSearchFields: (e) => (name: e.entityId, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<TenantWorkflowInstance>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((i) => i.isActive).toList();
  }

  @override
  Future<TenantWorkflowInstance?> getByEntity(String tenantId, String entityId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    for (final i in page.items) {
      if (i.entityId == entityId) return i;
    }
    return null;
  }
}

class ApprovalTemplateLocalRepository extends WorkflowRepositoryImpl<ApprovalTemplate>
    implements ApprovalTemplateRepository {
  ApprovalTemplateLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ApprovalTemplate.entityTypeName,
          fromPayload: ApprovalTemplate.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<ApprovalTemplate>> listActive(String tenantId, {String? entityType}) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((t) => t.isActive && (entityType == null || t.entityType == entityType)).toList();
  }
}

class ApprovalMatrixLocalRepository extends WorkflowRepositoryImpl<ApprovalMatrix>
    implements ApprovalMatrixRepository {
  ApprovalMatrixLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ApprovalMatrix.entityTypeName,
          fromPayload: ApprovalMatrix.fromPayload,
          toSearchFields: (e) => (name: e.requiredRole, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<ApprovalMatrix>> listByTemplate(String tenantId, String templateId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((m) => m.templateId == templateId).toList()..sort((a, b) => a.stepOrder.compareTo(b.stepOrder));
  }
}

class ApprovalRequestLocalRepository extends WorkflowRepositoryImpl<ApprovalRequest>
    implements ApprovalRequestRepository {
  ApprovalRequestLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ApprovalRequest.entityTypeName,
          fromPayload: ApprovalRequest.fromPayload,
          toSearchFields: (e) => (name: e.targetEntityType, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<ApprovalRequest>> listPending(String tenantId, {String? assignedTo}) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items
        .where((r) => r.isPending && (assignedTo == null || r.assignedTo == assignedTo))
        .toList();
  }

  @override
  Future<PaginatedResult<ApprovalRequest>> listByStatus(String tenantId, String status, {int page = 1, int pageSize = 50}) async {
    final all = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    final filtered = all.items.where((r) => r.status.value == status).toList();
    final start = (page - 1) * pageSize;
    final slice = filtered.skip(start).take(pageSize).toList();
    return PaginatedResult(
      items: slice,
      page: page,
      pageSize: pageSize,
      totalCount: filtered.length,
    );
  }
}

class ApprovalHistoryLocalRepository extends WorkflowRepositoryImpl<ApprovalHistory>
    implements ApprovalHistoryRepository {
  ApprovalHistoryLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ApprovalHistory.entityTypeName,
          fromPayload: ApprovalHistory.fromPayload,
          toSearchFields: (e) => (name: e.decision, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<ApprovalHistory>> listByRequest(String tenantId, String requestId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((h) => h.requestId == requestId).toList()
      ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
  }
}

class ApprovalDelegationLocalRepository extends WorkflowRepositoryImpl<ApprovalDelegation>
    implements ApprovalDelegationRepository {
  ApprovalDelegationLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ApprovalDelegation.entityTypeName,
          fromPayload: ApprovalDelegation.fromPayload,
          toSearchFields: (e) => (name: e.fromUserId, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<ApprovalDelegation>> listActive(String tenantId, {String? fromUserId}) async {
    final now = DateTime.now().toUtc();
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items
        .where((d) => d.isEffectiveAt(now) && (fromUserId == null || d.fromUserId == fromUserId))
        .toList();
  }
}

class NotificationCenterLocalRepository extends WorkflowRepositoryImpl<NotificationCenterItem>
    implements NotificationCenterRepository {
  NotificationCenterLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: NotificationCenterItem.entityTypeName,
          fromPayload: NotificationCenterItem.fromPayload,
          toSearchFields: (e) => (name: e.title, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<NotificationCenterItem>> listUnread(String tenantId, String recipientId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items
        .where((n) => n.recipientId == recipientId && n.status == NotificationItemStatus.unread)
        .toList();
  }

  @override
  Future<int> countUnread(String tenantId, String recipientId) async {
    final items = await listUnread(tenantId, recipientId);
    return items.length;
  }
}

class ReminderRuleLocalRepository extends WorkflowRepositoryImpl<ReminderRule> implements ReminderRuleRepository {
  ReminderRuleLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ReminderRule.entityTypeName,
          fromPayload: ReminderRule.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<ReminderRule>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((r) => r.isActive).toList();
  }
}

class EscalationRuleLocalRepository extends WorkflowRepositoryImpl<EscalationRule>
    implements EscalationRuleRepository {
  EscalationRuleLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: EscalationRule.entityTypeName,
          fromPayload: EscalationRule.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<EscalationRule>> listActive(String tenantId, {String? entityType}) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items
        .where((r) => r.isActive && (entityType == null || r.targetEntityType == entityType))
        .toList();
  }
}

class WorkflowTemplateLocalRepository extends WorkflowRepositoryImpl<WorkflowTemplate>
    implements WorkflowTemplateRepository {
  WorkflowTemplateLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: WorkflowTemplate.entityTypeName,
          fromPayload: WorkflowTemplate.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<WorkflowTemplate>> listByTenant(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items;
  }
}

class WorkflowVersionLocalRepository extends WorkflowRepositoryImpl<WorkflowVersion>
    implements WorkflowVersionRepository {
  WorkflowVersionLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: WorkflowVersion.entityTypeName,
          fromPayload: WorkflowVersion.fromPayload,
          toSearchFields: (e) => (name: '${e.templateId}-v${e.versionNumber}', sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<WorkflowVersion>> listByTemplate(String tenantId, String templateId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((v) => v.templateId == templateId).toList()
      ..sort((a, b) => b.versionNumber.compareTo(a.versionNumber));
  }

  @override
  Future<WorkflowVersion?> getLatestPublished(String tenantId, String templateId) async {
    final versions = await listByTemplate(tenantId, templateId);
    for (final v in versions) {
      if (v.status == WorkflowVersionStatus.published) return v;
    }
    return null;
  }
}

class WorkflowCategoryLocalRepository extends WorkflowRepositoryImpl<WorkflowCategory>
    implements WorkflowCategoryRepository {
  WorkflowCategoryLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: WorkflowCategory.entityTypeName,
          fromPayload: WorkflowCategory.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<WorkflowCategory>> listByTenant(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items;
  }
}

class WorkflowExecutionLocalRepository extends WorkflowRepositoryImpl<WorkflowExecution>
    implements WorkflowExecutionRepository {
  WorkflowExecutionLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: WorkflowExecution.entityTypeName,
          fromPayload: WorkflowExecution.fromPayload,
          toSearchFields: (e) => (name: e.templateId, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<WorkflowExecution>> listByTemplate(String tenantId, String templateId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((e) => e.templateId == templateId).toList();
  }

  @override
  Future<List<WorkflowExecution>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((e) => e.isActive).toList();
  }
}

class WorkflowStatisticsLocalRepository extends WorkflowRepositoryImpl<WorkflowStatistics>
    implements WorkflowStatisticsRepository {
  WorkflowStatisticsLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: WorkflowStatistics.entityTypeName,
          fromPayload: WorkflowStatistics.fromPayload,
          toSearchFields: (e) => (name: e.templateId, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<WorkflowStatistics>> listByTenant(String tenantId, {String? templateId}) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((s) => templateId == null || s.templateId == templateId).toList();
  }
}

class NotificationQueueLocalRepository extends WorkflowRepositoryImpl<NotificationQueueItem>
    implements NotificationQueueRepository {
  NotificationQueueLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: NotificationQueueItem.entityTypeName,
          fromPayload: NotificationQueueItem.fromPayload,
          toSearchFields: (e) => (name: e.title, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<NotificationQueueItem>> listPending(String tenantId, {int limit = 50}) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items
        .where((i) => i.status == NotificationQueueStatus.pending || i.status == NotificationQueueStatus.failed)
        .take(limit)
        .toList();
  }
}

class DeadLetterLocalRepository extends WorkflowRepositoryImpl<DeadLetterItem> implements DeadLetterRepository {
  DeadLetterLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: DeadLetterItem.entityTypeName,
          fromPayload: DeadLetterItem.fromPayload,
          toSearchFields: (e) => (name: e.originalQueueId, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<DeadLetterItem>> listByTenant(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items;
  }
}

class NotificationPreferenceLocalRepository extends WorkflowRepositoryImpl<NotificationPreference>
    implements NotificationPreferenceRepository {
  NotificationPreferenceLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: NotificationPreference.entityTypeName,
          fromPayload: NotificationPreference.fromPayload,
          toSearchFields: (e) => (name: e.userId, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<NotificationPreference?> getByUser(String tenantId, String userId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    for (final p in page.items) {
      if (p.userId == userId) return p;
    }
    return null;
  }
}

class SchedulerJobLocalRepository extends WorkflowRepositoryImpl<ScheduledJobRecord>
    implements SchedulerJobRepository {
  SchedulerJobLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ScheduledJobRecord.entityTypeName,
          fromPayload: ScheduledJobRecord.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<ScheduledJobRecord>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items
        .where((j) => j.status != JobStatus.cancelled && j.status != JobStatus.completed)
        .toList();
  }
}

class SchedulerExecutionLogLocalRepository extends WorkflowRepositoryImpl<JobExecutionLog>
    implements SchedulerExecutionLogRepository {
  SchedulerExecutionLogLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: JobExecutionLog.entityTypeName,
          fromPayload: JobExecutionLog.fromPayload,
          toSearchFields: (e) => (name: e.jobId, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<List<JobExecutionLog>> listRecent(String tenantId, {int limit = 100}) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    final sorted = page.items.toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sorted.take(limit).toList();
  }
}
