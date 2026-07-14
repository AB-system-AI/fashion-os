import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

class CustomerGroup extends Equatable implements SyncableEntity {
  const CustomerGroup({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.code,
    this.description,
    this.pricingRule,
    this.discountPercent = 0,
    this.loyaltyMultiplier = 1,
    this.creditLimit = 0,
    this.badgeColor,
    this.sortOrder = 0,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'customer_group';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? code;
  final String? description;
  final String? pricingRule;
  final double discountPercent;
  final double loyaltyMultiplier;
  final double creditLimit;
  final String? badgeColor;
  final int sortOrder;
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
        'name': name,
        'code': code,
        'description': description,
        'pricing_rule': pricingRule,
        'discount_percent': discountPercent,
        'loyalty_multiplier': loyaltyMultiplier,
        'credit_limit': creditLimit,
        'badge_color': badgeColor,
        'sort_order': sortOrder,
        'is_active': active,
        'version': version,
      };

  factory CustomerGroup.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return CustomerGroup(
      id: record.id,
      tenantId: record.tenantId,
      name: json['name'] as String? ?? record.searchName ?? '',
      code: json['code'] as String?,
      description: json['description'] as String?,
      pricingRule: json['pricing_rule'] as String?,
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0,
      loyaltyMultiplier: (json['loyalty_multiplier'] as num?)?.toDouble() ?? 1,
      creditLimit: (json['credit_limit'] as num?)?.toDouble() ?? 0,
      badgeColor: json['badge_color'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      active: json['is_active'] as bool? ?? true,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  CustomerGroup copyWith({
    String? name,
    String? code,
    String? description,
    double? discountPercent,
    double? loyaltyMultiplier,
    double? creditLimit,
    String? badgeColor,
    bool? active,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return CustomerGroup(
      id: id,
      tenantId: tenantId,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      pricingRule: pricingRule,
      discountPercent: discountPercent ?? this.discountPercent,
      loyaltyMultiplier: loyaltyMultiplier ?? this.loyaltyMultiplier,
      creditLimit: creditLimit ?? this.creditLimit,
      badgeColor: badgeColor ?? this.badgeColor,
      sortOrder: sortOrder,
      active: active ?? this.active,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, name, code];
}
