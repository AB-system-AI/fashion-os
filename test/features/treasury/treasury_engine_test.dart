import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/treasury/treasury_engine.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/enums/treasury_enums.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/value_objects/treasury_value_objects.dart';

void main() {
  late TreasuryEngine engine;

  setUp(() => engine = TreasuryEngine());

  test('validateTransfer rejects insufficient balance', () {
    final result = engine.validateTransfer(
      input: const TransferInput(fromAccountId: 'a1', toAccountId: 'a2', amount: 100),
      fromBalance: 50,
    );
    expect(result.isValid, isFalse);
  });

  test('canTransitionTransfer allows draft to pending', () {
    expect(engine.canTransitionTransfer(TransferStatus.draft, TransferStatus.pending), isTrue);
  });

  test('canTransitionCheque allows issued to deposited', () {
    expect(engine.canTransitionCheque(ChequeStatus.issued, ChequeStatus.deposited).allowed, isTrue);
  });

  test('reconcile detects balanced statement', () {
    final result = engine.reconcile(bookBalance: 1000, statementBalance: 1000, lines: const []);
    expect(result.isBalanced, isTrue);
    expect(result.variance, 0);
  });

  test('buildCashForecast projects balance', () {
    final points = engine.buildCashForecast(
      openingBalance: 1000,
      periods: [(date: DateTime(2026, 1, 1), inflow: 500, outflow: 200)],
    );
    expect(points.first.projectedBalance, 1300);
  });

  test('calculateLiquidity sums accounts', () {
    final snap = engine.calculateLiquidity(cashBalance: 100, bankBalance: 500, pettyCashBalance: 50);
    expect(snap.netLiquidity, 650);
  });

  test('calculateInterest computes daily accrual', () {
    final calc = engine.calculateInterest(principal: 10000, annualRate: 0.05, days: 30);
    expect(calc.interestAmount, greaterThan(0));
  });

  test('calculateKpis returns liquidity ratio', () {
    final kpis = engine.calculateKpis(
      cashOnHand: 1000,
      bankBalance: 5000,
      pendingPayments: 500,
      pendingReceipts: 200,
      unclearedCheques: 100,
      currentLiabilities: 2000,
    );
    expect(kpis.liquidityRatio, greaterThan(0));
  });
}
