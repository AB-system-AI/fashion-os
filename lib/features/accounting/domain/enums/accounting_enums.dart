enum AccountType {
  asset,
  liability,
  equity,
  revenue,
  expense,
  cogs;

  String get value => name;

  static AccountType fromValue(String? v) =>
      AccountType.values.firstWhere((e) => e.name == v || e.value == v, orElse: () => AccountType.asset);
}

enum AccountNormalBalance {
  debit,
  credit;

  String get value => name;

  static AccountNormalBalance fromValue(String? v) =>
      AccountNormalBalance.values.firstWhere((e) => e.name == v, orElse: () => AccountNormalBalance.debit);
}

enum JournalStatus {
  draft,
  posted,
  reversed,
  cancelled;

  String get value => name;

  static JournalStatus fromValue(String? v) =>
      JournalStatus.values.firstWhere((e) => e.name == v, orElse: () => JournalStatus.draft);
}

enum JournalSource {
  manual,
  sale,
  refund,
  exchange,
  purchase,
  purchaseReturn,
  inventory,
  cashSession,
  wallet,
  credit,
  loyalty,
  bank,
  closing,
  manufacturing;

  String get value => name;

  static JournalSource fromValue(String? v) =>
      JournalSource.values.firstWhere((e) => e.name == v, orElse: () => JournalSource.manual);
}

enum FiscalPeriodStatus {
  open,
  closed,
  locked;

  String get value => name;

  static FiscalPeriodStatus fromValue(String? v) =>
      FiscalPeriodStatus.values.firstWhere((e) => e.name == v, orElse: () => FiscalPeriodStatus.open);
}

enum BankTransactionType {
  deposit,
  withdrawal,
  transfer,
  fee,
  interest;

  String get value => name;

  static BankTransactionType fromValue(String? v) =>
      BankTransactionType.values.firstWhere((e) => e.name == v, orElse: () => BankTransactionType.deposit);
}

enum ReconciliationStatus {
  open,
  inProgress,
  completed,
  cancelled;

  String get value => name;

  static ReconciliationStatus fromValue(String? v) =>
      ReconciliationStatus.values.firstWhere((e) => e.name == v, orElse: () => ReconciliationStatus.open);
}

enum FinancialDocumentType {
  invoice,
  bill,
  receipt,
  creditNote,
  debitNote,
  statement;

  String get value => name;

  static FinancialDocumentType fromValue(String? v) =>
      FinancialDocumentType.values.firstWhere((e) => e.name == v, orElse: () => FinancialDocumentType.receipt);
}
