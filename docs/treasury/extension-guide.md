# Treasury Extension Guide

## Add a new treasury entity

1. Add entity in `domain/entities/` with `entityTypeName`, `fromPayload`, `toPayload`
2. Add repository interface in `treasury_repositories.dart`
3. Add `*LocalRepository` in `treasury_repository_impl.dart`
4. Add service method in `treasury_services.dart`
5. Register provider + sync processor in `treasury_providers.dart`
6. Register processor in `treasury_module_initializer.dart`
7. Add Supabase table + RLS in migration
8. Add page and route under `/treasury/...`

## Add document number type

1. Extend `DocumentNumberType` in `business_enums.dart`
2. Add format in `number_generator_engine.dart`
3. Use in service via `numberGenerator.next(type: ...)`

## Cross-module hooks

Subscribe to domain events in `TreasuryIntegrationService.register()` and audit integration metadata.
