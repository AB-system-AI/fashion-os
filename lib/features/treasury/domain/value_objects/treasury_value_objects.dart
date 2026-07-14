import 'package:equatable/equatable.dart';

class TransferInput extends Equatable {
  const TransferInput({
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    this.currencyCode = 'USD',
    this.exchangeRate = 1,
    this.notes,
  });

  final String fromAccountId;
  final String toAccountId;
  final double amount;
  final String currencyCode;
  final double exchangeRate;
  final String? notes;

  @override
  List<Object?> get props => [fromAccountId, toAccountId, amount, currencyCode];
}

class PaymentInput extends Equatable {
  const PaymentInput({
    required this.payeeName,
    required this.amount,
    required this.accountId,
    this.currencyCode = 'USD',
    this.reference,
    this.notes,
  });

  final String payeeName;
  final double amount;
  final String accountId;
  final String currencyCode;
  final String? reference;
  final String? notes;

  @override
  List<Object?> get props => [payeeName, amount, accountId];
}

class ReceiptInput extends Equatable {
  const ReceiptInput({
    required this.payerName,
    required this.amount,
    required this.accountId,
    this.currencyCode = 'USD',
    this.reference,
    this.notes,
  });

  final String payerName;
  final double amount;
  final String accountId;
  final String currencyCode;
  final String? reference;
  final String? notes;

  @override
  List<Object?> get props => [payerName, amount, accountId];
}

class ExpenseInput extends Equatable {
  const ExpenseInput({
    required this.description,
    required this.amount,
    required this.category,
    this.departmentId,
    this.attachments = const [],
  });

  final String description;
  final double amount;
  final String category;
  final String? departmentId;
  final List<String> attachments;

  @override
  List<Object?> get props => [description, amount, category];
}

class ForecastPoint extends Equatable {
  const ForecastPoint({required this.date, required this.projectedBalance, this.inflows = 0, this.outflows = 0});

  final DateTime date;
  final double projectedBalance;
  final double inflows;
  final double outflows;

  @override
  List<Object?> get props => [date, projectedBalance];
}

class LiquiditySnapshot extends Equatable {
  const LiquiditySnapshot({
    required this.totalCash,
    required this.totalBank,
    required this.totalPettyCash,
    required this.netLiquidity,
    required this.currencyCode,
  });

  final double totalCash;
  final double totalBank;
  final double totalPettyCash;
  final double netLiquidity;
  final String currencyCode;

  @override
  List<Object?> get props => [totalCash, totalBank, netLiquidity];
}

class TreasuryKpis extends Equatable {
  const TreasuryKpis({
    required this.cashOnHand,
    required this.bankBalance,
    required this.pendingPayments,
    required this.pendingReceipts,
    required this.unclearedCheques,
    required this.liquidityRatio,
  });

  final double cashOnHand;
  final double bankBalance;
  final double pendingPayments;
  final double pendingReceipts;
  final double unclearedCheques;
  final double liquidityRatio;

  @override
  List<Object?> get props => [cashOnHand, bankBalance, liquidityRatio];
}

class ReconciliationLineInput extends Equatable {
  const ReconciliationLineInput({
    required this.statementDate,
    required this.statementAmount,
    required this.bookAmount,
    this.reference,
  });

  final DateTime statementDate;
  final double statementAmount;
  final double bookAmount;
  final String? reference;

  @override
  List<Object?> get props => [statementDate, statementAmount, bookAmount];
}
