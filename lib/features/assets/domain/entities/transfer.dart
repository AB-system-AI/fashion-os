import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/enums/assets_enums.dart';

class AssetTransfer extends Equatable implements SyncableEntity {
  const AssetTransfer({
    required this.id,
    required this.tenantId,
    required this.assetId,
    required this.toLocationId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.fromLocationId,
    this.status = TransferStatus.pending,
    this.notes,
    this.transferredAt,
    this.transferredBy,
    this.deletedAt,
  });

  static const entityTypeName = 'asset_transfer';

  @override
  final String id;
  @override
  final String tenantId;
  final String assetId;
  final String? fromLocationId;
  final String toLocationId;
  final TransferStatus status;
  final String? notes;
  final DateTime? transferredAt;
  final String? transferredBy;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  AssetTransfer copyWith({
    TransferStatus? status,
    DateTime? transferredAt,
    String? transferredBy,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      AssetTransfer(
        id: id,
        tenantId: tenantId,
        assetId: assetId,
        fromLocationId: fromLocationId,
        toLocationId: toLocationId,
        status: status ?? this.status,
        notes: notes,
        transferredAt: transferredAt ?? this.transferredAt,
        transferredBy: transferredBy ?? this.transferredBy,
        version: version ?? this.version,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
      );

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'asset_id': assetId,
        'from_location_id': fromLocationId,
        'to_location_id': toLocationId,
        'status': status.value,
        'notes': notes,
        'transferred_at': transferredAt?.toIso8601String(),
        'transferred_by': transferredBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static AssetTransfer fromPayload(Map<String, dynamic> json, LocalRecord record) => AssetTransfer(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        assetId: json['asset_id'] as String? ?? '',
        fromLocationId: json['from_location_id'] as String?,
        toLocationId: json['to_location_id'] as String? ?? '',
        status: TransferStatus.fromValue(json['status'] as String?),
        notes: json['notes'] as String?,
        transferredAt: json['transferred_at'] != null ? DateTime.tryParse(json['transferred_at'] as String) : null,
        transferredBy: json['transferred_by'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, assetId, status];
}
