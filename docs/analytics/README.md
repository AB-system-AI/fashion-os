# FashionOS Enterprise Reporting, BI & Analytics

Phase 12 delivers enterprise analytics: dashboards, KPIs, dynamic reports, exports, and scheduling — fully offline-first with integrations across all ERP modules.

## Quick start

1. Bootstrap registers `analyticsModuleInitializerProvider` (10 sync processors).
2. Navigate to `/analytics` from Foundation or directly.
3. All mutations persist locally and enqueue sync automatically.

## Module layout

```
lib/features/analytics/
  domain/     entities, enums, value objects, repositories, services
  data/       repositories, remote datasource, sync processors
  presentation/ providers, pages, widgets
  routing/    paths and GoRouter routes
  di/         module initializer
```

## Business engine

`lib/core/business/engines/analytics/analytics_engine.dart` — KPI math, trends, forecasts, comparisons, executive summaries.

## Related docs

- [architecture.md](architecture.md)
- [dashboards.md](dashboards.md)
- [reports.md](reports.md)
- [kpis.md](kpis.md)
- [export.md](export.md)
- [sync.md](sync.md)
- [testing-strategy.md](testing-strategy.md)
- [extension-guide.md](extension-guide.md)
