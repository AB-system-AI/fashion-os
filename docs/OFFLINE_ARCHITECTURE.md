# Offline-First Architecture

## Principle

**Local database is the primary source of truth.** Internet is optional for daily catalog and POS operations.

## Local Database (Drift + SQLCipher)

Path: `{app_documents}/fashion_pos_local.db` (encrypted, schema **v2**)

| Table | Purpose |
|---|---|
| `sync_queue_items` | Outbound mutations with retry/backoff |
| `sync_checkpoints` | Per-device incremental pull watermarks |
| `sync_conflict_history` | Conflict audit trail |
| `syncable_records` | Generic entity cache (products, categories, brands, media index) |
| `syncable_records_fts` | FTS5 index — updated on insert/update/delete |
| `auth_cache_entries` | Cached auth context for offline session validation |
| `local_settings` | Composite PK `(tenant_id, key)` |
| `audit_log_entries` | Local audit trail pending server sync |
| `license_cache_entries` | Offline license with grace period |
| `app_recovery_entries` | Startup recovery checkpoints |

## Encryption & Recovery

- **SQLCipher** — key in `flutter_secure_storage`
- **Schema v2 migration** — safe `local_settings` PK upgrade + conflict history table
- **WAL** journal + `PRAGMA synchronous = FULL`
- **Transactions** — repository write + sync queue enqueue in one Drift transaction

## Sync Engine

`SyncCoordinator` in `lib/core/infrastructure/sync/sync_coordinator.dart`:

- Push: processes queue with `scheduled_at` backoff and max retries
- Pull: applies deltas via `SyncPullApplier`, saves checkpoints
- Crash recovery: `resetStuckProcessing()` on startup
- Tenant: `SyncTenantContext` from authenticated session

See [enterprise/SYNC_ARCHITECTURE.md](./enterprise/SYNC_ARCHITECTURE.md).

## Conflict Resolution

`sync_conflict_history` locally + Supabase `sync_conflicts` remotely.
Strategies: `client_wins`, `server_wins`, `merged`, `manual`.

## RBAC Offline

Permissions parsed from JWT `app_metadata` at login and held in `AuthUser`.
`PermissionEngine` enforces at service layer even when offline.

See [enterprise/RBAC_FLOW.md](./enterprise/RBAC_FLOW.md).

## Performance Targets

| Operation | Target |
|---|---|
| App startup | < 2s |
| Barcode lookup | < 100ms (local index) |
| Product search | < 100ms (FTS5) |
| Checkout | < 1s |
| Scale | 100K products, 1M invoices |

## What Requires Internet

- Initial auth / token refresh
- Sync push/pull
- Remote media upload/download
- License validation
- Analytics / crash reporting
- Remote config fetch

Everything else operates offline.

## Code Generation

After schema changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```
