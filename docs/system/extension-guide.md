# Extension guide

1. Add entity under `domain/entities/` implementing `SyncableEntity`.
2. Extend `system_repositories.dart` and `system_repository_impl.dart`.
3. Add service method in `system_services.dart` with permission check.
4. Wire provider + sync processor in `system_providers.dart` and `system_module_initializer.dart`.
5. Add migration table + RLS policy.
6. Add page and route under `presentation/pages/` and `routing/`.
