import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';

class ExchangeReference extends Equatable implements SyncableEntity {
  const ExchangeReference({
    required this.id,
    required this.tenantId,
    required this.storeId,
    required this.exchangeNumber,
    required this.returnId,
    required this.employeeId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.newSaleOrderId,
    this.status = ExchangeStatus.pending,
    this.priceDifference = 0,
    this.completedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'exchange';

  @override
  final String id;
  @override
  final String tenantId;
  final String storeId;
  final String exchangeNumber;
  final String returnId;
  final String? newSaleOrderId;
  final String employeeId;
  final ExchangeStatus status;
  final double priceDifference;
  final DateTime? completedAt;
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
        'store_id': storeId,
        'exchange_number': exchangeNumber,
        'return_id': returnId,
        'new_sale_order_id': newSaleOrderId,
        'employee_id': employeeId,
        'status': status.value,
        'price_difference': priceDifference,
        'completed_at': completedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ExchangeReference fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return ExchangeReference(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      storeId: json['store_id'] as String? ?? '',
      exchangeNumber: json['exchange_number'] as String? ?? '',
      returnId: json['return_id'] as String? ?? '',
      newSaleOrderId: json['new_sale_order_id'] as String?,
      employeeId: json['employee_id'] as String? ?? '',
      status: ExchangeStatus.fromValue(json['status'] as String?),
      priceDifference: (json['price_difference'] as num?)?.toDouble() ?? 0,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, exchangeNumber, status];
}
