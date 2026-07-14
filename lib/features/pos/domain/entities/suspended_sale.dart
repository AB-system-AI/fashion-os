import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/sale.dart';

class SuspendedSale extends Equatable implements SyncableEntity {
  const SuspendedSale({
    required this.id,
    required this.tenantId,
    required this.storeId,
    required this.sale,
    required this.suspendedBy,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.label,
    this.suspendedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'suspended_sale';

  @override
  final String id;
  @override
  final String tenantId;
  final String storeId;
  final Sale sale;
  final String suspendedBy;
  final String? label;
  final DateTime? suspendedAt;
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
        'store_id': storeId,
        'sale': sale.toPayload(),
        'suspended_by': suspendedBy,
        'label': label,
        'suspended_at': suspendedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static SuspendedSale fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final saleJson = Map<String, dynamic>.from(json['sale'] as Map? ?? {});
    return SuspendedSale(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      storeId: json['store_id'] as String? ?? '',
      sale: Sale.fromPayload(saleJson, record),
      suspendedBy: json['suspended_by'] as String? ?? '',
      label: json['label'] as String?,
      suspendedAt: json['suspended_at'] != null ? DateTime.tryParse(json['suspended_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, sale.id, suspendedBy];
}
