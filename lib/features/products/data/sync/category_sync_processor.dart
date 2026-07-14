import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/entity_sync_processor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/remote_sync_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/remote_sync_record_mapper.dart';
import 'package:fashion_pos_enterprise/features/products/data/datasources/category_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/category.dart';

class CategorySyncProcessor extends EntitySyncProcessor {
  CategorySyncProcessor(this._remote, {AuditService? auditService}) : _audit = auditService;

  final CategoryRemoteDataSource _remote;
  final AuditService? _audit;

  @override
  String get entityType => Category.entityTypeName;

  @override
  Future<SyncProcessResult> push(Map<String, dynamic> queueItem) async {
    try {
      final operation = SyncOperation.fromValue(queueItem['operation'] as String? ?? 'update');
      final payload = Map<String, dynamic>.from(queueItem['payload'] as Map? ?? {});
      final tenantId = queueItem['tenant_id'] as String? ?? payload['tenant_id'] as String? ?? '';
      final entityId = queueItem['entity_id'] as String? ?? payload['id'] as String? ?? '';
      await _remote.push(operation: operation, payload: payload, tenantId: tenantId);
      await _audit?.log(
        action: AuditAction.sync,
        entityType: Category.entityTypeName,
        tenantId: tenantId,
        entityId: entityId,
        metadata: {'change_type': 'category_sync', 'operation': operation.value},
      );
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
    final rows = await _remote.pullDelta(tenantId: tenantId, since: since);
    final records = rows.map((r) => RemoteSyncRecordMapper.fromMap(r, entityType)).toList();
    return _buildPullResult(records, sinceVersion);
  }

  PullDeltaResult _buildPullResult(List<RemoteSyncRecord> records, int sinceVersion) {
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
