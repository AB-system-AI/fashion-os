# Sales OMS Architecture

```
UI → Riverpod → Services → Repositories → Drift → Sync Queue → SalesSyncProcessor → Supabase
                              ↓
                      SalesOrderEngine (pure rules)
```

Module: `lib/features/sales/` — domain, data, presentation, routing, di.

Engine: `lib/core/business/engines/sales_order/sales_order_engine.dart`

Distinct from POS `SalesEngine` (`lib/core/business/engines/sales/`) which handles register checkout.
