import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/enums/sales_enums.dart';

class Shipment extends Equatable implements SyncableEntity {
  const Shipment({
    required this.id,
    required this.tenantId,
    required this.shipmentNumber,
    required this.orderId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = ShipmentStatus.pending,
    this.warehouseId,
    this.carrier,
    this.trackingNumber,
    this.shippedAt,
    this.deliveredAt,
    this.deletedAt,
  });

  static const entityTypeName = 'shipment';

  @override
  final String id;
  @override
  final String tenantId;
  final String shipmentNumber;
  final String orderId;
  final ShipmentStatus status;
  final String? warehouseId;
  final String? carrier;
  final String? trackingNumber;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
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

  Shipment copyWith({
    ShipmentStatus? status,
    String? trackingNumber,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      Shipment(
        id: id,
        tenantId: tenantId,
        shipmentNumber: shipmentNumber,
        orderId: orderId,
        status: status ?? this.status,
        warehouseId: warehouseId,
        carrier: carrier,
        trackingNumber: trackingNumber ?? this.trackingNumber,
        shippedAt: shippedAt ?? this.shippedAt,
        deliveredAt: deliveredAt ?? this.deliveredAt,
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
        'shipment_number': shipmentNumber,
        'order_id': orderId,
        'status': status.value,
        'warehouse_id': warehouseId,
        'carrier': carrier,
        'tracking_number': trackingNumber,
        'shipped_at': shippedAt?.toIso8601String(),
        'delivered_at': deliveredAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Shipment fromPayload(Map<String, dynamic> json, LocalRecord record) => Shipment(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        shipmentNumber: json['shipment_number'] as String? ?? record.searchName ?? '',
        orderId: json['order_id'] as String? ?? '',
        status: ShipmentStatus.fromValue(json['status'] as String?),
        warehouseId: json['warehouse_id'] as String?,
        carrier: json['carrier'] as String?,
        trackingNumber: json['tracking_number'] as String?,
        shippedAt: json['shipped_at'] != null ? DateTime.tryParse(json['shipped_at'] as String) : null,
        deliveredAt: json['delivered_at'] != null ? DateTime.tryParse(json['delivered_at'] as String) : null,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, shipmentNumber, status, version];
}

class ShipmentLine extends Equatable implements SyncableEntity {
  const ShipmentLine({
    required this.id,
    required this.tenantId,
    required this.shipmentId,
    required this.orderLineId,
    required this.productId,
    required this.quantity,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.pickedQty = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'shipment_line';

  @override
  final String id;
  @override
  final String tenantId;
  final String shipmentId;
  final String orderLineId;
  final String productId;
  final double quantity;
  final double pickedQty;
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
        'shipment_id': shipmentId,
        'order_line_id': orderLineId,
        'product_id': productId,
        'quantity': quantity,
        'picked_qty': pickedQty,
        'version': version,
      };

  static ShipmentLine fromPayload(Map<String, dynamic> json, LocalRecord record) => ShipmentLine(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        shipmentId: json['shipment_id'] as String? ?? '',
        orderLineId: json['order_line_id'] as String? ?? '',
        productId: json['product_id'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        pickedQty: (json['picked_qty'] as num?)?.toDouble() ?? 0,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, shipmentId, orderLineId, version];
}
