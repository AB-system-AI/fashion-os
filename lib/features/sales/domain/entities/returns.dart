import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/enums/sales_enums.dart';

class SalesReturnRequest extends Equatable implements SyncableEntity {
  const SalesReturnRequest({
    required this.id,
    required this.tenantId,
    required this.orderId,
    required this.orderLineId,
    required this.quantity,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.returnNumber,
    this.status = ReturnRequestStatus.draft,
    this.reason,
    this.refundAmount = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'sales_return_request';

  @override
  final String id;
  @override
  final String tenantId;
  final String? returnNumber;
  final String orderId;
  final String orderLineId;
  final double quantity;
  final ReturnRequestStatus status;
  final String? reason;
  final double refundAmount;
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
        'return_number': returnNumber,
        'order_id': orderId,
        'order_line_id': orderLineId,
        'quantity': quantity,
        'status': status.value,
        'reason': reason,
        'refund_amount': refundAmount,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static SalesReturnRequest fromPayload(Map<String, dynamic> json, LocalRecord record) => SalesReturnRequest(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        returnNumber: json['return_number'] as String?,
        orderId: json['order_id'] as String? ?? '',
        orderLineId: json['order_line_id'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        status: ReturnRequestStatus.fromValue(json['status'] as String?),
        reason: json['reason'] as String?,
        refundAmount: (json['refund_amount'] as num?)?.toDouble() ?? 0,
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

class ExchangeRequest extends Equatable implements SyncableEntity {
  const ExchangeRequest({
    required this.id,
    required this.tenantId,
    required this.orderId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.exchangeNumber,
    this.returnLineId,
    this.newProductId,
    this.newQuantity = 1,
    this.status = ExchangeRequestStatus.draft,
    this.priceDifference = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'exchange_request';

  @override
  final String id;
  @override
  final String tenantId;
  final String? exchangeNumber;
  final String orderId;
  final String? returnLineId;
  final String? newProductId;
  final double newQuantity;
  final ExchangeRequestStatus status;
  final double priceDifference;
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
        'exchange_number': exchangeNumber,
        'order_id': orderId,
        'return_line_id': returnLineId,
        'new_product_id': newProductId,
        'new_quantity': newQuantity,
        'status': status.value,
        'price_difference': priceDifference,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ExchangeRequest fromPayload(Map<String, dynamic> json, LocalRecord record) => ExchangeRequest(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        exchangeNumber: json['exchange_number'] as String?,
        orderId: json['order_id'] as String? ?? '',
        returnLineId: json['return_line_id'] as String?,
        newProductId: json['new_product_id'] as String?,
        newQuantity: (json['new_quantity'] as num?)?.toDouble() ?? 1,
        status: ExchangeRequestStatus.fromValue(json['status'] as String?),
        priceDifference: (json['price_difference'] as num?)?.toDouble() ?? 0,
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
