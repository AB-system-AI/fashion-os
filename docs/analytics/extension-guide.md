# Extension Guide

## Add a new dashboard module

1. Extend `DashboardType` enum if needed.
2. Add a method on `DashboardService` composing an existing module report service.
3. Add route in `analytics_routes.dart` and tile in `AnalyticsHubPage`.
4. Optionally snapshot KPIs via `KpiService`.

## Add a new report type

1. Create template row in `report_templates` (local or migration seed).
2. Use `ReportDefinitionService.create` with module key and column schema.
3. Wire export rows in UI or scheduling service.

## Add a sync entity

1. Add Supabase table + RLS in a migration.
2. Create entity with `entityTypeName` and `toPayload`/`fromPayload`.
3. Register `AnalyticsSyncProcessor` provider and register in module initializer.

Do not duplicate calculations — extend `AnalyticsEngine` for pure math only.
