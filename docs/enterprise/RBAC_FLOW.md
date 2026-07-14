# RBAC Security Flow

Phase 4.2 wires JWT claims through to service-level enforcement.

## Pipeline

```
Supabase JWT app_metadata
        ↓
AuthUserMapper.fromSession()
        ↓
AuthUser.permissions (List<String>)
        ↓
PermissionEngine.can() / require()
        ↓
Domain services (ProductCatalogService, CategoryCatalogService, …)
        ↓
UI guards (existing presentation checks)
```

## JWT Claims

`AuthUserMapper` reads `app_metadata`:

| Claim | Maps to |
|---|---|
| `tenant_id` | `AuthUser.tenantId` |
| `employee_id` | `AuthUser.employeeId` |
| `permissions` (list or CSV) | `AuthUser.permissions` |
| `roles` (fallback list) | `AuthUser.permissions` |

## Permission Codes

Canonical format: `{module}.{action}` — see `lib/core/permissions/permission_codes.dart`.

Examples:

- `product.read`, `product.create`, `product.bulk`
- `category.read`, `category.manage`
- `brand.read`, `brand.manage`

## Enforcement Layers

1. **UI** — hides actions when `PermissionEngine.can()` is false.
2. **Domain services** — `require()` on every mutating and sensitive read operation.
3. **Sync tenant context** — `SyncTenantContext` receives tenant/device from `AuthController` on login/logout so pull/push never uses an empty tenant.

## Testing

- `test/features/auth/auth_user_mapper_test.dart` — JWT permission parsing
- `test/core/permissions/permission_engine_test.dart` — engine behavior
- Service tests assert `permission_denied` when user lacks codes
