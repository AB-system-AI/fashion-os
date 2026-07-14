import 'package:fashion_pos_enterprise/core/infrastructure/sync/remote_sync_record.dart';

/// Maps remote API rows to [RemoteSyncRecord].
abstract final class RemoteSyncRecordMapper {
  static RemoteSyncRecord fromMap(Map<String, dynamic> row, String entityType) {
    final updatedAt = _parseDate(row['updated_at'] ?? row['updatedAt']) ?? DateTime.now().toUtc();
    final deletedAt = _parseDate(row['deleted_at'] ?? row['deletedAt']);
    return RemoteSyncRecord(
      id: row['id'] as String,
      tenantId: row['tenant_id'] as String? ?? row['tenantId'] as String? ?? '',
      entityType: entityType,
      payload: Map<String, dynamic>.from(row),
      version: (row['version'] as num?)?.toInt() ?? 1,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      searchName: row['name'] as String?,
      searchSku: row['sku'] as String?,
      searchBarcode: row['barcode'] as String?,
      storeId: row['store_id'] as String? ?? row['storeId'] as String?,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toUtc();
    return DateTime.tryParse(value.toString())?.toUtc();
  }
}
