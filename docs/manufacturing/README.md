# FashionOS Enterprise Manufacturing (MRP) & Production

Phase 11 delivers enterprise manufacturing: BOMs, production orders, work orders, material consumption, quality, capacity planning, and maintenance — fully offline-first with integrations to Inventory, Purchasing, Accounting, HR, CRM, and POS.

## Quick start

1. Bootstrap registers `manufacturingModuleInitializerProvider` (sync processors + integration).
2. Navigate to `/manufacturing` from Foundation or directly.
3. All mutations persist locally and enqueue sync automatically.

## Module layout

```
lib/features/manufacturing/
  domain/     entities, enums, value objects, repositories, services
  data/       repositories, remote datasource, sync processors
  presentation/ providers, pages
  routing/    paths and GoRouter routes
  di/         module initializer
```

## Business engine

`lib/core/business/engines/manufacturing/manufacturing_engine.dart` — BOM explosion, MRP, costing, capacity, variance, quality evaluation.

## Related docs

- [architecture.md](architecture.md)
- [bom.md](bom.md)
- [production.md](production.md)
- [planning.md](planning.md)
- [quality.md](quality.md)
- [sync.md](sync.md)
- [testing-strategy.md](testing-strategy.md)
- [integration.md](integration.md)
- [inventory.md](inventory.md)
- [accounting.md](accounting.md)
