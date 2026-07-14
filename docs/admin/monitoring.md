# Monitoring

Admin monitoring pages delegate to **system** where applicable:

| Admin page | System delegate |
|------------|-----------------|
| Audit Explorer | `AuditExplorerService` |
| Jobs / Sync | System monitor services |
| Devices / Sessions / Login History | `SecurityCenterService` |
| Diagnostics | `DiagnosticsService` |
| Health Dashboard | `AdminDiagnosticsService` + system health repos |

Usage/storage/API metrics use admin-specific tables (`admin_usage_metrics`, `admin_storage_usage`, `admin_api_usage`).
