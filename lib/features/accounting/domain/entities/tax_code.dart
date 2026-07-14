import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

class TaxCode extends Equatable implements SyncableEntity {
  const TaxCode({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    required this.rate,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.accountId,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'tax_code';

  @override
  final String id;
  @override
  final String tenantId;
  final String code;
  final String name;
  final double rate;
  final String? accountId;
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
        'code': code,
        'name': name,
        'rate': rate,
        'account_id': accountId,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static TaxCode fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return TaxCode(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 0,
      accountId: json['account_id'] as String?,
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
  List<Object?> get props => [id, code];
}

class TaxGroup extends Equatable implements SyncableEntity {
  const TaxGroup({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    required this.taxCodeIds,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'tax_group';

  @override
  final String id;
  @override
  final String tenantId;
  final String code;
  final String name;
  final List<String> taxCodeIds;
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
        'code': code,
        'name': name,
        'tax_code_ids': taxCodeIds,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static TaxGroup fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final ids = json['tax_code_ids'] as List? ?? [];
    return TaxGroup(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      taxCodeIds: ids.map((e) => e.toString()).toList(),
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
  List<Object?> get props => [id, code];
}
