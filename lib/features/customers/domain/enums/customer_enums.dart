/// Customer gender values aligned with DB constraint.
enum CustomerGender {
  male('male'),
  female('female'),
  other('other'),
  preferNotToSay('prefer_not_to_say');

  const CustomerGender(this.value);
  final String value;

  static CustomerGender? fromValue(String? raw) {
    if (raw == null) return null;
    return CustomerGender.values.firstWhere(
      (e) => e.value == raw || e.name == raw,
      orElse: () => CustomerGender.other,
    );
  }
}

enum WalletTransactionType {
  deposit('DEPOSIT'),
  withdraw('WITHDRAW'),
  refund('REFUND'),
  purchasePayment('PURCHASE_PAYMENT'),
  adjustment('ADJUSTMENT');

  const WalletTransactionType(this.value);
  final String value;

  static WalletTransactionType fromValue(String? raw) {
    return WalletTransactionType.values.firstWhere(
      (e) => e.value == raw || e.name == raw,
      orElse: () => WalletTransactionType.adjustment,
    );
  }
}

enum CreditTransactionType {
  charge('CHARGE'),
  payment('PAYMENT'),
  adjustment('ADJUSTMENT'),
  refund('REFUND');

  const CreditTransactionType(this.value);
  final String value;

  static CreditTransactionType fromValue(String? raw) {
    return CreditTransactionType.values.firstWhere(
      (e) => e.value == raw || e.name == raw,
      orElse: () => CreditTransactionType.adjustment,
    );
  }
}

enum CustomerActivityType {
  note('NOTE'),
  visit('VISIT'),
  purchase('PURCHASE'),
  communication('COMMUNICATION'),
  loyalty('LOYALTY'),
  wallet('WALLET'),
  credit('CREDIT');

  const CustomerActivityType(this.value);
  final String value;

  static CustomerActivityType fromValue(String? raw) {
    return CustomerActivityType.values.firstWhere(
      (e) => e.value == raw || e.name == raw,
      orElse: () => CustomerActivityType.note,
    );
  }
}

enum LoyaltyPointLedgerType {
  earn('earn'),
  redeem('redeem'),
  adjustment('adjustment'),
  expire('expire'),
  refund('refund'),
  birthdayBonus('birthday_bonus'),
  campaign('campaign');

  const LoyaltyPointLedgerType(this.value);
  final String value;

  static LoyaltyPointLedgerType fromValue(String? raw) {
    return LoyaltyPointLedgerType.values.firstWhere(
      (e) => e.value == raw || e.name == raw,
      orElse: () => LoyaltyPointLedgerType.adjustment,
    );
  }
}
