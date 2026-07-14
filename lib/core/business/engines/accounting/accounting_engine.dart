import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/account.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/journal_entry.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/journal_line.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/ledger_transaction.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/enums/accounting_enums.dart';
import 'package:uuid/uuid.dart';

class TrialBalanceLine {
  const TrialBalanceLine({
    required this.accountId,
    required this.accountCode,
    required this.accountName,
    required this.debit,
    required this.credit,
  });

  final String accountId;
  final String accountCode;
  final String accountName;
  final double debit;
  final double credit;
}

class TrialBalanceReport {
  const TrialBalanceReport({required this.lines, required this.totalDebit, required this.totalCredit});

  final List<TrialBalanceLine> lines;
  final double totalDebit;
  final double totalCredit;

  bool get isBalanced => (totalDebit - totalCredit).abs() < 0.01;
}

class FinancialStatementLine {
  const FinancialStatementLine({required this.label, required this.amount, this.accountCode});

  final String label;
  final double amount;
  final String? accountCode;
}

class BalanceSheetReport {
  const BalanceSheetReport({
    required this.assets,
    required this.liabilities,
    required this.equity,
    required this.totalAssets,
    required this.totalLiabilitiesAndEquity,
  });

  final List<FinancialStatementLine> assets;
  final List<FinancialStatementLine> liabilities;
  final List<FinancialStatementLine> equity;
  final double totalAssets;
  final double totalLiabilitiesAndEquity;
}

class IncomeStatementReport {
  const IncomeStatementReport({
    required this.revenue,
    required this.cogs,
    required this.expenses,
    required this.netIncome,
  });

  final List<FinancialStatementLine> revenue;
  final List<FinancialStatementLine> cogs;
  final List<FinancialStatementLine> expenses;
  final double netIncome;
}

/// Standard system account codes for auto-posting.
abstract final class SystemAccounts {
  static const cash = '1000';
  static const accountsReceivable = '1100';
  static const inventory = '1200';
  static const accountsPayable = '2000';
  static const taxPayable = '2100';
  static const loyaltyLiability = '2200';
  static const walletLiability = '2210';
  static const salesRevenue = '4000';
  static const cogs = '5000';
  static const cashOverShort = '5900';
  static const salariesExpense = '6100';
  static const payrollPayable = '2300';
  static const payrollTaxPayable = '2110';
  static const wip = '1250';
  static const manufacturingVariance = '5910';
  static const scrapExpense = '5920';
  static const manufacturingOverhead = '5930';
}

/// Pure double-entry accounting rules and report calculations.
class AccountingEngine {
  AccountingEngine({DomainEventBus? eventBus, Uuid? uuid})
      : _eventBus = eventBus,
        _uuid = uuid ?? const Uuid();

  final DomainEventBus? _eventBus;
  final Uuid _uuid;

  Result<void> validateJournalLines(List<JournalLine> lines) {
    if (lines.length < 2) {
      return const Error(ValidationFailure(message: 'Journal requires at least two lines', code: 'invalid_journal'));
    }
    for (final line in lines) {
      if (line.debit < 0 || line.credit < 0) {
        return const Error(ValidationFailure(message: 'Amounts cannot be negative', code: 'invalid_amount'));
      }
      if (line.debit > 0 && line.credit > 0) {
        return const Error(ValidationFailure(message: 'Line cannot have both debit and credit', code: 'invalid_line'));
      }
      if (line.debit == 0 && line.credit == 0) {
        return const Error(ValidationFailure(message: 'Line must have debit or credit', code: 'empty_line'));
      }
    }
    final debit = lines.fold(0.0, (s, l) => s + l.debit);
    final credit = lines.fold(0.0, (s, l) => s + l.credit);
    if ((debit - credit).abs() > 0.01) {
      return Error(ValidationFailure(
        message: 'Debits ($debit) must equal credits ($credit)',
        code: 'unbalanced_journal',
      ));
    }
    return const Success(null);
  }

  List<LedgerTransaction> buildLedgerTransactions({
    required JournalEntry entry,
    required Map<String, Account> accounts,
  }) {
    return entry.lines.map((line) {
      final account = accounts[line.accountId];
      return LedgerTransaction(
        id: _uuid.v4(),
        tenantId: entry.tenantId,
        storeId: entry.storeId,
        accountId: line.accountId,
        accountCode: line.accountCode,
        journalEntryId: entry.id,
        entryDate: entry.entryDate,
        debit: line.debit,
        credit: line.credit,
        description: line.description ?? entry.description,
        referenceType: entry.referenceType,
        referenceId: entry.referenceId,
        costCenterId: line.costCenterId,
        currency: line.currency,
        version: 1,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        syncStatus: entry.syncStatus,
        isDirty: true,
      );
    }).toList();
  }

  Account applyBalanceChange(Account account, double debit, double credit) {
    final delta = switch (account.normalBalance) {
      AccountNormalBalance.debit => debit - credit,
      AccountNormalBalance.credit => credit - debit,
    };
    return account.copyWith(balance: _round(account.balance + delta));
  }

  TrialBalanceReport buildTrialBalance(List<Account> accounts, List<LedgerTransaction> transactions) {
    final debits = <String, double>{};
    final credits = <String, double>{};
    for (final tx in transactions) {
      debits[tx.accountId] = (debits[tx.accountId] ?? 0) + tx.debit;
      credits[tx.accountId] = (credits[tx.accountId] ?? 0) + tx.credit;
    }

    final lines = accounts.map((a) {
      final d = debits[a.id] ?? 0;
      final c = credits[a.id] ?? 0;
      return TrialBalanceLine(accountId: a.id, accountCode: a.code, accountName: a.name, debit: d, credit: c);
    }).toList();

    final totalDebit = lines.fold(0.0, (s, l) => s + l.debit);
    final totalCredit = lines.fold(0.0, (s, l) => s + l.credit);
    return TrialBalanceReport(lines: lines, totalDebit: totalDebit, totalCredit: totalCredit);
  }

  BalanceSheetReport buildBalanceSheet(List<Account> accounts) {
    final assets = <FinancialStatementLine>[];
    final liabilities = <FinancialStatementLine>[];
    final equity = <FinancialStatementLine>[];

    for (final a in accounts) {
      final line = FinancialStatementLine(label: a.name, amount: a.balance, accountCode: a.code);
      switch (a.accountType) {
        case AccountType.asset:
          assets.add(line);
        case AccountType.liability:
          liabilities.add(line);
        case AccountType.equity:
          equity.add(line);
        default:
          break;
      }
    }

    final totalAssets = assets.fold(0.0, (s, l) => s + l.amount);
    final totalLiab = liabilities.fold(0.0, (s, l) => s + l.amount);
    final totalEquity = equity.fold(0.0, (s, l) => s + l.amount);
    return BalanceSheetReport(
      assets: assets,
      liabilities: liabilities,
      equity: equity,
      totalAssets: totalAssets,
      totalLiabilitiesAndEquity: totalLiab + totalEquity,
    );
  }

  IncomeStatementReport buildIncomeStatement(List<Account> accounts) {
    final revenue = <FinancialStatementLine>[];
    final cogs = <FinancialStatementLine>[];
    final expenses = <FinancialStatementLine>[];

    for (final a in accounts) {
      final line = FinancialStatementLine(label: a.name, amount: a.balance, accountCode: a.code);
      switch (a.accountType) {
        case AccountType.revenue:
          revenue.add(line);
        case AccountType.cogs:
          cogs.add(line);
        case AccountType.expense:
          expenses.add(line);
        default:
          break;
      }
    }

    final totalRevenue = revenue.fold(0.0, (s, l) => s + l.amount);
    final totalCogs = cogs.fold(0.0, (s, l) => s + l.amount);
    final totalExpenses = expenses.fold(0.0, (s, l) => s + l.amount);
    return IncomeStatementReport(
      revenue: revenue,
      cogs: cogs,
      expenses: expenses,
      netIncome: totalRevenue - totalCogs - totalExpenses,
    );
  }

  List<JournalLine> saleJournalLines({
    required double grandTotal,
    required double taxTotal,
    required Map<String, Account> accountsByCode,
  }) {
    final netRevenue = grandTotal - taxTotal;
    return [
      _debitLine(accountsByCode, SystemAccounts.cash, grandTotal, 'Sale receipt'),
      _creditLine(accountsByCode, SystemAccounts.salesRevenue, netRevenue, 'Sales revenue'),
      if (taxTotal > 0) _creditLine(accountsByCode, SystemAccounts.taxPayable, taxTotal, 'Sales tax'),
    ];
  }

  List<JournalLine> purchaseReceiptLines({
    required double amount,
    required Map<String, Account> accountsByCode,
  }) {
    return [
      _debitLine(accountsByCode, SystemAccounts.inventory, amount, 'Inventory receipt'),
      _creditLine(accountsByCode, SystemAccounts.accountsPayable, amount, 'Accounts payable'),
    ];
  }

  List<JournalLine> cashSessionVarianceLines({
    required double difference,
    required Map<String, Account> accountsByCode,
  }) {
    if (difference.abs() < 0.01) return [];
    if (difference > 0) {
      return [
        _debitLine(accountsByCode, SystemAccounts.cash, difference, 'Cash over'),
        _creditLine(accountsByCode, SystemAccounts.cashOverShort, difference, 'Cash over/short'),
      ];
    }
    final abs = difference.abs();
    return [
      _debitLine(accountsByCode, SystemAccounts.cashOverShort, abs, 'Cash over/short'),
      _creditLine(accountsByCode, SystemAccounts.cash, abs, 'Cash short'),
    ];
  }

  List<JournalLine> payrollApprovedLines({
    required double grossSalary,
    required double taxAmount,
    required double netPay,
    required Map<String, Account> accountsByCode,
  }) {
    final liability = grossSalary - taxAmount;
    return [
      _debitLine(accountsByCode, SystemAccounts.salariesExpense, grossSalary, 'Payroll expense'),
      _creditLine(accountsByCode, SystemAccounts.payrollPayable, liability, 'Payroll payable'),
      if (taxAmount > 0) _creditLine(accountsByCode, SystemAccounts.payrollTaxPayable, taxAmount, 'Payroll tax'),
    ];
  }

  List<JournalLine> bonusJournalLines({
    required double amount,
    required Map<String, Account> accountsByCode,
  }) {
    return [
      _debitLine(accountsByCode, SystemAccounts.salariesExpense, amount, 'Bonus expense'),
      _creditLine(accountsByCode, SystemAccounts.payrollPayable, amount, 'Bonus payable'),
    ];
  }

  List<JournalLine> materialIssueLines({
    required double amount,
    required Map<String, Account> accountsByCode,
  }) {
    if (amount <= 0) return [];
    return [
      _debitLine(accountsByCode, SystemAccounts.wip, amount, 'WIP — material issue'),
      _creditLine(accountsByCode, SystemAccounts.inventory, amount, 'Inventory — material issue'),
    ];
  }

  List<JournalLine> materialReturnLines({
    required double amount,
    required Map<String, Account> accountsByCode,
  }) {
    if (amount <= 0) return [];
    return [
      _debitLine(accountsByCode, SystemAccounts.inventory, amount, 'Inventory — material return'),
      _creditLine(accountsByCode, SystemAccounts.wip, amount, 'WIP — material return'),
    ];
  }

  List<JournalLine> wipStartLines({
    required double amount,
    required Map<String, Account> accountsByCode,
  }) {
    if (amount <= 0) return [];
    return [
      _debitLine(accountsByCode, SystemAccounts.wip, amount, 'WIP — production started'),
      _creditLine(accountsByCode, SystemAccounts.manufacturingOverhead, amount, 'Manufacturing overhead allocation'),
    ];
  }

  List<JournalLine> finishedGoodsReceiptLines({
    required double amount,
    required Map<String, Account> accountsByCode,
  }) {
    if (amount <= 0) return [];
    return [
      _debitLine(accountsByCode, SystemAccounts.inventory, amount, 'Finished goods receipt'),
      _creditLine(accountsByCode, SystemAccounts.wip, amount, 'WIP — FG receipt'),
    ];
  }

  List<JournalLine> scrapLines({
    required double amount,
    required Map<String, Account> accountsByCode,
  }) {
    if (amount <= 0) return [];
    return [
      _debitLine(accountsByCode, SystemAccounts.scrapExpense, amount, 'Production scrap'),
      _creditLine(accountsByCode, SystemAccounts.wip, amount, 'WIP — scrap'),
    ];
  }

  List<JournalLine> manufacturingVarianceLines({
    required double varianceAmount,
    required Map<String, Account> accountsByCode,
  }) {
    if (varianceAmount.abs() < 0.01) return [];
    if (varianceAmount > 0) {
      return [
        _debitLine(accountsByCode, SystemAccounts.manufacturingVariance, varianceAmount, 'Unfavorable variance'),
        _creditLine(accountsByCode, SystemAccounts.wip, varianceAmount, 'WIP variance'),
      ];
    }
    final abs = varianceAmount.abs();
    return [
      _debitLine(accountsByCode, SystemAccounts.wip, abs, 'WIP variance'),
      _creditLine(accountsByCode, SystemAccounts.manufacturingVariance, abs, 'Favorable variance'),
    ];
  }

  List<JournalLine> productionCompletionLines({
    required double laborCost,
    required double overheadCost,
    required Map<String, Account> accountsByCode,
  }) {
    final lines = <JournalLine>[];
    if (laborCost > 0) {
      lines.add(_debitLine(accountsByCode, SystemAccounts.wip, laborCost, 'Labor to WIP'));
      lines.add(_creditLine(accountsByCode, SystemAccounts.salariesExpense, laborCost, 'Labor allocation'));
    }
    if (overheadCost > 0) {
      lines.add(_debitLine(accountsByCode, SystemAccounts.wip, overheadCost, 'Overhead to WIP'));
      lines.add(_creditLine(accountsByCode, SystemAccounts.manufacturingOverhead, overheadCost, 'Overhead allocation'));
    }
    return lines;
  }

  List<JournalLine> cogsPreparationLines({
    required double amount,
    required Map<String, Account> accountsByCode,
  }) {
    if (amount <= 0) return [];
    return [
      _debitLine(accountsByCode, SystemAccounts.cogs, amount, 'COGS preparation'),
      _creditLine(accountsByCode, SystemAccounts.inventory, amount, 'Inventory — COGS'),
    ];
  }

  JournalLine _debitLine(Map<String, Account> map, String code, double amount, String desc) {
    final account = map[code]!;
    return JournalLine(id: _uuid.v4(), accountId: account.id, accountCode: code, debit: _round(amount), description: desc);
  }

  JournalLine _creditLine(Map<String, Account> map, String code, double amount, String desc) {
    final account = map[code]!;
    return JournalLine(id: _uuid.v4(), accountId: account.id, accountCode: code, credit: _round(amount), description: desc);
  }

  double convertAmount(double amount, double rate) => _round(amount * rate);

  void publishJournalPosted({required String journalEntryId, required String tenantId, String? storeId}) {
    _eventBus?.publish(JournalPostedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      journalEntryId: journalEntryId,
      tenantId: tenantId,
      storeId: storeId,
    ));
  }

  void publishFiscalClosed({required String fiscalPeriodId, required String tenantId}) {
    _eventBus?.publish(FiscalClosedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      fiscalPeriodId: fiscalPeriodId,
      tenantId: tenantId,
    ));
  }

  void publishPaymentRecorded({required String paymentId, required double amount, String? tenantId}) {
    _eventBus?.publish(PaymentRecordedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      paymentId: paymentId,
      amountMinor: (amount * 100).round(),
      tenantId: tenantId,
    ));
  }

  void publishReconciliationCompleted({required String sessionId, String? tenantId}) {
    _eventBus?.publish(ReconciliationCompletedEvent(
      eventId: _uuid.v4(),
      occurredAt: DateTime.now().toUtc(),
      sessionId: sessionId,
      tenantId: tenantId,
    ));
  }

  double _round(double v) => double.parse(v.toStringAsFixed(2));
}
