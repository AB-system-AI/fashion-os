import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/account.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/bank_account.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/cost_center.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/currency.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/financial_document.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/fiscal_year.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/journal_entry.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/ledger_transaction.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/tax_code.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/enums/accounting_enums.dart';

abstract class AccountingRepository implements BaseLocalRepository<Account> {
  Future<Account?> findByCode(String tenantId, String code);
  Future<List<Account>> listByType(String tenantId, AccountType type);
  Future<PaginatedResult<Account>> getPage(RepositoryQuery query);
  Future<AccountGroup> createGroup(AccountGroup group);
  Future<AccountGroup?> findGroupByCode(String tenantId, String code);
  Future<CostCenter> createCostCenter(CostCenter center);
  Future<TaxCode> createTaxCode(TaxCode code);
  Future<TaxGroup> createTaxGroup(TaxGroup group);
}

abstract class JournalRepository implements BaseLocalRepository<JournalEntry> {
  Future<JournalEntry?> findByEntryNumber(String tenantId, String entryNumber);
  Future<JournalEntry?> findByReference(String tenantId, String referenceType, String referenceId);
  Future<List<JournalEntry>> listByStatus(String tenantId, JournalStatus status, {int limit = 100});
}

abstract class LedgerRepository implements BaseLocalRepository<LedgerTransaction> {
  Future<List<LedgerTransaction>> listByAccount(String tenantId, String accountId, {int limit = 500});
  Future<List<LedgerTransaction>> listByJournal(String tenantId, String journalEntryId);
  Future<List<LedgerTransaction>> listByDateRange(String tenantId, DateTime from, DateTime to);
}

abstract class BankRepository implements BaseLocalRepository<BankAccount> {
  Future<List<BankTransaction>> listTransactions(String tenantId, String bankAccountId);
  Future<BankTransaction> createTransaction(BankTransaction transaction);
  Future<ReconciliationSession> createReconciliation(ReconciliationSession session);
}

abstract class CurrencyRepository implements BaseLocalRepository<ExchangeRate> {
  Future<ExchangeRate?> findRate(String tenantId, String from, String to, DateTime on);
  Future<AccountingCurrency?> findCurrency(String tenantId, String code);
  Future<PaymentTerm?> findPaymentTerm(String tenantId, String code);
  Future<FiscalYear?> findOpenFiscalYear(String tenantId);
  Future<FiscalPeriod?> findOpenPeriod(String tenantId, DateTime date);
}
