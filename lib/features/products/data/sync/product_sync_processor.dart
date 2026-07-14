import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/entity_sync_processor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/remote_sync_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/remote_sync_record_mapper.dart';
import 'package:fashion_pos_enterprise/features/products/data/datasources/product_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';

/// Pushes product mutations to Supabase when online.
class ProductSyncProcessor extends EntitySyncProcessor {
  ProductSyncProcessor(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  String get entityType => Product.entityTypeName;

  @override
  Future<SyncProcessResult> push(Map<String, dynamic> queueItem) async {
    try {
      final operation = SyncOperation.fromValue(queueItem['operation'] as String? ?? 'update');
      final payload = Map<String, dynamic>.from(queueItem['payload'] as Map? ?? {});
      await _remote.push(operation: operation, payload: payload);
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
