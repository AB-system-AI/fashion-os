import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/enums/assets_enums.dart';

class ServiceContract extends Equatable implements SyncableEntity {
  const ServiceContract({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.assetId,
    this.vendorId,
    this.status = ContractStatus.active,
    this.startDate,
    this.endDate,
    this.annualCost = 0,
    this.coverageDetails,
    this.deletedAt,
  });

  static const entityTypeName = 'service_contract';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? assetId;
  final String? vendorId;
  final ContractStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final double annualCost;
  final String? coverageDetails;
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

  bool get isActive => status == ContractStatus.active && deletedAt == null;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'name': name,
        'asset_id': assetId,
        'vendor_id': vendorId,
        'status': status.value,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'annual_cost': annualCost,
        'coverage_details': coverageDetails,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ServiceContract fromPayload(Map<String, dynamic> json, LocalRecord record) => ServiceContract(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        assetId: json['asset_id'] as String?,
        vendorId: json['vendor_id'] as String?,
        status: ContractStatus.fromValue(json['status'] as String?),
        startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date'] as String) : null,
        endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date'] as String) : null,
        annualCost: (json['annual_cost'] as num?)?.toDouble() ?? 0,
        coverageDetails: json['coverage_details'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, status, endDate];
}

class Warranty extends Equatable implements SyncableEntity {
  const Warranty({
    required this.id,
    required this.tenantId,
    required this.assetId,
    required this.provider,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = WarrantyStatus.active,
    this.startDate,
    this.endDate,
    this.terms,
    this.deletedAt,
  });

  static const entityTypeName = 'warranty';

  @override
  final String id;
  @override
  final String tenantId;
  final String assetId;
  final String provider;
  final WarrantyStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? terms;
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

  bool get isValid => status == WarrantyStatus.active && (endDate == null || endDate!.isAfter(DateTime.now()));

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'asset_id': assetId,
        'provider': provider,
        'status': status.value,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'terms': terms,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Warranty fromPayload(Map<String, dynamic> json, LocalRecord record) => Warranty(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        assetId: json['asset_id'] as String? ?? '',
        provider: json['provider'] as String? ?? '',
        status: WarrantyStatus.fromValue(json['status'] as String?),
        startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date'] as String) : null,
        endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date'] as String) : null,
        terms: json['terms'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, assetId, provider, status];
}
