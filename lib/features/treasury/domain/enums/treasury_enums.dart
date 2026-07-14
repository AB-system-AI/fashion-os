enum TreasuryAccountType {
  cash,
  bank,
  pettyCash;

  String get value => name;

  static TreasuryAccountType fromValue(String? v) =>
      TreasuryAccountType.values.firstWhere((e) => e.name == v, orElse: () => TreasuryAccountType.cash);
}

enum CashBoxStatus {
  open,
  closed,
  suspended;

  String get value => name;

  static CashBoxStatus fromValue(String? v) =>
      CashBoxStatus.values.firstWhere((e) => e.name == v, orElse: () => CashBoxStatus.open);
}

enum BankAccountStatus {
  active,
  inactive,
  frozen;

  String get value => name;

  static BankAccountStatus fromValue(String? v) =>
      BankAccountStatus.values.firstWhere((e) => e.name == v, orElse: () => BankAccountStatus.active);
}

enum MovementDirection {
  inflow,
  outflow;

  String get value => name;

  static MovementDirection fromValue(String? v) =>
      MovementDirection.values.firstWhere((e) => e.name == v, orElse: () => MovementDirection.inflow);
}

enum TransferStatus {
  draft,
  pending,
  completed,
  cancelled,
  failed;

  String get value => name;

  static TransferStatus fromValue(String? v) =>
      TransferStatus.values.firstWhere((e) => e.name == v, orElse: () => TransferStatus.draft);
}

enum ChequeStatus {
  issued,
  deposited,
  cleared,
  bounced,
  cancelled,
  stale;

  String get value => name;

  static ChequeStatus fromValue(String? v) =>
      ChequeStatus.values.firstWhere((e) => e.name == v, orElse: () => ChequeStatus.issued);
}

enum VoucherStatus {
  draft,
  submitted,
  approved,
  posted,
  cancelled,
  rejected;

  String get value => name;

  static VoucherStatus fromValue(String? v) =>
      VoucherStatus.values.firstWhere((e) => e.name == v, orElse: () => VoucherStatus.draft);
}

enum ExpenseRequestStatus {
  draft,
  submitted,
  approved,
  rejected,
  paid,
  cancelled;

  String get value => name;

  static ExpenseRequestStatus fromValue(String? v) =>
      ExpenseRequestStatus.values.firstWhere((e) => e.name == v, orElse: () => ExpenseRequestStatus.draft);
}

enum ReconciliationStatus {
  open,
  inProgress,
  balanced,
  unbalanced,
  closed;

  String get value => name;

  static ReconciliationStatus fromValue(String? v) =>
      ReconciliationStatus.values.firstWhere((e) => e.name == v, orElse: () => ReconciliationStatus.open);
}

enum ForecastPeriod {
  daily,
  weekly,
  monthly,
  quarterly;

  String get value => name;

  static ForecastPeriod fromValue(String? v) =>
      ForecastPeriod.values.firstWhere((e) => e.name == v, orElse: () => ForecastPeriod.monthly);
}

enum TreasuryTransactionType {
  cashReceipt,
  cashPayment,
  bankDeposit,
  bankWithdrawal,
  transfer,
  cheque,
  expense,
  interest,
  adjustment;

  String get value => name;

  static TreasuryTransactionType fromValue(String? v) =>
      TreasuryTransactionType.values.firstWhere((e) => e.name == v, orElse: () => TreasuryTransactionType.adjustment);
}
