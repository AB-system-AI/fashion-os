import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/enums/treasury_enums.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/value_objects/treasury_value_objects.dart';
import 'package:uuid/uuid.dart';

class TransferValidationResult {
  const TransferValidationResult({required this.isValid, this.errors = const []});

  final bool isValid;
  final List<String> errors;
}

class ChequeTransitionResult {
  const ChequeTransitionResult({required this.allowed, this.reason});

  final bool allowed;
  final String? reason;
}

class ReconciliationResult {
  const ReconciliationResult({
    required this.isBalanced,
    required this.variance,
    required this.matchedCount,
    required this.unmatchedCount,
  });

  final bool isBalanced;
  final double variance;
  final int matchedCount;
  final int unmatchedCount;
}

class InterestCalculation {
  const InterestCalculation({
    required this.principal,
    required this.rate,
    required this.days,
    required this.interestAmount,
  });

  final double principal;
  final double rate;
  final int days;
  final double interestAmount;
}

/// Pure treasury rules: cash, bank, transfers, cheques, forecasting, reconciliation, KPIs.
class TreasuryEngine {
  TreasuryEngine({DomainEventBus? eventBus, Uuid? uuid})
      : _eventBus = eventBus,
        _uuid = uuid ?? const Uuid();

  final DomainEventBus? _eventBus;
  final Uuid _uuid;

  double convertAmount({required double amount, required double exchangeRate}) =>
      _round(amount * exchangeRate);

  TransferValidationResult validateTransfer({
    required TransferInput input,
    required double fromBalance,
    bool allowSameAccount = false,
  }) {
    final errors = <String>[];
    if (input.amount <= 0) errors.add('Transfer amount must be positive');
    if (input.fromAccountId == input.toAccountId && !allowSameAccount) {
      errors.add('Source and destination accounts must differ');
    }
    if (fromBalance < input.amount) errors.add('Insufficient balance in source account');
    if (input.exchangeRate <= 0) errors.add('Exchange rate must be positive');
    return TransferValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  bool canTransitionTransfer(TransferStatus from, TransferStatus to) {
    const allowed = {
      TransferStatus.draft: {TransferStatus.pending, TransferStatus.cancelled},
      TransferStatus.pending: {TransferStatus.completed, TransferStatus.failed, TransferStatus.cancelled},
      TransferStatus.completed: <TransferStatus>{},
      TransferStatus.cancelled: <TransferStatus>{},
      TransferStatus.failed: {TransferStatus.pending, TransferStatus.cancelled},
    };
    return allowed[from]?.contains(to) ?? false;
  }

  ChequeTransitionResult canTransitionCheque(ChequeStatus from, ChequeStatus to) {
    const allowed = {
      ChequeStatus.issued: {ChequeStatus.deposited, ChequeStatus.cancelled},
      ChequeStatus.deposited: {ChequeStatus.cleared, ChequeStatus.bounced, ChequeStatus.stale},
      ChequeStatus.cleared: <ChequeStatus>{},
      ChequeStatus.bounced: {ChequeStatus.issued},
      ChequeStatus.cancelled: <ChequeStatus>{},
      ChequeStatus.stale: {ChequeStatus.cancelled},
    };
    if (allowed[from]?.contains(to) ?? false) {
      return const ChequeTransitionResult(allowed: true);
    }
    return ChequeTransitionResult(allowed: false, reason: 'Cannot transition cheque from $from to $to');
  }

  bool requiresExpenseApproval({required double amount, required double threshold}) => amount > threshold;

  ReconciliationResult reconcile({
    required double bookBalance,
    required double statementBalance,
    required List<ReconciliationLineInput> lines,
    double tolerance = 0.01,
  }) {
    var matched = 0;
    var unmatched = 0;
    for (final line in lines) {
      if ((line.statementAmount - line.bookAmount).abs() <= tolerance) {
        matched++;
      } else {
        unmatched++;
      }
    }
    final variance = _round(statementBalance - bookBalance);
    return ReconciliationResult(
      isBalanced: variance.abs() <= tolerance,
      variance: variance,
      matchedCount: matched,
      unmatchedCount: unmatched,
    );
  }

  List<ForecastPoint> buildCashForecast({
    required double openingBalance,
    required List<({DateTime date, double inflow, double outflow})> periods,
  }) {
    var balance = openingBalance;
    return periods.map((p) {
      balance = _round(balance + p.inflow - p.outflow);
      return ForecastPoint(
        date: p.date,
        projectedBalance: balance,
        inflows: p.inflow,
        outflows: p.outflow,
      );
    }).toList();
  }

  LiquiditySnapshot calculateLiquidity({
    required double cashBalance,
    required double bankBalance,
    required double pettyCashBalance,
    String currencyCode = 'USD',
  }) {
    final total = _round(cashBalance + bankBalance + pettyCashBalance);
    return LiquiditySnapshot(
      totalCash: _round(cashBalance),
      totalBank: _round(bankBalance),
      totalPettyCash: _round(pettyCashBalance),
      netLiquidity: total,
      currencyCode: currencyCode,
    );
  }

  TreasuryKpis calculateKpis({
    required double cashOnHand,
    required double bankBalance,
    required double pendingPayments,
    required double pendingReceipts,
    required double unclearedCheques,
    required double currentLiabilities,
  }) {
    final totalLiquid = cashOnHand + bankBalance - unclearedCheques;
    final ratio = currentLiabilities > 0 ? totalLiquid / currentLiabilities : 1.0;
    return TreasuryKpis(
      cashOnHand: _round(cashOnHand),
      bankBalance: _round(bankBalance),
      pendingPayments: _round(pendingPayments),
      pendingReceipts: _round(pendingReceipts),
      unclearedCheques: _round(unclearedCheques),
      liquidityRatio: _round(ratio),
    );
  }

  InterestCalculation calculateInterest({
    required double principal,
    required double annualRate,
    required int days,
    int dayCountBasis = 365,
  }) {
    final interest = principal * annualRate * days / dayCountBasis;
    return InterestCalculation(
      principal: principal,
      rate: annualRate,
      days: days,
      interestAmount: _round(interest),
    );
  }

  bool canTransitionExpense(ExpenseRequestStatus from, ExpenseRequestStatus to) {
    const allowed = {
      ExpenseRequestStatus.draft: {ExpenseRequestStatus.submitted, ExpenseRequestStatus.cancelled},
      ExpenseRequestStatus.submitted: {ExpenseRequestStatus.approved, ExpenseRequestStatus.rejected, ExpenseRequestStatus.cancelled},
      ExpenseRequestStatus.approved: {ExpenseRequestStatus.paid, ExpenseRequestStatus.cancelled},
      ExpenseRequestStatus.rejected: <ExpenseRequestStatus>{},
      ExpenseRequestStatus.paid: <ExpenseRequestStatus>{},
      ExpenseRequestStatus.cancelled: <ExpenseRequestStatus>{},
    };
    return allowed[from]?.contains(to) ?? false;
  }

  String generateId() => _uuid.v4();

  double _round(double v) => double.parse(v.toStringAsFixed(4));
}
