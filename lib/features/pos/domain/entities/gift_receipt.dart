import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

class GiftReceipt extends Equatable implements SyncableEntity {
  const GiftReceipt({
    required this.id,
    required this.tenantId,
    required this.saleOrderId,
    required this.giftNumber,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.recipientName,
    this.message,
    this.hidePrices = true,
    this.deletedAt,
  });

  static const entityTypeName = 'gift_receipt';

  @override
  final String id;
  @override
  final String tenantId;
  final String saleOrderId;
  final String giftNumber;
  final String? recipientName;
  final String? message;
  final bool hidePrices;
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
        'sale_order_id': saleOrderId,
        'gift_number': giftNumber,
        'recipient_name': recipientName,
        'message': message,
        'hide_prices': hidePrices,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static GiftReceipt fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return GiftReceipt(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      saleOrderId: json['sale_order_id'] as String? ?? '',
      giftNumber: json['gift_number'] as String? ?? '',
      recipientName: json['recipient_name'] as String?,
      message: json['message'] as String?,
      hidePrices: json['hide_prices'] as bool? ?? true,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, giftNumber, saleOrderId];
}
