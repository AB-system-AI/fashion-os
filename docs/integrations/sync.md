# Integrations Sync

Eight `IntegrationsSyncProcessor` instances registered at bootstrap:

| Entity | Remote table |
|--------|-------------|
| `integration_connector` | `integration_connectors` |
| `webhook_endpoint` | `webhooks` |
| `api_key` | `api_keys` |
| `integration_log` | `integration_logs` |
| `import_job` | `import_jobs` |
| `export_job` | `export_jobs` |
| `oauth_connection` | `oauth_connections` |
| `printer_profile` | `printer_profiles` |

Push: create/upsert/soft-delete via `IntegrationsRemoteDataSource`.

Pull: delta by `tenant_id` + `updated_at`.

RLS: tenant-scoped policies on all tables (migration `20250712000014`).
