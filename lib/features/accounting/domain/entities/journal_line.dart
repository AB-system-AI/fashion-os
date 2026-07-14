import 'package:equatable/equatable.dart';

class JournalLine extends Equatable {
  const JournalLine({
    required this.id,
    required this.accountId,
    required this.accountCode,
    this.debit = 0,
    this.credit = 0,
    this.description,
    this.costCenterId,
    this.taxCodeId,
    this.currency = 'USD',
    this.exchangeRate = 1,
  });

  final String id;
  final String accountId;
  final String accountCode;
  final double debit;
  final double credit;
  final String? description;
  final String? costCenterId;
  final String? taxCodeId;
  final String currency;
  final double exchangeRate;

  Map<String, dynamic> toJson() => {
        'id': id,
        'account_id': accountId,
        'account_code': accountCode,
        'debit': debit,
        'credit': credit,
        'description': description,
        'cost_center_id': costCenterId,
        'tax_code_id': taxCodeId,
        'currency': currency,
        'exchange_rate': exchangeRate,
      };

  factory JournalLine.fromJson(Map<String, dynamic> json) {
    return JournalLine(
      id: json['id'] as String? ?? '',
      accountId: json['account_id'] as String? ?? '',
      accountCode: json['account_code'] as String? ?? '',
      debit: (json['debit'] as num?)?.toDouble() ?? 0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      costCenterId: json['cost_center_id'] as String?,
      taxCodeId: json['tax_code_id'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      exchangeRate: (json['exchange_rate'] as num?)?.toDouble() ?? 1,
    );
  }

  @override
  List<Object?> get props => [id, accountId, debit, credit];
}
