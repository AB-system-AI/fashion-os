# Accounting Sync

Processors registered in `accountingModuleInitializerProvider`:

| Processor | Entity type | Remote table |
|-----------|-------------|--------------|
| AccountingSyncProcessor | `chart_of_account` | `chart_of_accounts` |
| JournalSyncProcessor | `journal_entry` | `journal_entries` |
| LedgerSyncProcessor | `ledger_transaction` | `ledger_transactions` |
| BankSyncProcessor | `bank_account` | `bank_accounts` |
| ExchangeRateSyncProcessor | `exchange_rate` | `exchange_rates` |
| FiscalYearSyncProcessor | `fiscal_year` | `fiscal_years` |

Migration: `20250712000007_accounting_enterprise.sql`

## Offline behavior

- Every create/update writes to `syncable_records` and enqueues `SyncQueue`.
- Processors push to Supabase when online; pull delta merges remote changes.
- Conflict resolution uses version columns and last-write-wins with audit trail.

## Manual recovery

Failed sync items remain in the queue with error messages. Retry via sync coordinator or clear after fixing payload conflicts.
