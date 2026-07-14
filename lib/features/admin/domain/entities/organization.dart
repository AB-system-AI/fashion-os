import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/enums/admin_enums.dart';

mixin AdminEntity on Equatable implements SyncableEntity {
  Map<String, dynamic> basePayload() => {
        'id': id,
        'tenant_id': tenantId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        if (deletedAt != null) 'deleted_at': deletedAt!.toIso8601String(),
      };

  static Map<String, dynamic> mergeRecord(Map<String, dynamic> json, LocalRecord record) => {
        ...json,
        'id': record.id,
        'tenant_id': record.tenantId,
        'version': record.version,
        'created_at': record.createdAt.toIso8601String(),
        'updated_at': record.updatedAt.toIso8601String(),
        if (record.deletedAt != null) 'deleted_at': record.deletedAt!.toIso8601String(),
      };
}

class Company extends Equatable with AdminEntity {
  const Company({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.code,
    this.legalName,
    this.taxId,
    this.status = OrgUnitStatus.active,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_company';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? code;
  final String? legalName;
  final String? taxId;
  final OrgUnitStatus status;
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

  Company copyWith({
    String? name,
    OrgUnitStatus? status,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      Company(
        id: id,
        tenantId: tenantId,
        name: name ?? this.name,
        code: code,
        legalName: legalName,
        taxId: taxId,
        status: status ?? this.status,
        version: version ?? this.version,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
      );

  @override
  Map<String, dynamic> toPayload() => {
        ...basePayload(),
        'name': name,
        'code': code,
        'legal_name': legalName,
        'tax_id': taxId,
        'status': status.value,
      };

  static Company fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return Company(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      name: m['name'] as String? ?? '',
      code: m['code'] as String?,
      legalName: m['legal_name'] as String?,
      taxId: m['tax_id'] as String?,
      status: OrgUnitStatus.fromValue(m['status'] as String?),
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, name, status, version];
}

class Branch extends Equatable with AdminEntity {
  const Branch({
    required this.id,
    required this.tenantId,
    required this.companyId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.code,
    this.address,
    this.status = OrgUnitStatus.active,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_branch';

  @override
  final String id;
  @override
  final String tenantId;
  final String companyId;
  final String name;
  final String? code;
  final String? address;
  final OrgUnitStatus status;
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
        ...basePayload(),
        'company_id': companyId,
        'name': name,
        'code': code,
        'address': address,
        'status': status.value,
      };

  static Branch fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return Branch(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      companyId: m['company_id'] as String? ?? '',
      name: m['name'] as String? ?? '',
      code: m['code'] as String?,
      address: m['address'] as String?,
      status: OrgUnitStatus.fromValue(m['status'] as String?),
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, companyId, name];
}

class Store extends Equatable with AdminEntity {
  const Store({
    required this.id,
    required this.tenantId,
    required this.branchId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.code,
    this.status = OrgUnitStatus.active,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_store';

  @override
  final String id;
  @override
  final String tenantId;
  final String branchId;
  final String name;
  final String? code;
  final OrgUnitStatus status;
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
        ...basePayload(),
        'branch_id': branchId,
        'name': name,
        'code': code,
        'status': status.value,
      };

  static Store fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return Store(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      branchId: m['branch_id'] as String? ?? '',
      name: m['name'] as String? ?? '',
      code: m['code'] as String?,
      status: OrgUnitStatus.fromValue(m['status'] as String?),
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, branchId, name];
}

class WarehouseAdmin extends Equatable with AdminEntity {
  const WarehouseAdmin({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.storeId,
    this.code,
    this.status = OrgUnitStatus.active,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_warehouse';

  @override
  final String id;
  @override
  final String tenantId;
  final String? storeId;
  final String name;
  final String? code;
  final OrgUnitStatus status;
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
        ...basePayload(),
        'store_id': storeId,
        'name': name,
        'code': code,
        'status': status.value,
      };

  static WarehouseAdmin fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return WarehouseAdmin(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      storeId: m['store_id'] as String?,
      name: m['name'] as String? ?? '',
      code: m['code'] as String?,
      status: OrgUnitStatus.fromValue(m['status'] as String?),
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, name];
}

class Department extends Equatable with AdminEntity {
  const Department({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.companyId,
    this.managerId,
    this.status = OrgUnitStatus.active,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_department';

  @override
  final String id;
  @override
  final String tenantId;
  final String? companyId;
  final String name;
  final String? managerId;
  final OrgUnitStatus status;
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
        ...basePayload(),
        'company_id': companyId,
        'name': name,
        'manager_id': managerId,
        'status': status.value,
      };

  static Department fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return Department(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      companyId: m['company_id'] as String?,
      name: m['name'] as String? ?? '',
      managerId: m['manager_id'] as String?,
      status: OrgUnitStatus.fromValue(m['status'] as String?),
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, name];
}

class Team extends Equatable with AdminEntity {
  const Team({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.departmentId,
    this.leadId,
    this.status = OrgUnitStatus.active,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_team';

  @override
  final String id;
  @override
  final String tenantId;
  final String? departmentId;
  final String name;
  final String? leadId;
  final OrgUnitStatus status;
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
        ...basePayload(),
        'department_id': departmentId,
        'name': name,
        'lead_id': leadId,
        'status': status.value,
      };

  static Team fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return Team(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      departmentId: m['department_id'] as String?,
      name: m['name'] as String? ?? '',
      leadId: m['lead_id'] as String?,
      status: OrgUnitStatus.fromValue(m['status'] as String?),
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, name];
}

class BusinessUnit extends Equatable with AdminEntity {
  const BusinessUnit({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.companyId,
    this.code,
    this.status = OrgUnitStatus.active,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_business_unit';

  @override
  final String id;
  @override
  final String tenantId;
  final String? companyId;
  final String name;
  final String? code;
  final OrgUnitStatus status;
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
        ...basePayload(),
        'company_id': companyId,
        'name': name,
        'code': code,
        'status': status.value,
      };

  static BusinessUnit fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return BusinessUnit(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      companyId: m['company_id'] as String?,
      name: m['name'] as String? ?? '',
      code: m['code'] as String?,
      status: OrgUnitStatus.fromValue(m['status'] as String?),
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, name];
}

class CostCenterAdmin extends Equatable with AdminEntity {
  const CostCenterAdmin({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.code,
    this.businessUnitId,
    this.status = OrgUnitStatus.active,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_cost_center';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? code;
  final String? businessUnitId;
  final OrgUnitStatus status;
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
        ...basePayload(),
        'name': name,
        'code': code,
        'business_unit_id': businessUnitId,
        'status': status.value,
      };

  static CostCenterAdmin fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return CostCenterAdmin(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      name: m['name'] as String? ?? '',
      code: m['code'] as String?,
      businessUnitId: m['business_unit_id'] as String?,
      status: OrgUnitStatus.fromValue(m['status'] as String?),
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, name, code];
}
