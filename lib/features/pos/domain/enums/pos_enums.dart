enum SaleStatus {
  draft,
  suspended,
  completed,
  cancelled,
  voided;

  String get value => name;

  static SaleStatus fromValue(String? v) =>
      SaleStatus.values.firstWhere((e) => e.name == v || e.value == v, orElse: () => SaleStatus.draft);
}

enum PaymentMethodKind {
  cash,
  visa,
  mastercard,
  mada,
  wallet,
  credit,
  giftCard,
  bankTransfer,
  other;

  String get value => name;

  static PaymentMethodKind fromValue(String? v) =>
      PaymentMethodKind.values.firstWhere((e) => e.name == v || e.value == v, orElse: () => PaymentMethodKind.other);
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded;

  String get value => name;

  static PaymentStatus fromValue(String? v) =>
      PaymentStatus.values.firstWhere((e) => e.name == v || e.value == v, orElse: () => PaymentStatus.pending);
}

enum CashSessionStatus {
  open,
  closed,
  reconciled;

  String get value => name;

  static CashSessionStatus fromValue(String? v) =>
      CashSessionStatus.values.firstWhere((e) => e.name == v || e.value == v, orElse: () => CashSessionStatus.open);
}

enum CashMovementType {
  sale,
  refund,
  safeDrop,
  cashIn,
  cashOut,
  expense,
  openingFloat,
  closingFloat;

  String get value => name;

  static CashMovementType fromValue(String? v) =>
      CashMovementType.values.firstWhere((e) => e.name == v || e.value == v, orElse: () => CashMovementType.cashIn);
}

enum CouponType {
  percentage,
  fixed,
  bogo,
  freeShipping;

  String get value => name;

  static CouponType fromValue(String? v) =>
      CouponType.values.firstWhere((e) => e.name == v || e.value == v, orElse: () => CouponType.percentage);
}

enum ReturnStatus {
  pending,
  approved,
  completed,
  rejected;

  String get value => name;

  static ReturnStatus fromValue(String? v) =>
      ReturnStatus.values.firstWhere((e) => e.name == v || e.value == v, orElse: () => ReturnStatus.pending);
}

enum ExchangeStatus {
  pending,
  completed,
  cancelled;

  String get value => name;

  static ExchangeStatus fromValue(String? v) =>
      ExchangeStatus.values.firstWhere((e) => e.name == v || e.value == v, orElse: () => ExchangeStatus.pending);
}

enum LayawayStatus {
  active,
  completed,
  cancelled,
  defaulted;

  String get value => name;

  static LayawayStatus fromValue(String? v) =>
      LayawayStatus.values.firstWhere((e) => e.name == v || e.value == v, orElse: () => LayawayStatus.active);
}

enum ReceiptFormat {
  thermal,
  a4,
  pdf,
  digital;

  String get value => name;

  static ReceiptFormat fromValue(String? v) =>
      ReceiptFormat.values.firstWhere((e) => e.name == v || e.value == v, orElse: () => ReceiptFormat.thermal);
}
