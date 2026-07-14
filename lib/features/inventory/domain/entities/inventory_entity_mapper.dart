import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

/// Shared helpers for inventory [SyncableEntity] mapping.
abstract final class InventoryEntityMapper {
  static Map<String, dynamic> basePayload({
    required String id,
    required String tenantId,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) =>
      {
        'id': id,
        'tenant_id': tenantId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
      };

  static LocalSyncStatus syncStatus(LocalRecord record) => record.syncStatus;
}
