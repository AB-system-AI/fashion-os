import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';

class Coupon extends Equatable implements SyncableEntity {
  const Coupon({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.couponType,
    required this.value,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.discountId,
    this.minOrderAmount,
    this.maxUses,
    this.maxUsesPerCustomer = 1,
    this.usedCount = 0,
    this.startsAt,
    this.endsAt,
    this.customerId,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'coupon';

  @override
  final String id;
  @override
  final String tenantId;
  final String? discountId;
  final String code;
  final CouponType couponType;
  final double value;
  final double? minOrderAmount;
  final int? maxUses;
  final int maxUsesPerCustomer;
  final int usedCount;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? customerId;
  final bool active;
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
        'discount_id': discountId,
        'code': code,
        'coupon_type': couponType.value,
        'value': value,
        'min_order_amount': minOrderAmount,
        'max_uses': maxUses,
        'max_uses_per_customer': maxUsesPerCustomer,
        'used_count': usedCount,
        'starts_at': startsAt?.toIso8601String(),
        'ends_at': endsAt?.toIso8601String(),
        'customer_id': customerId,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Coupon fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Coupon(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      discountId: json['discount_id'] as String?,
      code: json['code'] as String? ?? '',
      couponType: CouponType.fromValue(json['coupon_type'] as String?),
      value: (json['value'] as num?)?.toDouble() ?? 0,
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble(),
      maxUses: (json['max_uses'] as num?)?.toInt(),
      maxUsesPerCustomer: (json['max_uses_per_customer'] as num?)?.toInt() ?? 1,
      usedCount: (json['used_count'] as num?)?.toInt() ?? 0,
      startsAt: json['starts_at'] != null ? DateTime.tryParse(json['starts_at'] as String) : null,
      endsAt: json['ends_at'] != null ? DateTime.tryParse(json['ends_at'] as String) : null,
      customerId: json['customer_id'] as String?,
      active: json['is_active'] as bool? ?? true,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, code, couponType];
}
