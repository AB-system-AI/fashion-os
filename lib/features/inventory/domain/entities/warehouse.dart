import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

class Warehouse extends Equatable implements SyncableEntity {
  const Warehouse({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.code,
    this.storeId,
    this.address,
    this.isActive = true,
    this.isDefault = false,
    this.deletedAt,
  });

  static const entityTypeName = 'warehouse';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? code;
  final String? storeId;
  final String? address;
  final bool isActive;
  final bool isDefault;
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
        'store_id': storeId,
        'address': address,
        'is_active': isActive,
        'is_default': isDefault,
        'version': version,
      };

  factory Warehouse.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Warehouse(
      id: record.id,
      tenantId: record.tenantId,
      name: json['name'] as String? ?? record.searchName ?? '',
      code: json['code'] as String?,
      storeId: json['store_id'] as String? ?? record.storeId,
      address: json['address'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isDefault: json['is_default'] as bool? ?? false,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  Warehouse copyWith({
    String? name,
    String? code,
    String? storeId,
    String? address,
    bool? isActive,
    bool? isDefault,
    int? version,
    DateTime? updatedAt,
    DateTime? deletedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return Warehouse(
      id: id,
      tenantId: tenantId,
      name: name ?? this.name,
      code: code ?? this.code,
      storeId: storeId ?? this.storeId,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, name, storeId];
}

class WarehouseLocation extends Equatable implements SyncableEntity {
  const WarehouseLocation({
    required this.id,
    required this.tenantId,
    required this.warehouseId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.code,
    this.aisle,
    this.bin,
    this.isActive = true,
    this.deletedAt,
  });

  static const entityTypeName = 'warehouse_location';

  @override
  final String id;
  @override
  final String tenantId;
  final String warehouseId;
  final String name;
  final String? code;
  final String? aisle;
  final String? bin;
  final bool isActive;
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
        'warehouse_id': warehouseId,
        'name': name,
        'code': code,
        'aisle': aisle,
        'bin': bin,
        'is_active': isActive,
        'version': version,
      };

  factory WarehouseLocation.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return WarehouseLocation(
      id: record.id,
      tenantId: record.tenantId,
      warehouseId: json['warehouse_id'] as String? ?? record.storeId ?? '',
      name: json['name'] as String? ?? record.searchName ?? '',
      code: json['code'] as String?,
      aisle: json['aisle'] as String?,
      bin: json['bin'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, warehouseId, name];
}
