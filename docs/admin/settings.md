# Tenant Settings

Grouped value objects in `settings.dart`:

- `TenantSettings` — JSON snapshot per scope (`tenant`, `company`, `branch`)
- `TenantBranding` — logo, colors, company name
- Embedded: `ThemeSettings`, `LocalizationSettings`, `CurrencySettings`, `RegionalSettings`, `FiscalSettings`, `NumberingSettings`, `EmailSettings`, `SmsSettings`, `NotificationSettings`, `SecuritySettings`
- `EnterpriseSettings` — enterprise config blob (`admin_enterprise_config`)

Settings validated via `AdministrationEngine.validateConfig`.
