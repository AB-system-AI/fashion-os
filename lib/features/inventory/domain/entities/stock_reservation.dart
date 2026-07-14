import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

class StockReservation extends Equatable implements SyncableEntity {
  const StockReservation({
    required this.id,
    required this.tenantId,
    required this.warehouseId,
    required this.productId,
    required this.quantity,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.variantId,
    this.referenceType,
    this.referenceId,
    this.expiresAt,
    this.releasedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'stock_reservation';

  @override
  final String id;
  @override
  final String tenantId;
  final String warehouseId;
  final String productId;
  final String? variantId;
  final double quantity;
  final String? referenceType;
  final String? referenceId;
  final DateTime? expiresAt;
  final DateTime? releasedAt;
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

  bool get isActive => releasedAt == null && deletedAt == null;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'warehouse_id': warehouseId,
        'product_id': productId,
        'variant_id': variantId,
        'quantity': quantity,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'expires_at': expiresAt?.toIso8601String(),
        'released_at': releasedAt?.toIso8601String(),
        'version': version,
      };

  factory StockReservation.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return StockReservation(
      id: record.id,
      tenantId: record.tenantId,
      warehouseId: json['warehouse_id'] as String? ?? record.storeId ?? '',
      productId: json['product_id'] as String? ?? record.searchSku ?? '',
      variantId: json['variant_id'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'] as String) : null,
      releasedAt: json['released_at'] != null ? DateTime.tryParse(json['released_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  StockReservation copyWith({
    double? quantity,
    DateTime? releasedAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return StockReservation(
      id: id,
      tenantId: tenantId,
      warehouseId: warehouseId,
      productId: productId,
      variantId: variantId,
      quantity: quantity ?? this.quantity,
      referenceType: referenceType,
      referenceId: referenceId,
      expiresAt: expiresAt,
      releasedAt: releasedAt ?? this.releasedAt,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, warehouseId, productId, quantity];
}
