# Analytics Architecture

## Layers

| Layer | Responsibility |
|-------|----------------|
| Presentation | Riverpod providers, dashboards, reports UI |
| Domain | Entities, services (`DashboardService`, `KpiService`, …) |
| Data | Drift `syncable_records`, remote datasource, sync processors |
| Engine | Pure `AnalyticsEngine` calculations |

## Data flow

```
UI → Provider → Service → Repository → Local DB → Sync Queue → AnalyticsSyncProcessor → Supabase
```

## Multi-tenant & RBAC

- Every entity carries `tenant_id`.
- Services call `PermissionEngine.require` before mutations.
- Mutations write `AuditService` logs.

## Integrations

`DashboardService` composes existing module services (POS sales, inventory stock, purchasing reports, CRM analytics, financial reports, HR employees, manufacturing reports) — no duplicated business rules.
