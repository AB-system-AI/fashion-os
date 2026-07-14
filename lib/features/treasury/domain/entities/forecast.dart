import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/accounts.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/enums/treasury_enums.dart';

class CashForecast extends Equatable with TreasuryEntity {
  const CashForecast({
    required this.id,
    required this.tenantId,
    required this.period,
    required this.forecastDate,
    required this.projectedBalance,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.inflows = 0,
    this.outflows = 0,
    this.currencyCode = 'USD',
    this.deletedAt,
  });

  static const entityTypeName = 'cash_forecast';

  @override
  final String id;
  @override
  final String tenantId;
  final ForecastPeriod period;
  final DateTime forecastDate;
  final double projectedBalance;
  final double inflows;
  final double outflows;
  final String currencyCode;
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
        'period': period.value,
        'forecast_date': forecastDate.toIso8601String(),
        'projected_balance': projectedBalance,
        'inflows': inflows,
        'outflows': outflows,
        'currency_code': currencyCode,
      };

  static CashForecast fromPayload(Map<String, dynamic> json, LocalRecord record) => CashForecast(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        period: ForecastPeriod.fromValue(json['period'] as String?),
        forecastDate: DateTime.tryParse(json['forecast_date'] as String? ?? '') ?? record.createdAt,
        projectedBalance: (json['projected_balance'] as num?)?.toDouble() ?? 0,
        inflows: (json['inflows'] as num?)?.toDouble() ?? 0,
        outflows: (json['outflows'] as num?)?.toDouble() ?? 0,
        currencyCode: json['currency_code'] as String? ?? 'USD',
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, forecastDate, projectedBalance, version];
}

class BankReconciliation extends Equatable with TreasuryEntity {
  const BankReconciliation({
    required this.id,
    required this.tenantId,
    required this.bankAccountId,
    required this.statementDate,
    required this.bookBalance,
    required this.statementBalance,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = ReconciliationStatus.open,
    this.variance = 0,
    this.reconciledBy,
    this.deletedAt,
  });

  static const entityTypeName = 'bank_reconciliation';

  @override
  final String id;
  @override
  final String tenantId;
  final String bankAccountId;
  final DateTime statementDate;
  final double bookBalance;
  final double statementBalance;
  final double variance;
  final ReconciliationStatus status;
  final String? reconciledBy;
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

  BankReconciliation copyWith({
    ReconciliationStatus? status,
    double? variance,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      BankReconciliation(
        id: id,
        tenantId: tenantId,
        bankAccountId: bankAccountId,
        statementDate: statementDate,
        bookBalance: bookBalance,
        statementBalance: statementBalance,
        variance: variance ?? this.variance,
        status: status ?? this.status,
        reconciledBy: reconciledBy,
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
        'bank_account_id': bankAccountId,
        'statement_date': statementDate.toIso8601String(),
        'book_balance': bookBalance,
        'statement_balance': statementBalance,
        'variance': variance,
        'status': status.value,
        'reconciled_by': reconciledBy,
      };

  static BankReconciliation fromPayload(Map<String, dynamic> json, LocalRecord record) => BankReconciliation(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        bankAccountId: json['bank_account_id'] as String? ?? '',
        statementDate: DateTime.tryParse(json['statement_date'] as String? ?? '') ?? record.createdAt,
        bookBalance: (json['book_balance'] as num?)?.toDouble() ?? 0,
        statementBalance: (json['statement_balance'] as num?)?.toDouble() ?? 0,
        variance: (json['variance'] as num?)?.toDouble() ?? 0,
        status: ReconciliationStatus.fromValue(json['status'] as String?),
        reconciledBy: json['reconciled_by'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, bankAccountId, status, variance, version];
}
