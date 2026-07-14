# POS Testing Strategy

## Unit

- `SalesEngine` — totals, coupons, split payments, refund/exchange/layaway validation
- Repositories — create/find offline
- Sync processor entity type mapping

## Widget

- `PosDashboardPage` — permission gate and navigation tiles
- `PosSalesScreenPage` — cart layout (wide/narrow)

## Integration (local)

- Checkout flow with in-memory DB
- Cash session open → sale → close

Run:

```bash
flutter test test/features/pos/
flutter analyze
```
