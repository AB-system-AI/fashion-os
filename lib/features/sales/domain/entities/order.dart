import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/enums/sales_enums.dart';

class SalesOrder extends Equatable implements SyncableEntity {
  const SalesOrder({
    required this.id,
    required this.tenantId,
    required this.orderNumber,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.customerId,
    this.quotationId,
    this.status = SalesOrderStatus.draft,
    this.warehouseId,
    this.subtotal = 0,
    this.discountTotal = 0,
    this.taxTotal = 0,
    this.grandTotal = 0,
    this.planningMethod = PlanningMethod.makeToStock,
    this.productionOrderId,
    this.notes,
    this.createdBy,
    this.deletedAt,
  });

  static const entityTypeName = 'sales_order';

  @override
  final String id;
  @override
  final String tenantId;
  final String orderNumber;
  final String? customerId;
  final String? quotationId;
  final SalesOrderStatus status;
  final String? warehouseId;
  final double subtotal;
  final double discountTotal;
  final double taxTotal;
  final double grandTotal;
  final PlanningMethod planningMethod;
  final String? productionOrderId;
  final String? notes;
  final String? createdBy;
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

  SalesOrder copyWith({
    SalesOrderStatus? status,
    String? productionOrderId,
    double? grandTotal,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      SalesOrder(
        id: id,
        tenantId: tenantId,
        orderNumber: orderNumber,
        customerId: customerId,
        quotationId: quotationId,
        status: status ?? this.status,
        warehouseId: warehouseId,
        subtotal: subtotal,
        discountTotal: discountTotal,
        taxTotal: taxTotal,
        grandTotal: grandTotal ?? this.grandTotal,
        planningMethod: planningMethod,
        productionOrderId: productionOrderId ?? this.productionOrderId,
        notes: notes,
        createdBy: createdBy,
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
        'order_number': orderNumber,
        'customer_id': customerId,
        'quotation_id': quotationId,
        'status': status.value,
        'warehouse_id': warehouseId,
        'subtotal': subtotal,
        'discount_total': discountTotal,
        'tax_total': taxTotal,
        'grand_total': grandTotal,
        'planning_method': planningMethod.value,
        'production_order_id': productionOrderId,
        'notes': notes,
        'created_by': createdBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static SalesOrder fromPayload(Map<String, dynamic> json, LocalRecord record) => SalesOrder(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        orderNumber: json['order_number'] as String? ?? record.searchName ?? '',
        customerId: json['customer_id'] as String?,
        quotationId: json['quotation_id'] as String?,
        status: SalesOrderStatus.fromValue(json['status'] as String?),
        warehouseId: json['warehouse_id'] as String?,
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
        discountTotal: (json['discount_total'] as num?)?.toDouble() ?? 0,
        taxTotal: (json['tax_total'] as num?)?.toDouble() ?? 0,
        grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0,
        planningMethod: PlanningMethod.fromValue(json['planning_method'] as String?),
        productionOrderId: json['production_order_id'] as String?,
        notes: json['notes'] as String?,
        createdBy: json['created_by'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, orderNumber, status, version];
}

class SalesOrderLine extends Equatable implements SyncableEntity {
  const SalesOrderLine({
    required this.id,
    required this.tenantId,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.lineNumber = 1,
    this.variantId,
    this.shippedQty = 0,
    this.returnedQty = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'sales_order_line';

  @override
  final String id;
  @override
  final String tenantId;
  final String orderId;
  final int lineNumber;
  final String productId;
  final String? variantId;
  final double quantity;
  final double unitPrice;
  final double shippedQty;
  final double returnedQty;
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

  SalesOrderLine copyWith({double? shippedQty, double? returnedQty, int? version, DateTime? updatedAt, LocalSyncStatus? syncStatus, bool? isDirty}) =>
      SalesOrderLine(
        id: id,
        tenantId: tenantId,
        orderId: orderId,
        lineNumber: lineNumber,
        productId: productId,
        variantId: variantId,
        quantity: quantity,
        unitPrice: unitPrice,
        shippedQty: shippedQty ?? this.shippedQty,
        returnedQty: returnedQty ?? this.returnedQty,
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
        'order_id': orderId,
        'line_number': lineNumber,
        'product_id': productId,
        'variant_id': variantId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'shipped_qty': shippedQty,
        'returned_qty': returnedQty,
        'version': version,
      };

  static SalesOrderLine fromPayload(Map<String, dynamic> json, LocalRecord record) => SalesOrderLine(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        orderId: json['order_id'] as String? ?? '',
        lineNumber: json['line_number'] as int? ?? 1,
        productId: json['product_id'] as String? ?? '',
        variantId: json['variant_id'] as String?,
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
        shippedQty: (json['shipped_qty'] as num?)?.toDouble() ?? 0,
        returnedQty: (json['returned_qty'] as num?)?.toDouble() ?? 0,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, orderId, lineNumber, version];
}

class SalesReservation extends Equatable implements SyncableEntity {
  const SalesReservation({
    required this.id,
    required this.tenantId,
    required this.orderId,
    required this.orderLineId,
    required this.productId,
    required this.quantity,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.warehouseId,
    this.stockReservationId,
    this.releasedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'sales_reservation';

  @override
  final String id;
  @override
  final String tenantId;
  final String orderId;
  final String orderLineId;
  final String productId;
  final String? warehouseId;
  final double quantity;
  final String? stockReservationId;
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
        'order_id': orderId,
        'order_line_id': orderLineId,
        'product_id': productId,
        'warehouse_id': warehouseId,
        'quantity': quantity,
        'stock_reservation_id': stockReservationId,
        'released_at': releasedAt?.toIso8601String(),
        'version': version,
      };

  static SalesReservation fromPayload(Map<String, dynamic> json, LocalRecord record) => SalesReservation(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        orderId: json['order_id'] as String? ?? '',
        orderLineId: json['order_line_id'] as String? ?? '',
        productId: json['product_id'] as String? ?? '',
        warehouseId: json['warehouse_id'] as String?,
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        stockReservationId: json['stock_reservation_id'] as String?,
        releasedAt: json['released_at'] != null ? DateTime.tryParse(json['released_at'] as String) : null,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, orderId, orderLineId, version];
}

class BackOrder extends Equatable implements SyncableEntity {
  const BackOrder({
    required this.id,
    required this.tenantId,
    required this.orderId,
    required this.orderLineId,
    required this.productId,
    required this.quantity,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = BackOrderStatus.open,
    this.fulfilledQty = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'back_order';

  @override
  final String id;
  @override
  final String tenantId;
  final String orderId;
  final String orderLineId;
  final String productId;
  final double quantity;
  final double fulfilledQty;
  final BackOrderStatus status;
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
        'order_id': orderId,
        'order_line_id': orderLineId,
        'product_id': productId,
        'quantity': quantity,
        'fulfilled_qty': fulfilledQty,
        'status': status.value,
        'version': version,
      };

  static BackOrder fromPayload(Map<String, dynamic> json, LocalRecord record) => BackOrder(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        orderId: json['order_id'] as String? ?? '',
        orderLineId: json['order_line_id'] as String? ?? '',
        productId: json['product_id'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        fulfilledQty: (json['fulfilled_qty'] as num?)?.toDouble() ?? 0,
        status: BackOrderStatus.fromValue(json['status'] as String?),
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, orderId, status, version];
}

class SalesInvoiceReference extends Equatable implements SyncableEntity {
  const SalesInvoiceReference({
    required this.id,
    required this.tenantId,
    required this.orderId,
    required this.invoiceNumber,
    required this.amount,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.journalEntryId,
    this.deletedAt,
  });

  static const entityTypeName = 'sales_invoice_reference';

  @override
  final String id;
  @override
  final String tenantId;
  final String orderId;
  final String invoiceNumber;
  final double amount;
  final String? journalEntryId;
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
        'order_id': orderId,
        'invoice_number': invoiceNumber,
        'amount': amount,
        'journal_entry_id': journalEntryId,
        'version': version,
      };

  static SalesInvoiceReference fromPayload(Map<String, dynamic> json, LocalRecord record) => SalesInvoiceReference(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        orderId: json['order_id'] as String? ?? '',
        invoiceNumber: json['invoice_number'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        journalEntryId: json['journal_entry_id'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, orderId, invoiceNumber, version];
}
