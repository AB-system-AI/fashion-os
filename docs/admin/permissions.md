# Admin Permissions

| Class | Code | Purpose |
|-------|------|---------|
| `EnterpriseAdminPermissions` | `admin.view`, `admin.manage` | Module dashboard & enterprise config |
| `OrganizationPermissions` | `org.manage` | Org hierarchy CRUD |
| `TenantSettingsPermissions` | `tenant.settings` | Settings & branding |
| `UserAdminPermissions` | `user.admin` | User administration |
| `RoleAdminPermissions` | `role.admin` | Roles & permission UI |

**Note:** `AdminPermissions.manage` (`admin.manage`) is shared with legacy system tenant RBAC. `EnterpriseAdminPermissions` adds `admin.view` for read-only dashboard access.
