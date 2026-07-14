import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/domain/entities/loyalty_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/loyalty_engine.dart';

void main() {
  late LoyaltyEngine engine;

  setUp(() {
    engine = LoyaltyEngine();
  });

  const program = LoyaltyProgram(
    id: 'p1',
    name: 'Default',
    pointsPerCurrencyUnit: 1,
    currencyCode: 'USD',
    tiers: [
      LoyaltyTierConfig(tier: LoyaltyTier.standard, minPoints: 0, earnMultiplier: 1),
      LoyaltyTierConfig(tier: LoyaltyTier.silver, minPoints: 100, earnMultiplier: 1.5),
    ],
    birthdayBonusPoints: 50,
  );

  test('expire points reduces balance', () {
    const account = LoyaltyAccount(
      customerId: 'c1',
      programId: 'p1',
      pointsBalance: 200,
      tier: LoyaltyTier.standard,
    );
    final result = engine.process(
      LoyaltyTransactionRequest(
        account: account,
        type: LoyaltyTransactionType.expire,
        program: program,
        pointsToRedeem: 50,
      ),
    );
    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull!.account.pointsBalance, 150);
  });

  test('adjust points supports positive delta', () {
    const account = LoyaltyAccount(
      customerId: 'c1',
      programId: 'p1',
      pointsBalance: 100,
      tier: LoyaltyTier.standard,
    );
    final result = engine.process(
      LoyaltyTransactionRequest(
        account: account,
        type: LoyaltyTransactionType.adjust,
        program: program,
        pointsToRedeem: 25,
      ),
    );
    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull!.account.pointsBalance, 125);
  });
}
