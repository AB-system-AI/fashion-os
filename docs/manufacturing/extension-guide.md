# Manufacturing Extension Guide

## Add a new manufacturing entity

1. Define entity in `lib/features/manufacturing/domain/entities/` with `entityTypeName`, `toPayload`, `fromPayload`.
2. Add repository methods to the appropriate interface in `manufacturing_repositories.dart`.
3. Implement in `manufacturing_repository_impl.dart`.
4. Add application service methods with audit + RBAC.
5. Register sync processor in `manufacturing_providers.dart` and `manufacturing_module_initializer.dart`.
6. Add Supabase table in a new migration with RLS.
7. Add route/page if user-facing.

## Add engine rule

Extend `ManufacturingEngine` only — never duplicate logic in services or widgets.

## Add integration

Subscribe in `ManufacturingIntegrationService` to inventory/accounting/HR events.

## Add permission

Add constant in `permission_codes.dart` under `ManufacturingPermissions` (or sub-groups).

## Add domain event

Add class + `DomainEventTypes` constant in `business_events.dart`; publish from engine or service.
