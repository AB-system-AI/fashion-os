# Integrations Extension Guide

## Add a new provider

1. Implement interface in `integration_abstractions.dart` (e.g. `EmailProvider`)
2. Register in `integrations_providers.dart` replacing NoOp
3. Optionally add `IntegrationConnector` with matching `providerKey`

## Add a new synced entity

1. Domain entity with `entityTypeName`, `toPayload`, `fromPayload`
2. Repository interface + `IntegrationsRepositoryImpl` subclass
3. Sync processor provider mapping to Supabase table
4. Register in `integrations_module_initializer.dart`
5. Add migration table + RLS policies

## Cross-module hooks

`IntegrationsCrossModuleService` subscribes to `DomainEventBus` — add handlers for new events and call `WebhookService.dispatch`.

## Permissions

Add codes to `permission_codes.dart` and gate services with `PermissionEngine.require`.
