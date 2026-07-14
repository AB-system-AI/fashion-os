# Automation Testing Strategy

## Unit tests

| File | Coverage |
|------|----------|
| `automation_engine_test.dart` | Rule evaluation, workflow planning, suggestions, summary |
| `scheduler_engine_test.dart` | Cron validation, next-run, due detection, priority |
| `automation_sync_processor_test.dart` | Entity type → table mapping |
| `automation_permissions_test.dart` | Permission code stability |

## Integration tests (future)

- End-to-end rule trigger → execution → log
- Scheduler enqueue → queue item creation
- Approval request → resolve flow

## Widget tests (future)

- Dashboard permission gating
- Rule designer create/activate flow

Run: `flutter test test/features/automation/`
