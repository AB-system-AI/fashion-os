# Security Report — RC2

**Date:** 2026-07-14

## Authentication & Authorization

| Control | Status | RC2 Notes |
|---------|--------|-----------|
| Supabase Auth | ✅ | Unchanged |
| RBAC permission codes | ✅ | 60+ permission groups; namespaces fixed |
| PermissionEngine in services | ✅ | All write paths |
| Tenant isolation (app) | ✅ | `tenant_id` on queries |
| Tenant isolation (DB) | ✅ | RLS on all tables |
| Session/device tracking | ✅ | System security center |
| MFA | ⚠️ | Abstraction only |

## Phase 18 Permission Security Fixes

| Collision | Before | After |
|-----------|--------|-------|
| Manufacturing maintenance | `maintenance.manage` | `manufacturing.maintenance.manage` |
| System maintenance mode | `maintenance.manage` | `system.maintenance.manage` |
| Asset maintenance | `maintenance.view/manage` | `assets.maintenance.view/manage` |
| Treasury banks | Shared `bank.manage` with Accounting | `treasury.bank.manage` |
| Treasury receipts | Shared `receipt.manage` with POS | `treasury.receipt.manage` |

**Impact:** Prevents privilege escalation where granting manufacturing maintenance inadvertently grants system maintenance mode or asset maintenance access.

## Data Protection

| Control | Status |
|---------|--------|
| SQLCipher-compatible local DB | ✅ |
| API key hash-only storage | ✅ |
| Webhook secret hash | ✅ |
| Audit trail | ✅ |
| Soft delete | ✅ |

## Network Security

| Control | Status |
|---------|--------|
| HTTPS (Supabase) | ✅ |
| Connector rate limiting | ✅ |
| Webhook HMAC validation | ⚠️ Stub per connector |

## Production Recommendations

1. Re-seed admin roles with namespaced permission codes before go-live
2. Enable Supabase audit logs on production
3. Wire MFA before exposing admin roles externally
4. Rotate API keys via System Admin before production cutover
