import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/enums/treasury_enums.dart';

mixin TreasuryEntity on Equatable implements SyncableEntity {
  Map<String, dynamic> basePayload() => {
        'id': id,
        'tenant_id': tenantId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class TreasuryAccount extends Equatable with TreasuryEntity {
  const TreasuryAccount({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.accountType,
    required this.currencyCode,
    required this.balance,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.code,
    this.isActive = true,
    this.deletedAt,
  });

  static const entityTypeName = 'treasury_account';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? code;
  final TreasuryAccountType accountType;
  final String currencyCode;
  final double balance;
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

  TreasuryAccount copyWith({double? balance, int? version, DateTime? updatedAt, LocalSyncStatus? syncStatus, bool? isDirty}) =>
      TreasuryAccount(
        id: id,
        tenantId: tenantId,
        name: name,
        code: code,
        accountType: accountType,
        currencyCode: currencyCode,
        balance: balance ?? this.balance,
        isActive: isActive,
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
        'account_type': accountType.value,
        'currency_code': currencyCode,
        'balance': balance,
        'is_active': isActive,
      };

  static TreasuryAccount fromPayload(Map<String, dynamic> json, LocalRecord record) => TreasuryAccount(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        code: json['code'] as String?,
        accountType: TreasuryAccountType.fromValue(json['account_type'] as String?),
        currencyCode: json['currency_code'] as String? ?? 'USD',
        balance: (json['balance'] as num?)?.toDouble() ?? 0,
        isActive: json['is_active'] as bool? ?? true,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, accountType, balance, version];
}

class CashBox extends Equatable with TreasuryEntity {
  const CashBox({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.balance,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.storeId,
    this.status = CashBoxStatus.open,
    this.currencyCode = 'USD',
    this.deletedAt,
  });

  static const entityTypeName = 'cash_box';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? storeId;
  final CashBoxStatus status;
  final String currencyCode;
  final double balance;
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

  CashBox copyWith({double? balance, CashBoxStatus? status, int? version, DateTime? updatedAt, LocalSyncStatus? syncStatus, bool? isDirty}) =>
      CashBox(
        id: id,
        tenantId: tenantId,
        name: name,
        storeId: storeId,
        status: status ?? this.status,
        currencyCode: currencyCode,
        balance: balance ?? this.balance,
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
        'store_id': storeId,
        'status': status.value,
        'currency_code': currencyCode,
        'balance': balance,
      };

  static CashBox fromPayload(Map<String, dynamic> json, LocalRecord record) => CashBox(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        storeId: json['store_id'] as String? ?? record.storeId,
        status: CashBoxStatus.fromValue(json['status'] as String?),
        currencyCode: json['currency_code'] as String? ?? 'USD',
        balance: (json['balance'] as num?)?.toDouble() ?? 0,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, balance, status, version];
}

class Bank extends Equatable with TreasuryEntity {
  const Bank({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.code,
    this.swiftCode,
    this.country,
    this.isActive = true,
    this.deletedAt,
  });

  static const entityTypeName = 'bank';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? code;
  final String? swiftCode;
  final String? country;
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
        ...basePayload(),
        'name': name,
        'code': code,
        'swift_code': swiftCode,
        'country': country,
        'is_active': isActive,
      };

  static Bank fromPayload(Map<String, dynamic> json, LocalRecord record) => Bank(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        code: json['code'] as String?,
        swiftCode: json['swift_code'] as String?,
        country: json['country'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, version];
}

class BankAccount extends Equatable with TreasuryEntity {
  const BankAccount({
    required this.id,
    required this.tenantId,
    required this.bankId,
    required this.accountNumber,
    required this.balance,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.accountName,
    this.iban,
    this.currencyCode = 'USD',
    this.status = BankAccountStatus.active,
    this.interestRate = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'bank_account';

  @override
  final String id;
  @override
  final String tenantId;
  final String bankId;
  final String accountNumber;
  final String? accountName;
  final String? iban;
  final String currencyCode;
  final double balance;
  final BankAccountStatus status;
  final double interestRate;
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

  BankAccount copyWith({double? balance, BankAccountStatus? status, int? version, DateTime? updatedAt, LocalSyncStatus? syncStatus, bool? isDirty}) =>
      BankAccount(
        id: id,
        tenantId: tenantId,
        bankId: bankId,
        accountNumber: accountNumber,
        accountName: accountName,
        iban: iban,
        currencyCode: currencyCode,
        balance: balance ?? this.balance,
        status: status ?? this.status,
        interestRate: interestRate,
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
        'bank_id': bankId,
        'account_number': accountNumber,
        'account_name': accountName,
        'iban': iban,
        'currency_code': currencyCode,
        'balance': balance,
        'status': status.value,
        'interest_rate': interestRate,
      };

  static BankAccount fromPayload(Map<String, dynamic> json, LocalRecord record) => BankAccount(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        bankId: json['bank_id'] as String? ?? '',
        accountNumber: json['account_number'] as String? ?? record.searchName ?? '',
        accountName: json['account_name'] as String?,
        iban: json['iban'] as String?,
        currencyCode: json['currency_code'] as String? ?? 'USD',
        balance: (json['balance'] as num?)?.toDouble() ?? 0,
        status: BankAccountStatus.fromValue(json['status'] as String?),
        interestRate: (json['interest_rate'] as num?)?.toDouble() ?? 0,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, bankId, accountNumber, balance, version];
}

class PettyCash extends Equatable with TreasuryEntity {
  const PettyCash({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.balance,
    required this.custodianId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.limit = 0,
    this.currencyCode = 'USD',
    this.deletedAt,
  });

  static const entityTypeName = 'petty_cash';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String custodianId;
  final double balance;
  final double limit;
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
        'name': name,
        'custodian_id': custodianId,
        'balance': balance,
        'limit_amount': limit,
        'currency_code': currencyCode,
      };

  static PettyCash fromPayload(Map<String, dynamic> json, LocalRecord record) => PettyCash(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        custodianId: json['custodian_id'] as String? ?? '',
        balance: (json['balance'] as num?)?.toDouble() ?? 0,
        limit: (json['limit_amount'] as num?)?.toDouble() ?? 0,
        currencyCode: json['currency_code'] as String? ?? 'USD',
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, balance, version];
}

class TreasurySettings extends Equatable with TreasuryEntity {
  const TreasurySettings({
    required this.id,
    required this.tenantId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.baseCurrency = 'USD',
    this.expenseApprovalThreshold = 500,
    this.autoReconcile = false,
    this.deletedAt,
  });

  static const entityTypeName = 'treasury_settings';

  @override
  final String id;
  @override
  final String tenantId;
  final String baseCurrency;
  final double expenseApprovalThreshold;
  final bool autoReconcile;
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
        'base_currency': baseCurrency,
        'expense_approval_threshold': expenseApprovalThreshold,
        'auto_reconcile': autoReconcile,
      };

  static TreasurySettings fromPayload(Map<String, dynamic> json, LocalRecord record) => TreasurySettings(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        baseCurrency: json['base_currency'] as String? ?? 'USD',
        expenseApprovalThreshold: (json['expense_approval_threshold'] as num?)?.toDouble() ?? 500,
        autoReconcile: json['auto_reconcile'] as bool? ?? false,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, baseCurrency, version];
}
