# Admin Architecture

## Layers

```
presentation/pages → providers → domain/services → domain/repositories
                                      ↓
                              AdministrationEngine (pure rules)
                                      ↓
                         data/repositories + sync processors → Supabase
```

## Services

| Service | Responsibility |
|---------|----------------|
| `OrganizationService` | Companies, branches, stores, departments, teams |
| `UserAdminService` | Admin users, invites |
| `RoleAdminService` | Role templates, permission assignments |
| `TenantSettingsService` | Tenant settings snapshots, localization/currency/fiscal |
| `BrandingService` | Tenant branding |
| `LicenseAdminService` | License validation |
| `UsageDashboardService` | Usage, storage, API metrics |
| `AdminDiagnosticsService` | Health assessment; delegates audit/diagnostics to **system** |

## System delegation

Monitoring pages (audit, jobs, sync, devices, sessions, diagnostics) reuse **system** services where overlap exists. Admin focuses on org/settings/licensing; system remains ops monitoring.
