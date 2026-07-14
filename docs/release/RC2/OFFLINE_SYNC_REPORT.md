# Offline Sync Report — RC2

**Date:** 2026-07-14

## Sync Architecture

```
Local Write → SyncQueueWriter → sync_queue
                    ↓
            SyncCoordinator
                    ↓
            EntitySyncProcessor.push()
                    ↓
            Remote DataSource → Supabase

Remote Change → pullDelta() → Drift upsert
```

## Module Sync Processor Count (Full)

| Module | Processors |
|--------|------------|
| Products | 6+ |
| Inventory | 8+ |
| Purchasing | 6+ |
| Customers | 5+ |
| POS | 10+ |
| Accounting | 8+ |
| HR | 10+ |
| Manufacturing | 12+ |
| Analytics | 10 |
| Sales OMS | 14 |
| Automation | 11 |
| Integrations | 8 |
| System | 19 |
| **Treasury** | **12** |
| **Assets** | **14** |
| **Workflow** | **8** |

**Grand total:** 120+ entity sync processors

## RC2 Module Offline Capabilities

| Module | Offline Create | Offline Read | Offline Update | Sync on Reconnect |
|--------|---------------|--------------|----------------|-------------------|
| Treasury vouchers | ✅ | ✅ | ✅ | ✅ |
| Treasury bank movements | ✅ | ✅ | ✅ | ✅ |
| Asset register | ✅ | ✅ | ✅ | ✅ |
| Asset depreciation | ✅ | ✅ | ✅ | ✅ |
| Approval requests | ✅ | ✅ | ✅ | ✅ |
| Notifications | ✅ | ✅ | ✅ | ✅ |

## Conflict Resolution

- Optimistic versioning via `version` column
- Last-write-wins on version mismatch
- `isDirty` flag until sync confirmed

## Retry Strategy

- Sync queue: standard retry on push failure
- IntegrationConnectorEngine: exponential backoff
- Automation job_queue: failed job retry tracking

## Verification Tests

| Module | Test File |
|--------|-----------|
| Treasury | `treasury_sync_processor_test.dart` |
| Assets | `assets_sync_processor_test.dart` |
| Workflow | `workflow_sync_processor_test.dart` |

```bash
flutter test test/features/treasury/treasury_sync_processor_test.dart
flutter test test/features/assets/assets_sync_processor_test.dart
flutter test test/features/workflow/workflow_sync_processor_test.dart
```
