import 'package:fashion_pos_enterprise/core/business/domain/entities/loyalty_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/business/engines/loyalty_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoyaltyEngine', () {
    late LoyaltyEngine engine;
    late LoyaltyProgram program;
    late LoyaltyAccount account;

    setUp(() {
      engine = LoyaltyEngine();
      program = const LoyaltyProgram(
        id: 'lp1',
        name: 'Fashion Rewards',
        pointsPerCurrencyUnit: 1,
        currencyCode: 'USD',
        tiers: [
          LoyaltyTierConfig(tier: LoyaltyTier.standard, minPoints: 0, earnMultiplier: 1),
          LoyaltyTierConfig(tier: LoyaltyTier.silver, minPoints: 500, earnMultiplier: 1.25),
          LoyaltyTierConfig(tier: LoyaltyTier.gold, minPoints: 1000, earnMultiplier: 1.5),
          LoyaltyTierConfig(tier: LoyaltyTier.vip, minPoints: 5000, earnMultiplier: 2),
        ],
        birthdayBonusPoints: 100,
      );
      account = const LoyaltyAccount(
        customerId: 'c1',
        programId: 'lp1',
        pointsBalance: 0,
        tier: LoyaltyTier.standard,
      );
    });

    test('earns points on sale', () {
      final result = engine.process(
        LoyaltyTransactionRequest(
          account: account,
          type: LoyaltyTransactionType.earn,
          program: program,
          saleAmount: Money.fromMajor(100),
        ),
      );
      final data = (result as Success<LoyaltyTransactionResult>).data;
      expect(data.pointsDelta, 100);
      expect(data.account.pointsBalance, 100);
    });

    test('auto upgrades tier when lifetime points threshold met', () {
      final silverAccount = account.copyWith(lifetimePoints: 450, pointsBalance: 450);
      final result = engine.process(
        LoyaltyTransactionRequest(
          account: silverAccount,
          type: LoyaltyTransactionType.earn,
          program: program,
          saleAmount: Money.fromMajor(100),
        ),
      );
      final data = (result as Success<LoyaltyTransactionResult>).data;
      expect(data.tierChanged, isTrue);
      expect(data.account.tier, LoyaltyTier.silver);
    });

    test('redeems points for discount', () {
      final funded = account.copyWith(pointsBalance: 500);
      final result = engine.process(
        LoyaltyTransactionRequest(
          account: funded,
          type: LoyaltyTransactionType.redeem,
          program: program,
          pointsToRedeem: 200,
        ),
      );
      final data = (result as Success<LoyaltyTransactionResult>).data;
      expect(data.pointsDelta, -200);
      expect(data.account.pointsBalance, 300);
      expect(data.discountAmount!.majorUnits, 2);
    });

    test('rejects insufficient points', () {
      final result = engine.process(
        LoyaltyTransactionRequest(
          account: account,
          type: LoyaltyTransactionType.redeem,
          program: program,
          pointsToRedeem: 100,
        ),
      );
      expect(result.isFailure, isTrue);
    });
  });
}
