# Performance Report — RC1

## Architecture Performance Characteristics

| Pattern | Benefit |
|---------|---------|
| Offline-first Drift | Sub-ms local reads; no network for UI lists |
| Paginated repositories | `RepositoryQuery` with pageSize limits |
| Lazy Riverpod providers | Services created on demand |
| Pure business engines | No I/O in hot paths; testable & fast |
| Sync delta pull | Only changed records since last sync |

## Areas Reviewed

| Area | Status | Notes |
|------|--------|-------|
| Stream disposal | ✅ Providers use ref.onDispose where needed |
| Controller disposal | ✅ StatefulWidget patterns follow Flutter best practices |
| Image caching | ✅ AppImageCache configured at bootstrap |
| Large list pagination | ✅ BaseLocalRepository.getPage() |
| Batch sync operations | ✅ SyncCoordinator processes queue in batches |
| Memory (global providers) | ⚠️ DomainEventBus lives for app lifetime — acceptable |
| Background job execution | ⚠️ Scheduler engine computes schedules; no isolate worker yet |

## Known Performance Gaps

1. **Analytics charts** — lightweight custom rendering (no fl_chart); sufficient for RC1
2. **Audit explorer** — loads 500 records max per query; pagination UI needed for large tenants
3. **Full-text search** — uses searchName/searchSku indexes; not full PostgreSQL FTS

## Recommendations

- Profile sync pull on 10k+ records per entity type
- Add `ListView.builder` audit on all new list pages
- Consider Drift isolate for heavy report generation in v2
