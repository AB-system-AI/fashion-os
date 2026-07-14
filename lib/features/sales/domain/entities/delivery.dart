import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/enums/sales_enums.dart';

class Delivery extends Equatable implements SyncableEntity {
  const Delivery({
    required this.id,
    required this.tenantId,
    required this.deliveryNumber,
    required this.shipmentId,
    required this.orderId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = DeliveryStatus.pending,
    this.estimatedAt,
    this.deliveredAt,
    this.recipientName,
    this.address,
    this.deletedAt,
  });

  static const entityTypeName = 'delivery';

  @override
  final String id;
  @override
  final String tenantId;
  final String deliveryNumber;
  final String shipmentId;
  final String orderId;
  final DeliveryStatus status;
  final DateTime? estimatedAt;
  final DateTime? deliveredAt;
  final String? recipientName;
  final String? address;
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

  Delivery copyWith({
    DeliveryStatus? status,
    DateTime? deliveredAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      Delivery(
        id: id,
        tenantId: tenantId,
        deliveryNumber: deliveryNumber,
        shipmentId: shipmentId,
        orderId: orderId,
        status: status ?? this.status,
        estimatedAt: estimatedAt,
        deliveredAt: deliveredAt ?? this.deliveredAt,
        recipientName: recipientName,
        address: address,
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
        'delivery_number': deliveryNumber,
        'shipment_id': shipmentId,
        'order_id': orderId,
        'status': status.value,
        'estimated_at': estimatedAt?.toIso8601String(),
        'delivered_at': deliveredAt?.toIso8601String(),
        'recipient_name': recipientName,
        'address': address,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Delivery fromPayload(Map<String, dynamic> json, LocalRecord record) => Delivery(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        deliveryNumber: json['delivery_number'] as String? ?? record.searchName ?? '',
        shipmentId: json['shipment_id'] as String? ?? '',
        orderId: json['order_id'] as String? ?? '',
        status: DeliveryStatus.fromValue(json['status'] as String?),
        estimatedAt: json['estimated_at'] != null ? DateTime.tryParse(json['estimated_at'] as String) : null,
        deliveredAt: json['delivered_at'] != null ? DateTime.tryParse(json['delivered_at'] as String) : null,
        recipientName: json['recipient_name'] as String?,
        address: json['address'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, deliveryNumber, status, version];
}

class DeliveryLine extends Equatable implements SyncableEntity {
  const DeliveryLine({
    required this.id,
    required this.tenantId,
    required this.deliveryId,
    required this.shipmentLineId,
    required this.productId,
    required this.quantity,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.deletedAt,
  });

  static const entityTypeName = 'delivery_line';

  @override
  final String id;
  @override
  final String tenantId;
  final String deliveryId;
  final String shipmentLineId;
  final String productId;
  final double quantity;
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
        'delivery_id': deliveryId,
        'shipment_line_id': shipmentLineId,
        'product_id': productId,
        'quantity': quantity,
        'version': version,
      };

  static DeliveryLine fromPayload(Map<String, dynamic> json, LocalRecord record) => DeliveryLine(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        deliveryId: json['delivery_id'] as String? ?? '',
        shipmentLineId: json['shipment_line_id'] as String? ?? '',
        productId: json['product_id'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, deliveryId, version];
}
