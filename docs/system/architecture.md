# System module architecture

## Layers

- **Domain**: 19 syncable entities, 14 services, value objects for dashboard/audit/diagnostics.
- **Data**: `SystemRepositoryImpl` local-first repos, `SystemRemoteDataSource`, `SystemSyncProcessor` per entity.
- **Presentation**: Riverpod providers, 13 admin pages, GoRouter under `/system`.

## Key services

| Service | Responsibility |
|---------|----------------|
| `SystemDashboardService` | Aggregate metrics for hub |
| `AuditExplorerService` | Wraps core `AuditService` reads |
| `TenantAdminService` | Roles, permissions, configuration |
| `SecurityCenterService` | Sessions, devices, login history |
| `MaintenanceService` | Tenant maintenance mode |
| `DiagnosticsService` | Runtime health bundle |

## Permissions

Uses `SystemMaintenancePermissions` (not manufacturing `MaintenancePermissions`).
