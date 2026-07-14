# Accounting Architecture

## Layers

```
UI (pages) → Riverpod providers → Application services → Repositories → syncable_records (Drift) → SyncQueue → AccountingSyncProcessor → Supabase
```

Business rules live in **AccountingEngine**. Widgets contain no business logic.

## Services

| Service | Responsibility |
|---------|----------------|
| `PostingService` | Post journals, update ledger, audit, idempotent auto-post |
| `JournalService` | Draft journals, validation |
| `LedgerService` | Read ledger transactions |
| `TrialBalanceService` | Trial balance report |
| `FinancialReportService` | Balance sheet, income statement |
| `ClosingService` | Fiscal period close |
| `FiscalYearService` | Fiscal year/period CRUD |
| `ExchangeRateService` | Currency conversion |
| `BankService` | Bank accounts and transactions |
| `ReconciliationService` | Bank reconciliation sessions |
| `PaymentTermService` | Payment terms |
| `AccountingIntegrationService` | Auto-post from domain events |

## Repositories

| Repository | Entity types |
|------------|--------------|
| `AccountingRepository` | Accounts, groups, cost centers, tax codes |
| `JournalRepository` | Journal entries |
| `LedgerRepository` | Ledger transactions |
| `BankRepository` | Bank accounts, transactions, reconciliation |
| `CurrencyRepository` | Currencies, exchange rates, payment terms, fiscal years |

## Events published

- `JournalPostedEvent`
- `FiscalClosedEvent`
- `PaymentRecordedEvent`
- `ReconciliationCompletedEvent`

## Events consumed (auto-posting)

- `sale.completed` → revenue/cash journal
- `cash_session.closed` → cash over/short
- `purchase.received` → inventory/AP (amount from receipt when available)
- `payment.received` → `PaymentRecordedEvent`
- `stock.changed` → COGS extension point
