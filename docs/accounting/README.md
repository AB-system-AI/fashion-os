# FashionOS Enterprise Accounting

Phase 9 delivers the general ledger and finance module: chart of accounts, journals, ledger, fiscal periods, banks, taxes, and financial reports — fully offline-first with automatic posting from POS, Purchasing, Inventory, and CRM events.

## Quick start

1. Bootstrap registers `accountingModuleInitializerProvider` (sync processors + integration service).
2. Navigate to `/accounting` from Foundation or directly.
3. Default system accounts (1000–5900) are seeded on first auto-post.
4. All mutations persist locally and enqueue sync automatically.

## Module layout

```
lib/features/accounting/
  domain/     entities, enums, repositories, services
  data/       repositories, remote datasource, sync processors
  presentation/ providers, pages
  routing/    paths and GoRouter routes
  di/         module initializer
```

## Business engine

`lib/core/business/engines/accounting/accounting_engine.dart` — double-entry validation, ledger building, trial balance, balance sheet, income statement, and auto journal line builders.

## Related docs

- [architecture.md](architecture.md)
- [posting.md](posting.md)
- [reports.md](reports.md)
- [sync.md](sync.md)
- [testing-strategy.md](testing-strategy.md)
- [extension-guide.md](extension-guide.md)
