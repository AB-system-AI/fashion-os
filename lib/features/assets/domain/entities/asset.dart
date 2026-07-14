import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/enums/assets_enums.dart';

class Asset extends Equatable implements SyncableEntity {
  const Asset({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.categoryId,
    required this.locationId,
    required this.acquisitionCost,
    required this.bookValue,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.assetTag,
    this.serialNumber,
    this.description,
    this.status = AssetStatus.active,
    this.acquisitionDate,
    this.usefulLifeMonths = 60,
    this.salvageValue = 0,
    this.depreciationMethod = DepreciationMethod.straightLine,
    this.accumulatedDepreciation = 0,
    this.lastMaintenanceAt,
    this.deletedAt,
  });

  static const entityTypeName = 'asset';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? assetTag;
  final String? serialNumber;
  final String? description;
  final String categoryId;
  final String locationId;
  final AssetStatus status;
  final double acquisitionCost;
  final double bookValue;
  final double accumulatedDepreciation;
  final DateTime? acquisitionDate;
  final int usefulLifeMonths;
  final double salvageValue;
  final DepreciationMethod depreciationMethod;
  final DateTime? lastMaintenanceAt;
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

  bool get isActive => status == AssetStatus.active && deletedAt == null;

  @override
  String get entityType => entityTypeName;

  Asset copyWith({
    String? locationId,
    AssetStatus? status,
    double? bookValue,
    double? accumulatedDepreciation,
    DateTime? lastMaintenanceAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      Asset(
        id: id,
        tenantId: tenantId,
        name: name,
        assetTag: assetTag,
        serialNumber: serialNumber,
        description: description,
        categoryId: categoryId,
        locationId: locationId ?? this.locationId,
        status: status ?? this.status,
        acquisitionCost: acquisitionCost,
        bookValue: bookValue ?? this.bookValue,
        accumulatedDepreciation: accumulatedDepreciation ?? this.accumulatedDepreciation,
        acquisitionDate: acquisitionDate,
        usefulLifeMonths: usefulLifeMonths,
        salvageValue: salvageValue,
        depreciationMethod: depreciationMethod,
        lastMaintenanceAt: lastMaintenanceAt ?? this.lastMaintenanceAt,
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
        'name': name,
        'asset_tag': assetTag,
        'serial_number': serialNumber,
        'description': description,
        'category_id': categoryId,
        'location_id': locationId,
        'status': status.value,
        'acquisition_cost': acquisitionCost,
        'book_value': bookValue,
        'accumulated_depreciation': accumulatedDepreciation,
        'acquisition_date': acquisitionDate?.toIso8601String(),
        'useful_life_months': usefulLifeMonths,
        'salvage_value': salvageValue,
        'depreciation_method': depreciationMethod.value,
        'last_maintenance_at': lastMaintenanceAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Asset fromPayload(Map<String, dynamic> json, LocalRecord record) => Asset(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        assetTag: json['asset_tag'] as String?,
        serialNumber: json['serial_number'] as String?,
        description: json['description'] as String?,
        categoryId: json['category_id'] as String? ?? '',
        locationId: json['location_id'] as String? ?? '',
        status: AssetStatus.fromValue(json['status'] as String?),
        acquisitionCost: (json['acquisition_cost'] as num?)?.toDouble() ?? 0,
        bookValue: (json['book_value'] as num?)?.toDouble() ?? 0,
        accumulatedDepreciation: (json['accumulated_depreciation'] as num?)?.toDouble() ?? 0,
        acquisitionDate: json['acquisition_date'] != null ? DateTime.tryParse(json['acquisition_date'] as String) : null,
        usefulLifeMonths: json['useful_life_months'] as int? ?? 60,
        salvageValue: (json['salvage_value'] as num?)?.toDouble() ?? 0,
        depreciationMethod: DepreciationMethod.fromValue(json['depreciation_method'] as String?),
        lastMaintenanceAt: json['last_maintenance_at'] != null ? DateTime.tryParse(json['last_maintenance_at'] as String) : null,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, status, bookValue, version];
}

class AssetCategory extends Equatable implements SyncableEntity {
  const AssetCategory({
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
    this.parentId,
    this.defaultUsefulLifeMonths = 60,
    this.defaultDepreciationMethod = DepreciationMethod.straightLine,
    this.deletedAt,
  });

  static const entityTypeName = 'asset_category';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? code;
  final String? description;
  final String? parentId;
  final int defaultUsefulLifeMonths;
  final DepreciationMethod defaultDepreciationMethod;
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
        'parent_id': parentId,
        'default_useful_life_months': defaultUsefulLifeMonths,
        'default_depreciation_method': defaultDepreciationMethod.value,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static AssetCategory fromPayload(Map<String, dynamic> json, LocalRecord record) => AssetCategory(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        code: json['code'] as String?,
        description: json['description'] as String?,
        parentId: json['parent_id'] as String?,
        defaultUsefulLifeMonths: json['default_useful_life_months'] as int? ?? 60,
        defaultDepreciationMethod: DepreciationMethod.fromValue(json['default_depreciation_method'] as String?),
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, code];
}

class AssetLocation extends Equatable implements SyncableEntity {
  const AssetLocation({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.code,
    this.address,
    this.storeId,
    this.warehouseId,
    this.deletedAt,
  });

  static const entityTypeName = 'asset_location';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? code;
  final String? address;
  final String? storeId;
  final String? warehouseId;
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
        'address': address,
        'store_id': storeId,
        'warehouse_id': warehouseId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static AssetLocation fromPayload(Map<String, dynamic> json, LocalRecord record) => AssetLocation(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        code: json['code'] as String?,
        address: json['address'] as String?,
        storeId: json['store_id'] as String?,
        warehouseId: json['warehouse_id'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, code];
}
