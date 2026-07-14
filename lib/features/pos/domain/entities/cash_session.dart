import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';

class CashSession extends Equatable implements SyncableEntity {
  const CashSession({
    required this.id,
    required this.tenantId,
    required this.storeId,
    required this.registerId,
    required this.sessionNumber,
    required this.employeeId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = CashSessionStatus.open,
    this.openingFloat = 0,
    this.expectedCash = 0,
    this.actualCash,
    this.cashDifference,
    this.totalSales = 0,
    this.totalRefunds = 0,
    this.transactionCount = 0,
    this.openedAt,
    this.closedAt,
    this.notes,
    this.deletedAt,
  });

  static const entityTypeName = 'cash_session';

  @override
  final String id;
  @override
  final String tenantId;
  final String storeId;
  final String registerId;
  final String sessionNumber;
  final String employeeId;
  final CashSessionStatus status;
  final double openingFloat;
  final double expectedCash;
  final double? actualCash;
  final double? cashDifference;
  final double totalSales;
  final double totalRefunds;
  final int transactionCount;
  final DateTime? openedAt;
  final DateTime? closedAt;
  final String? notes;
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

  bool get isOpen => status == CashSessionStatus.open;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'store_id': storeId,
        'register_id': registerId,
        'session_number': sessionNumber,
        'employee_id': employeeId,
        'status': status.value,
        'opening_float': openingFloat,
        'expected_cash': expectedCash,
        'actual_cash': actualCash,
        'cash_difference': cashDifference,
        'total_sales': totalSales,
        'total_refunds': totalRefunds,
        'transaction_count': transactionCount,
        'opened_at': openedAt?.toIso8601String(),
        'closed_at': closedAt?.toIso8601String(),
        'notes': notes,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static CashSession fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return CashSession(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      storeId: json['store_id'] as String? ?? '',
      registerId: json['register_id'] as String? ?? '',
      sessionNumber: json['session_number'] as String? ?? '',
      employeeId: json['employee_id'] as String? ?? '',
      status: CashSessionStatus.fromValue(json['status'] as String?),
      openingFloat: (json['opening_float'] as num?)?.toDouble() ?? 0,
      expectedCash: (json['expected_cash'] as num?)?.toDouble() ?? 0,
      actualCash: (json['actual_cash'] as num?)?.toDouble(),
      cashDifference: (json['cash_difference'] as num?)?.toDouble(),
      totalSales: (json['total_sales'] as num?)?.toDouble() ?? 0,
      totalRefunds: (json['total_refunds'] as num?)?.toDouble() ?? 0,
      transactionCount: (json['transaction_count'] as num?)?.toInt() ?? 0,
      openedAt: json['opened_at'] != null ? DateTime.tryParse(json['opened_at'] as String) : null,
      closedAt: json['closed_at'] != null ? DateTime.tryParse(json['closed_at'] as String) : null,
      notes: json['notes'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  CashSession copyWith({
    CashSessionStatus? status,
    double? expectedCash,
    double? actualCash,
    double? cashDifference,
    double? totalSales,
    double? totalRefunds,
    int? transactionCount,
    DateTime? closedAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return CashSession(
      id: id,
      tenantId: tenantId,
      storeId: storeId,
      registerId: registerId,
      sessionNumber: sessionNumber,
      employeeId: employeeId,
      status: status ?? this.status,
      openingFloat: openingFloat,
      expectedCash: expectedCash ?? this.expectedCash,
      actualCash: actualCash ?? this.actualCash,
      cashDifference: cashDifference ?? this.cashDifference,
      totalSales: totalSales ?? this.totalSales,
      totalRefunds: totalRefunds ?? this.totalRefunds,
      transactionCount: transactionCount ?? this.transactionCount,
      openedAt: openedAt,
      closedAt: closedAt ?? this.closedAt,
      notes: notes,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, sessionNumber, status];
}
