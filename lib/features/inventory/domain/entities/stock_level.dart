import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/enums/inventory_enums.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/value_objects/quantity.dart';

class StockLevel extends Equatable implements SyncableEntity {
  const StockLevel({
    required this.id,
    required this.tenantId,
    required this.warehouseId,
    required this.productId,
    required this.onHand,
    required this.reserved,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.variantId,
    this.incoming = 0,
    this.damaged = 0,
    this.minimumLevel,
    this.maximumLevel,
    this.deletedAt,
  });

  static const entityTypeName = 'stock_level';

  @override
  final String id;
  @override
  final String tenantId;
  final String warehouseId;
  final String productId;
  final String? variantId;
  final double onHand;
  final double reserved;
  final double incoming;
  final double damaged;
  final double? minimumLevel;
  final double? maximumLevel;
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

  double get available => onHand - reserved - damaged;

  StockStatus get status {
    if (available < 0) return StockStatus.negative;
    if (available == 0) return StockStatus.outOfStock;
    if (minimumLevel != null && available <= minimumLevel!) return StockStatus.lowStock;
    if (reserved > 0 && available <= reserved) return StockStatus.reserved;
    return StockStatus.inStock;
  }

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'warehouse_id': warehouseId,
        'product_id': productId,
        'variant_id': variantId,
        'on_hand': onHand,
        'reserved': reserved,
        'incoming': incoming,
        'damaged': damaged,
        'minimum_level': minimumLevel,
        'maximum_level': maximumLevel,
        'version': version,
      };

  factory StockLevel.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return StockLevel(
      id: record.id,
      tenantId: record.tenantId,
      warehouseId: json['warehouse_id'] as String? ?? record.storeId ?? '',
      productId: json['product_id'] as String? ?? record.searchSku ?? '',
      variantId: json['variant_id'] as String?,
      onHand: (json['on_hand'] as num?)?.toDouble() ?? 0,
      reserved: (json['reserved'] as num?)?.toDouble() ?? 0,
      incoming: (json['incoming'] as num?)?.toDouble() ?? 0,
      damaged: (json['damaged'] as num?)?.toDouble() ?? 0,
      minimumLevel: (json['minimum_level'] as num?)?.toDouble(),
      maximumLevel: (json['maximum_level'] as num?)?.toDouble(),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  StockLevel copyWith({
    double? onHand,
    double? reserved,
    double? incoming,
    double? damaged,
    double? minimumLevel,
    double? maximumLevel,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return StockLevel(
      id: id,
      tenantId: tenantId,
      warehouseId: warehouseId,
      productId: productId,
      variantId: variantId,
      onHand: onHand ?? this.onHand,
      reserved: reserved ?? this.reserved,
      incoming: incoming ?? this.incoming,
      damaged: damaged ?? this.damaged,
      minimumLevel: minimumLevel ?? this.minimumLevel,
      maximumLevel: maximumLevel ?? this.maximumLevel,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  Quantity get onHandQuantity => Quantity(onHand);
  Quantity get reservedQuantity => Quantity(reserved);
  Quantity get availableQuantity => Quantity(available);

  @override
  List<Object?> get props => [id, warehouseId, productId, variantId, onHand, reserved];
}
