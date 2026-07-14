import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/enums/manufacturing_enums.dart';

class BillOfMaterial extends Equatable implements SyncableEntity {
  const BillOfMaterial({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    required this.finishedProductId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.bomType = BomType.standard,
    this.quantity = 1,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'bill_of_material';

  @override
  final String id;
  @override
  final String tenantId;
  final String code;
  final String name;
  final String finishedProductId;
  final BomType bomType;
  final double quantity;
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

  BillOfMaterial copyWith({
    String? code,
    String? name,
    String? finishedProductId,
    BomType? bomType,
    double? quantity,
    bool? active,
    int? version,
    DateTime? updatedAt,
    DateTime? deletedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      BillOfMaterial(
        id: id,
        tenantId: tenantId,
        code: code ?? this.code,
        name: name ?? this.name,
        finishedProductId: finishedProductId ?? this.finishedProductId,
        bomType: bomType ?? this.bomType,
        quantity: quantity ?? this.quantity,
        active: active ?? this.active,
        version: version ?? this.version,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
      );

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'code': code,
        'name': name,
        'finished_product_id': finishedProductId,
        'bom_type': bomType.value,
        'quantity': quantity,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static BillOfMaterial fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return BillOfMaterial(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      finishedProductId: json['finished_product_id'] as String? ?? '',
      bomType: BomType.fromValue(json['bom_type'] as String?),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
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
  List<Object?> get props => [id, code, version];
}

class BomLine extends Equatable implements SyncableEntity {
  const BomLine({
    required this.id,
    required this.tenantId,
    required this.bomId,
    required this.componentProductId,
    required this.quantity,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.lineNumber = 1,
    this.unit = 'ea',
    this.consumptionMethod = ConsumptionMethod.manual,
    this.scrapPercent = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'bom_line';

  @override
  final String id;
  @override
  final String tenantId;
  final String bomId;
  final String componentProductId;
  final int lineNumber;
  final double quantity;
  final String unit;
  final ConsumptionMethod consumptionMethod;
  final double scrapPercent;
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
        'bom_id': bomId,
        'component_product_id': componentProductId,
        'line_number': lineNumber,
        'quantity': quantity,
        'unit': unit,
        'consumption_method': consumptionMethod.value,
        'scrap_percent': scrapPercent,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static BomLine fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return BomLine(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      bomId: json['bom_id'] as String? ?? '',
      componentProductId: json['component_product_id'] as String? ?? '',
      lineNumber: (json['line_number'] as num?)?.toInt() ?? 1,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? 'ea',
      consumptionMethod: ConsumptionMethod.fromValue(json['consumption_method'] as String?),
      scrapPercent: (json['scrap_percent'] as num?)?.toDouble() ?? 0,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, bomId, componentProductId];
}

class BomVersion extends Equatable implements SyncableEntity {
  const BomVersion({
    required this.id,
    required this.tenantId,
    required this.bomId,
    required this.versionNumber,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.effectiveFrom,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'bom_version';

  @override
  final String id;
  @override
  final String tenantId;
  final String bomId;
  final int versionNumber;
  final DateTime? effectiveFrom;
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
        'bom_id': bomId,
        'version_number': versionNumber,
        'effective_from': effectiveFrom?.toIso8601String().split('T').first,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static BomVersion fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return BomVersion(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      bomId: json['bom_id'] as String? ?? '',
      versionNumber: (json['version_number'] as num?)?.toInt() ?? 1,
      effectiveFrom: DateTime.tryParse(json['effective_from'] as String? ?? ''),
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
  List<Object?> get props => [id, bomId, versionNumber];
}
