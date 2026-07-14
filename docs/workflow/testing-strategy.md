# Workflow Testing Strategy

## Unit tests

| File | Coverage |
|------|----------|
| `test/features/workflow/approval_engine_test.dart` | Matrix resolution, delegation, escalation, workflow integration |
| `test/features/workflow/workflow_permissions_test.dart` | Permission code stability |
| `test/features/workflow/workflow_sync_processor_test.dart` | Entity type → remote table mapping |

## Run

```bash
flutter test test/features/workflow/
```

## Future coverage

- ApprovalService approve/reject with mocked repositories
- ReminderSchedulerService and EscalationService integration
- Widget tests for dashboard pages with permission gates
