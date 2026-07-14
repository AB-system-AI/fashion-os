import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/accounts.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/enums/treasury_enums.dart';

class PaymentVoucher extends Equatable with TreasuryEntity {
  const PaymentVoucher({
    required this.id,
    required this.tenantId,
    required this.voucherNumber,
    required this.payeeName,
    required this.amount,
    required this.accountId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = VoucherStatus.draft,
    this.currencyCode = 'USD',
    this.reference,
    this.notes,
    this.deletedAt,
  });

  static const entityTypeName = 'payment_voucher';

  @override
  final String id;
  @override
  final String tenantId;
  final String voucherNumber;
  final String payeeName;
  final double amount;
  final String accountId;
  final VoucherStatus status;
  final String currencyCode;
  final String? reference;
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

  @override
  String get entityType => entityTypeName;

  PaymentVoucher copyWith({VoucherStatus? status, int? version, DateTime? updatedAt, LocalSyncStatus? syncStatus, bool? isDirty}) =>
      PaymentVoucher(
        id: id,
        tenantId: tenantId,
        voucherNumber: voucherNumber,
        payeeName: payeeName,
        amount: amount,
        accountId: accountId,
        status: status ?? this.status,
        currencyCode: currencyCode,
        reference: reference,
        notes: notes,
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
        'voucher_number': voucherNumber,
        'payee_name': payeeName,
        'amount': amount,
        'account_id': accountId,
        'status': status.value,
        'currency_code': currencyCode,
        'reference': reference,
        'notes': notes,
      };

  static PaymentVoucher fromPayload(Map<String, dynamic> json, LocalRecord record) => PaymentVoucher(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        voucherNumber: json['voucher_number'] as String? ?? record.searchName ?? '',
        payeeName: json['payee_name'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        accountId: json['account_id'] as String? ?? '',
        status: VoucherStatus.fromValue(json['status'] as String?),
        currencyCode: json['currency_code'] as String? ?? 'USD',
        reference: json['reference'] as String?,
        notes: json['notes'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, voucherNumber, status, amount, version];
}

class ReceiptVoucher extends Equatable with TreasuryEntity {
  const ReceiptVoucher({
    required this.id,
    required this.tenantId,
    required this.voucherNumber,
    required this.payerName,
    required this.amount,
    required this.accountId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = VoucherStatus.draft,
    this.currencyCode = 'USD',
    this.reference,
    this.notes,
    this.deletedAt,
  });

  static const entityTypeName = 'receipt_voucher';

  @override
  final String id;
  @override
  final String tenantId;
  final String voucherNumber;
  final String payerName;
  final double amount;
  final String accountId;
  final VoucherStatus status;
  final String currencyCode;
  final String? reference;
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

  @override
  String get entityType => entityTypeName;

  ReceiptVoucher copyWith({VoucherStatus? status, int? version, DateTime? updatedAt, LocalSyncStatus? syncStatus, bool? isDirty}) =>
      ReceiptVoucher(
        id: id,
        tenantId: tenantId,
        voucherNumber: voucherNumber,
        payerName: payerName,
        amount: amount,
        accountId: accountId,
        status: status ?? this.status,
        currencyCode: currencyCode,
        reference: reference,
        notes: notes,
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
        'voucher_number': voucherNumber,
        'payer_name': payerName,
        'amount': amount,
        'account_id': accountId,
        'status': status.value,
        'currency_code': currencyCode,
        'reference': reference,
        'notes': notes,
      };

  static ReceiptVoucher fromPayload(Map<String, dynamic> json, LocalRecord record) => ReceiptVoucher(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        voucherNumber: json['voucher_number'] as String? ?? record.searchName ?? '',
        payerName: json['payer_name'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        accountId: json['account_id'] as String? ?? '',
        status: VoucherStatus.fromValue(json['status'] as String?),
        currencyCode: json['currency_code'] as String? ?? 'USD',
        reference: json['reference'] as String?,
        notes: json['notes'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, voucherNumber, status, amount, version];
}
