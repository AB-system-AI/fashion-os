# Phase 3 — Enterprise Authentication

## Architecture

```
features/auth/
├── domain/          # Entities, repository interfaces
├── data/            # Supabase datasource, repository impl
├── presentation/    # Pages, widgets, Riverpod controllers
└── routing/         # Auth routes, guards, redirect logic

core/
├── security/        # Password validation, secure storage, device info
├── local_database/  # SQLite offline-first store
├── sync/            # SyncEngine with queue + retry
└── enterprise/      # Feature flags, license, remote config, analytics hooks
```

Clean Architecture: UI → AuthController → AuthRepository → AuthRemoteDataSource → Supabase.

## Owner Registration Flow

1. User completes `RegisterPage` form
2. `supabase.auth.signUp()` creates auth user + profile (trigger)
3. RPC `register_owner_organization()` runs in **single PostgreSQL transaction**:
   - Tenant, subscription, store, warehouse
   - Owner role + all permissions
   - Employee, store assignment, employee role
   - Taxes, payment methods, POS register, expense categories
   - Loyalty program, receipt template, settings, numbering sequences
4. Edge Function `update-user-claims` sets JWT `app_metadata`
5. `auth.refreshSession()` loads new claims
6. Device session registered via RPC

## Login Flow

1. Check `is_login_locked` RPC (brute-force protection)
2. `signInWithPassword`
3. Edge Function `record-login-attempt`
4. `update-user-claims` if metadata missing
5. `register_device_session`
6. AuthController updates state → router redirects to home

## Security Decisions

| Decision | Rationale |
|---|---|
| JWT claims in `app_metadata` only | User-editable `user_metadata` never used for authorization |
| `private` schema RLS helpers | SECURITY DEFINER functions avoid policy recursion |
| Brute-force via `login_attempts` | 5 failures / 15 min lockout |
| Password policy (10+ chars, mixed) | Enterprise-grade credential strength |
| `flutter_secure_storage` | Sensitive tokens encrypted on device |
| Device session tracking | Multi-device support, logout all sessions |
| Security events table | Immutable audit trail for auth actions |

## Supabase Integration

- **Auth**: Email/password, verification, password reset
- **RPC**: `register_owner_organization`, `invite_employee`, `accept_employee_invitation`
- **Edge Functions**: `update-user-claims`, `record-login-attempt`
- **RLS**: New tables tenant-scoped; login_attempts denied to clients
- **Realtime**: Ready for session revocation broadcasts (future)

## Offline-First Foundation

- `LocalDatabase` (SQLite): products, customers, sales, settings, sync_queue
- `SyncEngine`: enqueue offline mutations, auto-sync on connectivity
- Extension points documented in `docs/OFFLINE_ARCHITECTURE.md`

## Future Auth Providers (Prepared)

- Phone OTP: `AuthRepository` interface supports additional sign-in methods
- Google/Apple: Supabase OAuth providers + same claims pipeline

## Sequence Diagrams

See `docs/auth/SEQUENCE_DIAGRAMS.md`.

## Extension Points

See `docs/auth/EXTENSION_POINTS.md` for POS, AI, integrations, and offline modules.
