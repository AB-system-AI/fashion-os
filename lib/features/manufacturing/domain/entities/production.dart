import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/enums/manufacturing_enums.dart';

class ProductionOrder extends Equatable implements SyncableEntity {
  const ProductionOrder({
    required this.id,
    required this.tenantId,
    required this.orderNumber,
    required this.productId,
    required this.plannedQty,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.bomId,
    this.status = ProductionStatus.draft,
    this.completedQty = 0,
    this.scrappedQty = 0,
    this.warehouseId,
    this.plannedStart,
    this.plannedEnd,
    this.actualStart,
    this.actualEnd,
    this.deletedAt,
  });

  static const entityTypeName = 'production_order';

  @override
  final String id;
  @override
  final String tenantId;
  final String orderNumber;
  final String productId;
  final String? bomId;
  final ProductionStatus status;
  final double plannedQty;
  final double completedQty;
  final double scrappedQty;
  final String? warehouseId;
  final DateTime? plannedStart;
  final DateTime? plannedEnd;
  final DateTime? actualStart;
  final DateTime? actualEnd;
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

  ProductionOrder copyWith({
    ProductionStatus? status,
    double? completedQty,
    double? scrappedQty,
    DateTime? actualStart,
    DateTime? actualEnd,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return ProductionOrder(
      id: id,
      tenantId: tenantId,
      orderNumber: orderNumber,
      productId: productId,
      bomId: bomId,
      status: status ?? this.status,
      plannedQty: plannedQty,
      completedQty: completedQty ?? this.completedQty,
      scrappedQty: scrappedQty ?? this.scrappedQty,
      warehouseId: warehouseId,
      plannedStart: plannedStart,
      plannedEnd: plannedEnd,
      actualStart: actualStart ?? this.actualStart,
      actualEnd: actualEnd ?? this.actualEnd,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'order_number': orderNumber,
        'product_id': productId,
        'bom_id': bomId,
        'status': status.value,
        'planned_qty': plannedQty,
        'completed_qty': completedQty,
        'scrapped_qty': scrappedQty,
        'warehouse_id': warehouseId,
        'planned_start': plannedStart?.toIso8601String(),
        'planned_end': plannedEnd?.toIso8601String(),
        'actual_start': actualStart?.toIso8601String(),
        'actual_end': actualEnd?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ProductionOrder fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return ProductionOrder(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      orderNumber: json['order_number'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      bomId: json['bom_id'] as String?,
      status: ProductionStatus.fromValue(json['status'] as String?),
      plannedQty: (json['planned_qty'] as num?)?.toDouble() ?? 0,
      completedQty: (json['completed_qty'] as num?)?.toDouble() ?? 0,
      scrappedQty: (json['scrapped_qty'] as num?)?.toDouble() ?? 0,
      warehouseId: json['warehouse_id'] as String?,
      plannedStart: DateTime.tryParse(json['planned_start'] as String? ?? ''),
      plannedEnd: DateTime.tryParse(json['planned_end'] as String? ?? ''),
      actualStart: DateTime.tryParse(json['actual_start'] as String? ?? ''),
      actualEnd: DateTime.tryParse(json['actual_end'] as String? ?? ''),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, orderNumber, version];
}

class ProductionOrderLine extends Equatable implements SyncableEntity {
  const ProductionOrderLine({
    required this.id,
    required this.tenantId,
    required this.productionOrderId,
    required this.componentProductId,
    required this.requiredQty,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.issuedQty = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'production_order_line';

  @override
  final String id;
  @override
  final String tenantId;
  final String productionOrderId;
  final String componentProductId;
  final double requiredQty;
  final double issuedQty;
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
        'production_order_id': productionOrderId,
        'component_product_id': componentProductId,
        'required_qty': requiredQty,
        'issued_qty': issuedQty,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ProductionOrderLine fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return ProductionOrderLine(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      productionOrderId: json['production_order_id'] as String? ?? '',
      componentProductId: json['component_product_id'] as String? ?? '',
      requiredQty: (json['required_qty'] as num?)?.toDouble() ?? 0,
      issuedQty: (json['issued_qty'] as num?)?.toDouble() ?? 0,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, productionOrderId, componentProductId];
}

class ProductionOutput extends Equatable implements SyncableEntity {
  const ProductionOutput({
    required this.id,
    required this.tenantId,
    required this.productionOrderId,
    required this.productId,
    required this.quantity,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.warehouseId,
    this.outputDate,
    this.deletedAt,
  });

  static const entityTypeName = 'production_output';

  @override
  final String id;
  @override
  final String tenantId;
  final String productionOrderId;
  final String productId;
  final double quantity;
  final String? warehouseId;
  final DateTime? outputDate;
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
        'production_order_id': productionOrderId,
        'product_id': productId,
        'quantity': quantity,
        'warehouse_id': warehouseId,
        'output_date': outputDate?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ProductionOutput fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return ProductionOutput(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      productionOrderId: json['production_order_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      warehouseId: json['warehouse_id'] as String?,
      outputDate: DateTime.tryParse(json['output_date'] as String? ?? ''),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, productionOrderId];
}

class ProductionScrap extends Equatable implements SyncableEntity {
  const ProductionScrap({
    required this.id,
    required this.tenantId,
    required this.productionOrderId,
    required this.productId,
    required this.quantity,
    required this.reason,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.deletedAt,
  });

  static const entityTypeName = 'production_scrap';

  @override
  final String id;
  @override
  final String tenantId;
  final String productionOrderId;
  final String productId;
  final double quantity;
  final ScrapReason reason;
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
        'production_order_id': productionOrderId,
        'product_id': productId,
        'quantity': quantity,
        'reason': reason.value,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ProductionScrap fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return ProductionScrap(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      productionOrderId: json['production_order_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      reason: ScrapReason.fromValue(json['reason'] as String?),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, productionOrderId];
}

class FinishedGoodsReceipt extends Equatable implements SyncableEntity {
  const FinishedGoodsReceipt({
    required this.id,
    required this.tenantId,
    required this.productionOrderId,
    required this.productId,
    required this.quantity,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.warehouseId,
    this.receiptDate,
    this.deletedAt,
  });

  static const entityTypeName = 'finished_goods_receipt';

  @override
  final String id;
  @override
  final String tenantId;
  final String productionOrderId;
  final String productId;
  final double quantity;
  final String? warehouseId;
  final DateTime? receiptDate;
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
        'production_order_id': productionOrderId,
        'product_id': productId,
        'quantity': quantity,
        'warehouse_id': warehouseId,
        'receipt_date': receiptDate?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static FinishedGoodsReceipt fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return FinishedGoodsReceipt(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      productionOrderId: json['production_order_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      warehouseId: json['warehouse_id'] as String?,
      receiptDate: DateTime.tryParse(json['receipt_date'] as String? ?? ''),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, productionOrderId];
}
