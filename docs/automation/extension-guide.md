# Automation Extension Guide

## Add a new action type

1. Register handler on `RuleEngine` via `registerActionHandler`
2. Map action type in rule designer UI
3. Document parameters schema

## Add a workflow step type

1. Extend `WorkflowStepType` enum
2. Handle in workflow runner (future background worker)
3. Add step config validation in `AutomationEngine.planWorkflow`

## Plug in a real AI provider

```dart
ref.read(aiProviderProvider.overrideWithValue(MyOpenAIProvider()));
```

## Add a new synced entity

1. Create entity with `SyncableEntity` + `entityTypeName`
2. Add repository interface + `AutomationRepositoryImpl` subclass
3. Register sync processor in `automation_providers.dart` and module initializer
4. Add migration table + RLS policies

## Cross-module triggers

Subscribe to `DomainEventBus` in a future integration service to fire `AutomationService.triggerEvent` on sales, inventory, or HR events.
