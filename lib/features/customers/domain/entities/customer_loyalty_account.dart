import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

class CustomerLoyaltyAccount extends Equatable implements SyncableEntity {
  const CustomerLoyaltyAccount({
    required this.id,
    required this.tenantId,
    required this.customerId,
    required this.programId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.tierId,
    this.tierName,
    this.pointsBalance = 0,
    this.lifetimePoints = 0,
    this.enrolledAt,
    this.lastActivityAt,
    this.deletedAt,
  });

  static const entityTypeName = 'customer_loyalty_account';

  @override
  final String id;
  @override
  final String tenantId;
  final String customerId;
  final String programId;
  final String? tierId;
  final String? tierName;
  final int pointsBalance;
  final int lifetimePoints;
  final DateTime? enrolledAt;
  final DateTime? lastActivityAt;
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
        'customer_id': customerId,
        'program_id': programId,
        'tier_id': tierId,
        'tier_name': tierName,
        'points_balance': pointsBalance,
        'lifetime_points': lifetimePoints,
        'enrolled_at': enrolledAt?.toIso8601String(),
        'last_activity_at': lastActivityAt?.toIso8601String(),
        'version': version,
      };

  factory CustomerLoyaltyAccount.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return CustomerLoyaltyAccount(
      id: record.id,
      tenantId: record.tenantId,
      customerId: json['customer_id'] as String? ?? record.storeId ?? '',
      programId: json['program_id'] as String? ?? '',
      tierId: json['tier_id'] as String?,
      tierName: json['tier_name'] as String?,
      pointsBalance: (json['points_balance'] as num?)?.toInt() ?? 0,
      lifetimePoints: (json['lifetime_points'] as num?)?.toInt() ?? 0,
      enrolledAt: json['enrolled_at'] != null ? DateTime.tryParse(json['enrolled_at'] as String) : null,
      lastActivityAt: json['last_activity_at'] != null ? DateTime.tryParse(json['last_activity_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  CustomerLoyaltyAccount copyWith({
    String? tierId,
    String? tierName,
    int? pointsBalance,
    int? lifetimePoints,
    DateTime? lastActivityAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return CustomerLoyaltyAccount(
      id: id,
      tenantId: tenantId,
      customerId: customerId,
      programId: programId,
      tierId: tierId ?? this.tierId,
      tierName: tierName ?? this.tierName,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      enrolledAt: enrolledAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, customerId, pointsBalance];
}
