# FashionOS Enterprise POS

Phase 8 delivers the primary point-of-sale module: sales, checkout, cash sessions, receipts, returns, exchanges, layaway, and coupons.

## Quick start

1. Bootstrap registers `posModuleInitializerProvider` (sync processors).
2. Navigate to `/pos` from Foundation or directly.
3. Open a cash session before completing sales.
4. All mutations persist locally and enqueue sync automatically.

## Module layout

```
lib/features/pos/
  domain/     entities, enums, repositories, services
  data/       repositories, remote datasource, sync processors
  presentation/ providers, pages
  routing/    paths and GoRouter routes
  di/         module initializer
```

## Business engine

`lib/core/business/engines/sales/sales_engine.dart` — pure calculation and validation (totals, coupons, split payments, refunds, exchanges, layaway).

## Related docs

- [architecture.md](architecture.md)
- [offline.md](offline.md)
- [cash.md](cash.md)
- [receipt.md](receipt.md)
- [workflow.md](workflow.md)
- [sync.md](sync.md)
- [testing-strategy.md](testing-strategy.md)
- [extension-guide.md](extension-guide.md)
