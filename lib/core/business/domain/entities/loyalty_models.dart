import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';

/// Loyalty program configuration.
class LoyaltyProgram extends Equatable {
  const LoyaltyProgram({
    required this.id,
    required this.name,
    required this.pointsPerCurrencyUnit,
    required this.currencyCode,
    this.tiers = const [],
    this.birthdayBonusPoints = 0,
    this.isActive = true,
  });

  final String id;
  final String name;
  final double pointsPerCurrencyUnit;
  final String currencyCode;
  final List<LoyaltyTierConfig> tiers;
  final int birthdayBonusPoints;
  final bool isActive;

  @override
  List<Object?> get props => [id, pointsPerCurrencyUnit];
}

/// Tier threshold configuration.
class LoyaltyTierConfig extends Equatable {
  const LoyaltyTierConfig({
    required this.tier,
    required this.minPoints,
    required this.earnMultiplier,
    this.discountPercent = 0,
  });

  final LoyaltyTier tier;
  final int minPoints;
  final double earnMultiplier;
  final double discountPercent;

  @override
  List<Object?> get props => [tier, minPoints];
}

/// Customer loyalty account state.
class LoyaltyAccount extends Equatable {
  const LoyaltyAccount({
    required this.customerId,
    required this.programId,
    required this.pointsBalance,
    required this.tier,
    this.lifetimePoints = 0,
    this.lastActivityAt,
    this.dateOfBirth,
  });

  final String customerId;
  final String programId;
  final int pointsBalance;
  final LoyaltyTier tier;
  final int lifetimePoints;
  final DateTime? lastActivityAt;
  final DateTime? dateOfBirth;

  LoyaltyAccount copyWith({
    int? pointsBalance,
    LoyaltyTier? tier,
    int? lifetimePoints,
    DateTime? lastActivityAt,
  }) {
    return LoyaltyAccount(
      customerId: customerId,
      programId: programId,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      tier: tier ?? this.tier,
      lifetimePoints: lifetimePoints ?? this.lifetimePoints,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      dateOfBirth: dateOfBirth,
    );
  }

  @override
  List<Object?> get props => [customerId, pointsBalance, tier];
}

/// Loyalty earn/redeem request.
class LoyaltyTransactionRequest extends Equatable {
  const LoyaltyTransactionRequest({
    required this.account,
    required this.type,
    required this.program,
    this.saleAmount,
    this.pointsToRedeem,
    this.evaluatedAt,
  });

  final LoyaltyAccount account;
  final LoyaltyTransactionType type;
  final LoyaltyProgram program;
  final Money? saleAmount;
  final int? pointsToRedeem;
  final DateTime? evaluatedAt;

  @override
  List<Object?> get props => [account.customerId, type];
}

/// Loyalty transaction result.
class LoyaltyTransactionResult extends Equatable {
  const LoyaltyTransactionResult({
    required this.account,
    required this.pointsDelta,
    required this.type,
    this.tierChanged = false,
    this.previousTier,
    this.discountAmount,
  });

  final LoyaltyAccount account;
  final int pointsDelta;
  final LoyaltyTransactionType type;
  final bool tierChanged;
  final LoyaltyTier? previousTier;
  final Money? discountAmount;

  @override
  List<Object?> get props => [account, pointsDelta, type, tierChanged];
}
