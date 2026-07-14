# Scheduling

## Schedule types

| Type | Use case |
|------|----------|
| `once` | Single run at `run_at` |
| `delayed` | Run after `interval_seconds` |
| `recurring` | Fixed interval repeats |
| `cron` | Cron expression (5–6 fields) |

## Components

- **ScheduledJob** — definition with next/last run timestamps
- **JobQueueItem** — concrete queued execution instance
- **SchedulerEngine** — pure logic for due detection and next-run computation
- **SchedulerService** — persistence and enqueue operations

## Flow

1. `SchedulerService.schedule` creates job with computed `next_run_at`
2. Background worker calls `enqueueDue` to create queue items
3. Execution recorded in `automation_executions`
