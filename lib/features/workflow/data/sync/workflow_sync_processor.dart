import 'package:fashion_pos_enterprise/core/infrastructure/sync/entity_sync_processor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/remote_sync_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/remote_sync_record_mapper.dart';
import 'package:fashion_pos_enterprise/features/workflow/data/datasources/workflow_remote_datasource.dart';

class WorkflowSyncProcessor extends EntitySyncProcessor {
  WorkflowSyncProcessor({
    required WorkflowRemoteDataSource remote,
    required String entityTypeName,
    required String remoteTable,
  })  : _remote = remote,
        _entityTypeName = entityTypeName,
        _remoteTable = remoteTable;

  final WorkflowRemoteDataSource _remote;
  final String _entityTypeName;
  final String _remoteTable;

  @override
  String get entityType => _entityTypeName;

  @override
  Future<SyncProcessResult> push(Map<String, dynamic> queueItem) async {
    try {
      final operation = SyncOperation.fromValue(queueItem['operation'] as String? ?? 'update');
      final payload = Map<String, dynamic>.from(queueItem['payload'] as Map? ?? {});
      await _remote.push(table: _remoteTable, operation: operation, payload: payload);
      return const SyncProcessResult(success: true);
    } catch (e) {
      return SyncProcessResult(success: false, errorMessage: e.toString());
    }
  }

  @override
  Future<PullDeltaResult> pullDelta({
    required String tenantId,
    required String deviceId,
    required DateTime since,
    required int sinceVersion,
  }) async {
    final rows = await _remote.pullDelta(table: _remoteTable, tenantId: tenantId, since: since);
    final records = rows.map((r) => RemoteSyncRecordMapper.fromMap(r, entityType)).toList();
    if (records.isEmpty) return const PullDeltaResult();
    var maxVersion = sinceVersion;
    DateTime? maxUpdated;
    for (final r in records) {
      if (r.version > maxVersion) maxVersion = r.version;
      if (maxUpdated == null || r.updatedAt.isAfter(maxUpdated)) maxUpdated = r.updatedAt;
    }
    return PullDeltaResult(records: records, maxUpdatedAt: maxUpdated, maxVersion: maxVersion);
  }
}

typedef WfDefinitionSyncProcessor = WorkflowSyncProcessor;
typedef WfInstanceSyncProcessor = WorkflowSyncProcessor;
typedef ApprovalTemplateSyncProcessor = WorkflowSyncProcessor;
typedef ApprovalMatrixSyncProcessor = WorkflowSyncProcessor;
typedef WfApprovalRequestSyncProcessor = WorkflowSyncProcessor;
typedef WfApprovalHistorySyncProcessor = WorkflowSyncProcessor;
typedef WfApprovalDelegationSyncProcessor = WorkflowSyncProcessor;
typedef WfNotificationSyncProcessor = WorkflowSyncProcessor;
typedef ReminderRuleSyncProcessor = WorkflowSyncProcessor;
typedef EscalationRuleSyncProcessor = WorkflowSyncProcessor;
typedef WfTemplateSyncProcessor = WorkflowSyncProcessor;
typedef WfTemplateVersionSyncProcessor = WorkflowSyncProcessor;
typedef WfCategorySyncProcessor = WorkflowSyncProcessor;
typedef WfExecutionSyncProcessor = WorkflowSyncProcessor;
typedef WfExecutionLogSyncProcessor = WorkflowSyncProcessor;
typedef WfStatisticsSyncProcessor = WorkflowSyncProcessor;
typedef NotificationQueueSyncProcessor = WorkflowSyncProcessor;
typedef NotificationDeadLetterSyncProcessor = WorkflowSyncProcessor;
typedef NotificationPreferenceSyncProcessor = WorkflowSyncProcessor;
typedef SchedulerJobSyncProcessor = WorkflowSyncProcessor;
typedef SchedulerExecutionLogSyncProcessor = WorkflowSyncProcessor;
