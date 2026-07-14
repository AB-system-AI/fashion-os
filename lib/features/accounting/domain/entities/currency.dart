import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

class AccountingCurrency extends Equatable implements SyncableEntity {
  const AccountingCurrency({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.symbol,
    this.decimalPlaces = 2,
    this.isBase = false,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'accounting_currency';

  @override
  final String id;
  @override
  final String tenantId;
  final String code;
  final String name;
  final String? symbol;
  final int decimalPlaces;
  final bool isBase;
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
        'symbol': symbol,
        'decimal_places': decimalPlaces,
        'is_base': isBase,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static AccountingCurrency fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return AccountingCurrency(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String?,
      decimalPlaces: (json['decimal_places'] as num?)?.toInt() ?? 2,
      isBase: json['is_base'] as bool? ?? false,
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

class ExchangeRate extends Equatable implements SyncableEntity {
  const ExchangeRate({
    required this.id,
    required this.tenantId,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.effectiveDate,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.source,
    this.deletedAt,
  });

  static const entityTypeName = 'exchange_rate';

  @override
  final String id;
  @override
  final String tenantId;
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime effectiveDate;
  final String? source;
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
        'from_currency': fromCurrency,
        'to_currency': toCurrency,
        'rate': rate,
        'effective_date': effectiveDate.toIso8601String().split('T').first,
        'source': source,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ExchangeRate fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return ExchangeRate(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      fromCurrency: json['from_currency'] as String? ?? '',
      toCurrency: json['to_currency'] as String? ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 1,
      effectiveDate: DateTime.tryParse(json['effective_date'] as String? ?? '') ?? record.createdAt,
      source: json['source'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, fromCurrency, toCurrency, effectiveDate];
}

class PaymentTerm extends Equatable implements SyncableEntity {
  const PaymentTerm({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    required this.dueDays,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.discountPercent,
    this.discountDays,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'payment_term';

  @override
  final String id;
  @override
  final String tenantId;
  final String code;
  final String name;
  final int dueDays;
  final double? discountPercent;
  final int? discountDays;
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
        'due_days': dueDays,
        'discount_percent': discountPercent,
        'discount_days': discountDays,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static PaymentTerm fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return PaymentTerm(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dueDays: (json['due_days'] as num?)?.toInt() ?? 0,
      discountPercent: (json['discount_percent'] as num?)?.toDouble(),
      discountDays: (json['discount_days'] as num?)?.toInt(),
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
