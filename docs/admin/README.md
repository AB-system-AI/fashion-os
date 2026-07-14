# FashionOS Enterprise Administration

Phase 17 delivers org hierarchy, tenant settings, RBAC templates, licensing, usage metrics, and an enterprise admin hub — separate from the **system** module (ops monitoring).

## Quick start

1. Bootstrap registers `adminModuleInitializerProvider` (19 sync processors).
2. Navigate to `/admin` from Foundation (**Open Admin**).
3. Workflow: Organizations → Users/Roles → Tenant Settings → License/Usage → Monitoring (delegates to system where noted).

## Permissions

- `EnterpriseAdminPermissions.view` / `manage` — module access (`admin.view`, `admin.manage`)
- `OrganizationPermissions.manage` — org hierarchy
- `TenantSettingsPermissions.settings` — tenant configuration
- `UserAdminPermissions.admin` / `RoleAdminPermissions.admin` — identity & RBAC

Existing `AdminPermissions.manage` remains for legacy tenant RBAC in system.

## Related docs

- [architecture.md](architecture.md)
- [permissions.md](permissions.md)
- [organizations.md](organizations.md)
- [settings.md](settings.md)
- [deployment.md](deployment.md)
- [monitoring.md](monitoring.md)
- [extension-guide.md](extension-guide.md)
- [testing-strategy.md](testing-strategy.md)
