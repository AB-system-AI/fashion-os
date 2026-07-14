import 'package:fashion_pos_enterprise/core/infrastructure/sync/entity_sync_processor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/remote_sync_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/remote_sync_record_mapper.dart';
import 'package:fashion_pos_enterprise/features/automation/data/datasources/automation_remote_datasource.dart';

class AutomationSyncProcessor extends EntitySyncProcessor {
  AutomationSyncProcessor({
    required AutomationRemoteDataSource remote,
    required String entityTypeName,
    required String remoteTable,
  })  : _remote = remote,
        _entityTypeName = entityTypeName,
        _remoteTable = remoteTable;

  final AutomationRemoteDataSource _remote;
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

typedef AutomationRuleSyncProcessor = AutomationSyncProcessor;
typedef AutomationWorkflowSyncProcessor = AutomationSyncProcessor;
typedef WorkflowStepSyncProcessor = AutomationSyncProcessor;
typedef ScheduledJobSyncProcessor = AutomationSyncProcessor;
typedef JobQueueItemSyncProcessor = AutomationSyncProcessor;
typedef AutomationExecutionSyncProcessor = AutomationSyncProcessor;
typedef AutomationLogSyncProcessor = AutomationSyncProcessor;
typedef ApprovalWorkflowSyncProcessor = AutomationSyncProcessor;
typedef ApprovalRequestSyncProcessor = AutomationSyncProcessor;
typedef DocumentTemplateSyncProcessor = AutomationSyncProcessor;
typedef AutomationSettingsSyncProcessor = AutomationSyncProcessor;
