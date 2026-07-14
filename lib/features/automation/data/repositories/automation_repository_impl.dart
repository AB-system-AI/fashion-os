import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/approval.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/automation_rule.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/execution.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/scheduled_job.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/settings.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/template.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/workflow.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/repositories/automation_repositories.dart';

typedef AutomationEntityMapper<T> = T Function(Map<String, dynamic> json, LocalRecord record);

class AutomationRepositoryImpl<T extends SyncableEntity> extends BaseLocalRepository<T> {
  AutomationRepositoryImpl({
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

  final AutomationEntityMapper<T> fromPayload;
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

  AutomationRepositoryImpl<R> child<R extends SyncableEntity>({
    required String entityType,
    required AutomationEntityMapper<R> fromPayload,
    required ({String? name, String? sku, String? barcode, String? storeId}) Function(R) toSearch,
  }) =>
      AutomationRepositoryImpl<R>(
        database: _database,
        syncQueue: _syncQueue,
        entityType: entityType,
        fromPayload: fromPayload,
        toSearchFields: toSearch,
      );
}

class AutomationRuleLocalRepository extends AutomationRepositoryImpl<AutomationRule> implements AutomationRuleRepository {
  AutomationRuleLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: AutomationRule.entityTypeName,
          fromPayload: AutomationRule.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.triggerEntityType, barcode: null, storeId: null),
        );

  @override
  Future<List<AutomationRule>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((r) => r.isActive).toList();
  }

  @override
  Future<List<AutomationRule>> listByTrigger(String tenantId, TriggerEventType trigger, {String? entityType}) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((r) {
      if (!r.isActive) return false;
      if (r.triggerEvent != trigger) return false;
      if (entityType != null && r.triggerEntityType != null && r.triggerEntityType != entityType) return false;
      return true;
    }).toList();
  }
}

class AutomationWorkflowLocalRepository extends AutomationRepositoryImpl<AutomationWorkflow> implements AutomationWorkflowRepository {
  AutomationWorkflowLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: AutomationWorkflow.entityTypeName,
          fromPayload: AutomationWorkflow.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.triggerEntityType, barcode: null, storeId: null),
        );

  @override
  Future<List<AutomationWorkflow>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((w) => w.isActive).toList();
  }

  @override
  Future<List<WorkflowStep>> listSteps(String tenantId, String workflowId) async {
    final records = await _database.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: WorkflowStep.entityTypeName, pageSize: 500),
    );
    return records.map((r) => WorkflowStep.fromPayload(r.payload, r)).where((s) => s.workflowId == workflowId).toList()
      ..sort((a, b) => a.stepOrder.compareTo(b.stepOrder));
  }

  @override
  Future<WorkflowStep> createStep(WorkflowStep step) =>
      child(entityType: WorkflowStep.entityTypeName, fromPayload: WorkflowStep.fromPayload, toSearch: (e) => (name: e.name, sku: e.workflowId, barcode: null, storeId: null)).create(step);
}

class ScheduledJobLocalRepository extends AutomationRepositoryImpl<ScheduledJob> implements ScheduledJobRepository {
  ScheduledJobLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ScheduledJob.entityTypeName,
          fromPayload: ScheduledJob.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.ruleId, barcode: e.workflowId, storeId: null),
        );

  @override
  Future<List<ScheduledJob>> listDue(String tenantId, DateTime before) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((j) => j.nextRunAt != null && !j.nextRunAt!.isAfter(before) && j.status != JobStatus.cancelled).toList();
  }

  @override
  Future<List<ScheduledJob>> listByStatus(String tenantId, JobStatus status) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((j) => j.status == status).toList();
  }
}

class JobQueueLocalRepository extends AutomationRepositoryImpl<JobQueueItem> implements JobQueueRepository {
  JobQueueLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: JobQueueItem.entityTypeName,
          fromPayload: JobQueueItem.fromPayload,
          toSearchFields: (e) => (name: e.scheduledJobId, sku: e.status.value, barcode: null, storeId: null),
        );

  @override
  Future<List<JobQueueItem>> listPending(String tenantId, {int limit = 50}) async {
    final records = await _database.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: JobQueueItem.entityTypeName, pageSize: limit),
    );
    return records
        .map((r) => JobQueueItem.fromPayload(r.payload, r))
        .where((q) => q.status == JobStatus.pending || q.status == JobStatus.queued)
        .toList();
  }
}

class AutomationExecutionLocalRepository extends AutomationRepositoryImpl<AutomationExecution> implements AutomationExecutionRepository {
  AutomationExecutionLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: AutomationExecution.entityTypeName,
          fromPayload: AutomationExecution.fromPayload,
          toSearchFields: (e) => (name: e.targetEntityType, sku: e.targetEntityId, barcode: e.status.value, storeId: null),
        );

  @override
  Future<List<AutomationExecution>> listRecent(String tenantId, {int limit = 100}) async {
    final records = await _database.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: AutomationExecution.entityTypeName, pageSize: limit, sortBy: 'updated_at'),
    );
    return records.map(mapFromLocalRecord).toList();
  }
}

class AutomationLogLocalRepository extends AutomationRepositoryImpl<AutomationLog> implements AutomationLogRepository {
  AutomationLogLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: AutomationLog.entityTypeName,
          fromPayload: AutomationLog.fromPayload,
          toSearchFields: (e) => (name: e.message, sku: e.executionId, barcode: e.level.value, storeId: null),
        );

  @override
  Future<List<AutomationLog>> listByExecution(String tenantId, String executionId) async {
    final records = await _database.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: AutomationLog.entityTypeName, pageSize: 500),
    );
    return records.map((r) => AutomationLog.fromPayload(r.payload, r)).where((l) => l.executionId == executionId).toList();
  }
}

class ApprovalWorkflowLocalRepository extends AutomationRepositoryImpl<ApprovalWorkflow> implements ApprovalWorkflowRepository {
  ApprovalWorkflowLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ApprovalWorkflow.entityTypeName,
          fromPayload: ApprovalWorkflow.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.targetEntityType, barcode: null, storeId: null),
        );

  @override
  Future<List<ApprovalWorkflow>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
    return page.items.where((w) => w.isActive).toList();
  }
}

class ApprovalRequestLocalRepository extends AutomationRepositoryImpl<ApprovalRequest> implements ApprovalRequestRepository {
  ApprovalRequestLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ApprovalRequest.entityTypeName,
          fromPayload: ApprovalRequest.fromPayload,
          toSearchFields: (e) => (name: e.targetEntityType, sku: e.targetEntityId, barcode: e.status.value, storeId: null),
        );

  @override
  Future<List<ApprovalRequest>> listPending(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
    return page.items.where((r) => r.status == ApprovalStatus.pending).toList();
  }

  @override
  Future<List<ApprovalRequest>> listByEntity(String tenantId, String targetEntityType, String targetEntityId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
    return page.items.where((r) => r.targetEntityType == targetEntityType && r.targetEntityId == targetEntityId).toList();
  }
}

class DocumentTemplateLocalRepository extends AutomationRepositoryImpl<DocumentTemplate> implements DocumentTemplateRepository {
  DocumentTemplateLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: DocumentTemplate.entityTypeName,
          fromPayload: DocumentTemplate.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.templateType.value, barcode: null, storeId: null),
        );

  @override
  Future<List<DocumentTemplate>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 200));
    return page.items.where((t) => t.isActive).toList();
  }
}

class AutomationSettingsLocalRepository extends AutomationRepositoryImpl<AutomationSettings> implements AutomationSettingsRepository {
  AutomationSettingsLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: AutomationSettings.entityTypeName,
          fromPayload: AutomationSettings.fromPayload,
          toSearchFields: (e) => (name: e.tenantId, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<AutomationSettings?> getSettings(String tenantId) async {
    final records = await _database.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: AutomationSettings.entityTypeName, pageSize: 1),
    );
    return records.isEmpty ? null : mapFromLocalRecord(records.first);
  }

  @override
  Future<AutomationSettings> saveSettings(AutomationSettings settings) => create(settings);
}
