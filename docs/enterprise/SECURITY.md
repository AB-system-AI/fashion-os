# Security Architecture (Phase 4.2)

## Authentication

- Supabase Auth with JWT sessions.
- Permissions delivered in `app_metadata.permissions` (see [RBAC_FLOW.md](./RBAC_FLOW.md)).

## Authorization

- `PermissionEngine` is the single gate for domain services.
- UI guards are additive; services always re-check permissions.

## Data Isolation

- All `SyncableRecordDao.getById()` / repository reads accept optional `tenantId`.
- Cross-tenant reads return `null` (not found) instead of leaking another tenant's row.

## Media Encryption

- **No hardcoded production key.** `MediaSecurityService` requires a 32+ character key.
- `MediaEncryptionKeyStore` generates and persists a per-device key in `SecureStorageService`.
- Bootstrap: `mediaInitializerProvider` → `loadOrCreate()` before any media provider reads `mediaSecurityServiceProvider`.

## Remote Media

- Signed URL validation via `MediaSecurityService.isSignedUrlValid()` with `MediaAccessPolicy`.
- Remote delete flows through `MediaEngine` storage providers.

## Local Database

- SQLCipher encryption for Drift (`AppDatabase.encrypted`).
- WAL + `PRAGMA synchronous = FULL`.
- Schema v2 with versioned migrations (no unsafe `createAll()` on upgrade).

## Audit

- Sensitive operations (barcode print/export, catalog mutations) write to `AuditService`.

## Failure Modes

| Scenario | Behavior |
|---|---|
| Missing media key at runtime | `StateError` — bootstrap must run first |
| Short encryption key | Rejected at `MediaSecurityService` construction |
| Missing permission | `PermissionDeniedException` → `permission_denied` result |
| Tenant mismatch on sync pull | Record skipped, logged |
