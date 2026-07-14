# Performance Report — RC2

**Date:** 2026-07-14

## Architecture Performance Characteristics

| Pattern | Benefit |
|---------|---------|
| Offline-first Drift reads | Sub-ms local queries for lists/dashboards |
| Sync queue batching | Reduces network round-trips on reconnect |
| Pagination via `RepositoryQuery` | Bounded memory for large datasets |
| `AppImageCache` configuration | Reduced image decode overhead |
| Lazy module initialization | Bootstrap loads modules sequentially; no eager fetch |

## Module-Specific Notes

### Treasury
- Cash/bank balance queries use indexed `tenant_id` + `account_id`
- Forecast projections computed in `TreasuryEngine` (in-memory, bounded periods)

### Assets
- Depreciation runs batch-process assets by category
- Asset register uses paginated list queries

### Workflow
- Approval inbox filtered by assignee + status (indexed columns in migration 18)

## Known Performance Limits

| Area | Limit | Mitigation |
|------|-------|------------|
| Analytics reports | Large date ranges may be slow | Pre-aggregate; schedule reports |
| Sync pull on reconnect | Proportional to pending delta | Incremental `pullDelta` |
| Image gallery | Many hi-res images | Thumbnail generation + cache |
| Cron scheduler | In-process only | Platform worker for production |

## Benchmark Recommendations

```bash
# Profile widget rebuilds
flutter run --profile

# Measure sync throughput
# Create 100 offline records → reconnect → measure sync completion
```

## RC2 Performance Verdict

No performance regressions introduced in Phase 18. Permission namespace changes are compile-time constants with zero runtime cost.
