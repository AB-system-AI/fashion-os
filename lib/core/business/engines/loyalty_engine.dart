import 'package:fashion_pos_enterprise/core/business/domain/entities/loyalty_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';

/// Manages loyalty points, tiers, birthday rewards, and auto upgrade/downgrade.
class LoyaltyEngine {
  LoyaltyEngine({DomainEventBus? eventBus}) : _eventBus = eventBus;

  final DomainEventBus? _eventBus;

  Result<LoyaltyTransactionResult> process(LoyaltyTransactionRequest request) {
    if (!request.program.isActive) {
      return const Error(ValidationFailure(message: 'Loyalty program is inactive', code: 'loyalty_inactive'));
    }

    return switch (request.type) {
      LoyaltyTransactionType.earn => _earn(request),
      LoyaltyTransactionType.redeem => _redeem(request),
      LoyaltyTransactionType.birthdayBonus => _birthdayBonus(request),
      LoyaltyTransactionType.adjust => _adjust(request),
      LoyaltyTransactionType.expire => _expire(request),
      LoyaltyTransactionType.tierUpgrade || LoyaltyTransactionType.tierDowngrade => _evaluateTier(request),
      _ => const Error(ValidationFailure(message: 'Unsupported loyalty transaction type', code: 'loyalty_invalid')),
    };
  }

  Result<LoyaltyTransactionResult> applyCampaignBonus({
    required LoyaltyTransactionRequest request,
    required int bonusPoints,
  }) {
    if (bonusPoints <= 0) {
      return const Error(ValidationFailure(message: 'Bonus points must be positive', code: 'loyalty_invalid'));
    }
    final account = request.account.copyWith(
      pointsBalance: request.account.pointsBalance + bonusPoints,
      lifetimePoints: request.account.lifetimePoints + bonusPoints,
      lastActivityAt: request.evaluatedAt ?? DateTime.now().toUtc(),
    );
    return Success(
      LoyaltyTransactionResult(
        account: account,
        pointsDelta: bonusPoints,
        type: LoyaltyTransactionType.earn,
      ),
    );
  }

  Result<LoyaltyTransactionResult> _adjust(LoyaltyTransactionRequest request) {
    final delta = request.pointsToRedeem ?? 0;
    if (delta == 0) {
      return const Error(ValidationFailure(message: 'Adjustment points cannot be zero', code: 'loyalty_invalid'));
    }
    final nextBalance = request.account.pointsBalance + delta;
    if (nextBalance < 0) {
      return const Error(ValidationFailure(message: 'Adjustment would result in negative balance', code: 'loyalty_insufficient'));
    }
    final account = request.account.copyWith(
      pointsBalance: nextBalance,
      lifetimePoints: delta > 0 ? request.account.lifetimePoints + delta : request.account.lifetimePoints,
      lastActivityAt: request.evaluatedAt ?? DateTime.now().toUtc(),
    );
    return Success(
      LoyaltyTransactionResult(account: account, pointsDelta: delta, type: LoyaltyTransactionType.adjust),
    );
  }

  Result<LoyaltyTransactionResult> _expire(LoyaltyTransactionRequest request) {
    final points = request.pointsToRedeem;
    if (points == null || points <= 0) {
      return const Error(ValidationFailure(message: 'Expire points must be positive', code: 'loyalty_invalid'));
    }
    if (points > request.account.pointsBalance) {
      return const Error(ValidationFailure(message: 'Cannot expire more than balance', code: 'loyalty_insufficient'));
    }
    final account = request.account.copyWith(
      pointsBalance: request.account.pointsBalance - points,
      lastActivityAt: request.evaluatedAt ?? DateTime.now().toUtc(),
    );
    return Success(
      LoyaltyTransactionResult(account: account, pointsDelta: -points, type: LoyaltyTransactionType.expire),
    );
  }

  Result<LoyaltyTransactionResult> _earn(LoyaltyTransactionRequest request) {
    final sale = request.saleAmount;
    if (sale == null || sale.isZero) {
      return const Error(ValidationFailure(message: 'Sale amount required to earn points', code: 'loyalty_invalid'));
    }

    final tierConfig = _tierConfig(request.program, request.account.tier);
    final basePoints = (sale.majorUnits * request.program.pointsPerCurrencyUnit).floor();
    final points = (basePoints * tierConfig.earnMultiplier).round();

    var account = request.account.copyWith(
      pointsBalance: request.account.pointsBalance + points,
      lifetimePoints: request.account.lifetimePoints + points,
      lastActivityAt: request.evaluatedAt ?? DateTime.now().toUtc(),
    );

    final tierResult = _autoTierChange(request.program, account);
    account = tierResult.account;

    return Success(
      LoyaltyTransactionResult(
        account: account,
        pointsDelta: points,
        type: LoyaltyTransactionType.earn,
        tierChanged: tierResult.tierChanged,
        previousTier: tierResult.previousTier,
      ),
    );
  }

  Result<LoyaltyTransactionResult> _redeem(LoyaltyTransactionRequest request) {
    final points = request.pointsToRedeem;
    if (points == null || points <= 0) {
      return const Error(ValidationFailure(message: 'Points to redeem must be positive', code: 'loyalty_invalid'));
    }
    if (points > request.account.pointsBalance) {
      return const Error(ValidationFailure(message: 'Insufficient loyalty points', code: 'loyalty_insufficient'));
    }

    final discountAmount = Money.fromMajor(points / 100.0);
    final account = request.account.copyWith(
      pointsBalance: request.account.pointsBalance - points,
      lastActivityAt: request.evaluatedAt ?? DateTime.now().toUtc(),
    );

    return Success(
      LoyaltyTransactionResult(
        account: account,
        pointsDelta: -points,
        type: LoyaltyTransactionType.redeem,
        discountAmount: discountAmount,
      ),
    );
  }

  Result<LoyaltyTransactionResult> _birthdayBonus(LoyaltyTransactionRequest request) {
    final dob = request.account.dateOfBirth;
    final at = request.evaluatedAt ?? DateTime.now().toUtc();
    if (dob == null || dob.month != at.month || dob.day != at.day) {
      return const Error(ValidationFailure(message: 'Birthday bonus not applicable today', code: 'loyalty_birthday'));
    }

    final bonus = request.program.birthdayBonusPoints;
    final account = request.account.copyWith(
      pointsBalance: request.account.pointsBalance + bonus,
      lifetimePoints: request.account.lifetimePoints + bonus,
    );

    return Success(
      LoyaltyTransactionResult(
        account: account,
        pointsDelta: bonus,
        type: LoyaltyTransactionType.birthdayBonus,
      ),
    );
  }

  Result<LoyaltyTransactionResult> _evaluateTier(LoyaltyTransactionRequest request) {
    final result = _autoTierChange(request.program, request.account);
    return Success(
      LoyaltyTransactionResult(
        account: result.account,
        pointsDelta: 0,
        type: request.type,
        tierChanged: result.tierChanged,
        previousTier: result.previousTier,
      ),
    );
  }

  _TierChangeResult _autoTierChange(LoyaltyProgram program, LoyaltyAccount account) {
    final sorted = List<LoyaltyTierConfig>.from(program.tiers)
      ..sort((a, b) => b.minPoints.compareTo(a.minPoints));

    LoyaltyTier newTier = LoyaltyTier.standard;
    for (final config in sorted) {
      if (account.lifetimePoints >= config.minPoints) {
        newTier = config.tier;
        break;
      }
    }

    if (newTier == account.tier) {
      return _TierChangeResult(account: account, tierChanged: false);
    }

    final updated = account.copyWith(tier: newTier);
    _eventBus?.publish(
      LoyaltyTierChangedEvent(
        eventId: '${account.customerId}_tier',
        occurredAt: DateTime.now().toUtc(),
        customerId: account.customerId,
        previousTier: account.tier,
        newTier: newTier,
      ),
    );

    return _TierChangeResult(
      account: updated,
      tierChanged: true,
      previousTier: account.tier,
    );
  }

  LoyaltyTierConfig _tierConfig(LoyaltyProgram program, LoyaltyTier tier) {
    return program.tiers.firstWhere(
      (t) => t.tier == tier,
      orElse: () => const LoyaltyTierConfig(tier: LoyaltyTier.standard, minPoints: 0, earnMultiplier: 1),
    );
  }
}

class _TierChangeResult {
  const _TierChangeResult({required this.account, this.tierChanged = false, this.previousTier});
  final LoyaltyAccount account;
  final bool tierChanged;
  final LoyaltyTier? previousTier;
}
