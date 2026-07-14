# Deployment

1. Apply migration `20250712000020_admin_enterprise.sql`
2. Ensure bootstrap calls `adminModuleInitializerProvider` after system module
3. Grant `admin.view` to read-only admins; `admin.manage` + granular codes for operators
4. Routes registered via `buildAdminRoutes()` in `auth_router.dart`

Admin module is independent of `lib/features/system/` — both coexist.
