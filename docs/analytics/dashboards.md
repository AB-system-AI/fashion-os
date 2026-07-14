# Dashboards

## Routes

| Dashboard | Path | Permission |
|-----------|------|------------|
| Hub | `/analytics` | `analytics.view` |
| Executive | `/analytics/executive` | `executive.dashboard` |
| Sales | `/analytics/sales` | `analytics.view` |
| Inventory | `/analytics/inventory` | `analytics.view` |
| Purchasing | `/analytics/purchasing` | `analytics.view` |
| CRM | `/analytics/crm` | `analytics.view` |
| Accounting | `/analytics/accounting` | `analytics.view` |
| HR | `/analytics/hr` | `analytics.view` |
| Manufacturing | `/analytics/manufacturing` | `analytics.view` |

## UI components

- `DashboardMetricsGrid` — responsive KPI cards
- `AnalyticsChartWidget` — line, bar, pie, gauge, heatmap (lightweight custom painters)
- `MetricCard` — single KPI with optional delta

## Snapshots

Executive dashboard writes `AnalyticsSnapshot` records for cached executive metrics.
