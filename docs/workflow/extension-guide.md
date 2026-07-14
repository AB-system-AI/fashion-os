# Workflow Extension Guide

## Add a new workflow entity

1. Add entity in `domain/entities/` with `entityTypeName`, `fromPayload`, `toPayload`
2. Add repository interface in `workflow_repositories.dart`
3. Add `*LocalRepository` in `workflow_repository_impl.dart`
4. Add service method in `workflow_services.dart`
5. Register provider + sync processor in `workflow_providers.dart`
6. Register processor in `workflow_module_initializer.dart`
7. Add Supabase table + RLS in migration under `supabase/migrations/`
8. Add page and sub-route under `/workflows/...`

## Add a notification channel

1. Extend `NotificationChannel` in `business_enums.dart` if needed
2. Add `NoOpNotificationProvider` in `notification_engine.dart` provider registration (`business_providers.dart`)
3. Add workflow adapter in `notification_providers.dart`
4. Call `registerWorkflowNotificationProviders()` from `NotificationDispatchService`

## Add an approval pattern

1. Extend `ApprovalPatternType` in `workflow_enums.dart`
2. Add matching logic in `ApprovalPattern.matchesContext()` (`approval_extended.dart`)
3. Use via `ApprovalExtendedService.resolvePlan()`

## Add a designer action type

1. Extend `WorkflowActionType` in `workflow_enums.dart`
2. Handle in `WorkflowDesignerEngine.simulate()` trace output
3. Persist in `wf_template_versions.steps` JSONB

## Cross-module hooks

- Reuse `NotificationEngine` from core — do not duplicate dispatch logic
- Reuse `ApprovalEngine` for matrix/delegation — extended patterns live in `approval_extended.dart`
- Keep automation module (`lib/features/automation/`) unchanged; workflow uses `wf_*` routes and tables
