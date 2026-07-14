import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

/// Catalog link between product/variant and inventory tracking.
class InventoryItem extends Equatable implements SyncableEntity {
  const InventoryItem({
    required this.id,
    required this.tenantId,
    required this.productId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.variantId,
    this.sku,
    this.barcode,
    this.trackInventory = true,
    this.allowNegativeStock = false,
    this.deletedAt,
  });

  static const entityTypeName = 'inventory_item';

  @override
  final String id;
  @override
  final String tenantId;
  final String productId;
  final String? variantId;
  final String? sku;
  final String? barcode;
  final bool trackInventory;
  final bool allowNegativeStock;
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

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'product_id': productId,
        'variant_id': variantId,
        'sku': sku,
        'barcode': barcode,
        'track_inventory': trackInventory,
        'allow_negative_stock': allowNegativeStock,
        'version': version,
      };

  factory InventoryItem.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return InventoryItem(
      id: record.id,
      tenantId: record.tenantId,
      productId: json['product_id'] as String? ?? record.searchSku ?? '',
      variantId: json['variant_id'] as String?,
      sku: json['sku'] as String? ?? record.searchSku,
      barcode: json['barcode'] as String? ?? record.searchBarcode,
      trackInventory: json['track_inventory'] as bool? ?? true,
      allowNegativeStock: json['allow_negative_stock'] as bool? ?? false,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, productId, variantId];
}
