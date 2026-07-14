# Offline Sync Report — RC1

## Sync Architecture

```
Local Write → SyncQueueWriter → sync_queue table
                    ↓
            SyncCoordinator (background)
                    ↓
            EntitySyncProcessor.push()
                    ↓
            Remote DataSource → Supabase

Remote Change → pullDelta() → RemoteSyncRecordMapper → Drift upsert
```

## Module Sync Processor Count

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
| **Automation** | **11** |
| **Integrations** | **8** |
| **System** | **19** |

## Conflict Resolution

- Optimistic versioning via `version` column
- Last-write-wins on version mismatch (standard pattern)
- `isDirty` flag on local records until sync confirmed

## Offline Capabilities (Phases 14–16)

| Module | Offline Create | Offline Read | Offline Update | Sync on Reconnect |
|--------|---------------|--------------|----------------|-------------------|
| Automation rules | ✅ | ✅ | ✅ | ✅ |
| Workflows | ✅ | ✅ | ✅ | ✅ |
| Scheduled jobs | ✅ | ✅ | ✅ | ✅ |
| Connectors | ✅ | ✅ | ✅ | ✅ |
| Webhooks | ✅ | ✅ | ✅ | ✅ |
| Feature flags | ✅ | ✅ | ✅ | ✅ |
| System audit entries | ✅ | ✅ | ✅ | ✅ |

## Retry Queue

- IntegrationConnectorEngine: exponential backoff for connector calls
- Automation job_queue entity: failed job retry tracking
- Sync queue: standard retry on push failure

## Verification

```bash
flutter test test/features/automation/automation_sync_processor_test.dart
flutter test test/features/integrations/integrations_sync_processor_test.dart
flutter test test/features/system/system_sync_processor_test.dart
```
