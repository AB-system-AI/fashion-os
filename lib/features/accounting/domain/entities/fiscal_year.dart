import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/enums/accounting_enums.dart';

class FiscalYear extends Equatable implements SyncableEntity {
  const FiscalYear({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.closed = false,
    this.closedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'fiscal_year';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool closed;
  final DateTime? closedAt;
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
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'is_closed': closed,
        'closed_at': closedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static FiscalYear fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return FiscalYear(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      name: json['name'] as String? ?? '',
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? record.createdAt,
      endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? record.createdAt,
      closed: json['is_closed'] as bool? ?? false,
      closedAt: json['closed_at'] != null ? DateTime.tryParse(json['closed_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, name, startDate];
}

class FiscalPeriod extends Equatable implements SyncableEntity {
  const FiscalPeriod({
    required this.id,
    required this.tenantId,
    required this.fiscalYearId,
    required this.name,
    required this.periodNumber,
    required this.startDate,
    required this.endDate,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = FiscalPeriodStatus.open,
    this.closedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'fiscal_period';

  @override
  final String id;
  @override
  final String tenantId;
  final String fiscalYearId;
  final String name;
  final int periodNumber;
  final DateTime startDate;
  final DateTime endDate;
  final FiscalPeriodStatus status;
  final DateTime? closedAt;
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
        'fiscal_year_id': fiscalYearId,
        'name': name,
        'period_number': periodNumber,
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'status': status.value,
        'closed_at': closedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static FiscalPeriod fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return FiscalPeriod(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      fiscalYearId: json['fiscal_year_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      periodNumber: (json['period_number'] as num?)?.toInt() ?? 1,
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ?? record.createdAt,
      endDate: DateTime.tryParse(json['end_date'] as String? ?? '') ?? record.createdAt,
      status: FiscalPeriodStatus.fromValue(json['status'] as String?),
      closedAt: json['closed_at'] != null ? DateTime.tryParse(json['closed_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, fiscalYearId, periodNumber];
}
