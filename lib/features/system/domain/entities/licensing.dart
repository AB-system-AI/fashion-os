import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/system/domain/enums/system_enums.dart';

class LicenseRecord extends Equatable implements SyncableEntity {
  const LicenseRecord({
    required this.id,
    required this.tenantId,
    required this.licenseKey,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = LicenseStatus.unknown,
    this.planCode,
    this.validFrom,
    this.validUntil,
    this.maxUsers = 0,
    this.maxStores = 0,
    this.features = const [],
    this.deletedAt,
  });

  static const entityTypeName = 'license_record';

  @override
  final String id;
  @override
  final String tenantId;
  final String licenseKey;
  final LicenseStatus status;
  final String? planCode;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final int maxUsers;
  final int maxStores;
  final List<String> features;
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
        'license_key': licenseKey,
        'status': status.value,
        'plan_code': planCode,
        'valid_from': validFrom?.toIso8601String(),
        'valid_until': validUntil?.toIso8601String(),
        'max_users': maxUsers,
        'max_stores': maxStores,
        'features': features,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static LicenseRecord fromPayload(Map<String, dynamic> json, LocalRecord record) => LicenseRecord(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        licenseKey: json['license_key'] as String? ?? record.searchName ?? '',
        status: LicenseStatus.fromValue(json['status'] as String?),
        planCode: json['plan_code'] as String?,
        validFrom: json['valid_from'] != null ? DateTime.tryParse(json['valid_from'] as String) : null,
        validUntil: json['valid_until'] != null ? DateTime.tryParse(json['valid_until'] as String) : null,
        maxUsers: json['max_users'] as int? ?? 0,
        maxStores: json['max_stores'] as int? ?? 0,
        features: List<String>.from(json['features'] as List? ?? []),
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, licenseKey, status, validUntil];
}

class SubscriptionRecord extends Equatable implements SyncableEntity {
  const SubscriptionRecord({
    required this.id,
    required this.tenantId,
    required this.planCode,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = SubscriptionStatus.active,
    this.billingCycle,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.cancelAt,
    this.externalId,
    this.deletedAt,
  });

  static const entityTypeName = 'subscription_record';

  @override
  final String id;
  @override
  final String tenantId;
  final String planCode;
  final SubscriptionStatus status;
  final String? billingCycle;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? cancelAt;
  final String? externalId;
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
        'plan_code': planCode,
        'status': status.value,
        'billing_cycle': billingCycle,
        'current_period_start': currentPeriodStart?.toIso8601String(),
        'current_period_end': currentPeriodEnd?.toIso8601String(),
        'cancel_at': cancelAt?.toIso8601String(),
        'external_id': externalId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static SubscriptionRecord fromPayload(Map<String, dynamic> json, LocalRecord record) => SubscriptionRecord(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        planCode: json['plan_code'] as String? ?? record.searchName ?? '',
        status: SubscriptionStatus.fromValue(json['status'] as String?),
        billingCycle: json['billing_cycle'] as String?,
        currentPeriodStart: json['current_period_start'] != null ? DateTime.tryParse(json['current_period_start'] as String) : null,
        currentPeriodEnd: json['current_period_end'] != null ? DateTime.tryParse(json['current_period_end'] as String) : null,
        cancelAt: json['cancel_at'] != null ? DateTime.tryParse(json['cancel_at'] as String) : null,
        externalId: json['external_id'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, planCode, status, currentPeriodEnd];
}
