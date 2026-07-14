# Integrations Architecture

```
UI → Riverpod → Services → Repositories → Drift → Sync Queue → IntegrationsSyncProcessor → Supabase
                              ↓
                   IntegrationConnectorEngine (health, rate limit, retry)
                              ↓
                   Provider abstractions (Email, SMS, Push, OAuth, Storage)
```

Module: `lib/features/integrations/` — domain, data, presentation, routing, di.

Engine: `lib/core/business/engines/integration/integration_connector_engine.dart`

Wraps existing `ImportExportService` via `ImportExportIntegrationService`.
