# Workflow Scheduler

## Overview

Workflow scheduling complements the automation module's `SchedulerEngine` with tenant-scoped job records for workflow reminders, escalations, and report aggregation.

## Core engine

`WorkflowSchedulerEngine` (`lib/core/business/engines/workflow/scheduler_engine.dart`):

- Cron validation (5–6 field expressions)
- Next-run computation for once, delayed, recurring, and cron schedules
- Priority queue ordering for due jobs
- Retry with exponential backoff via `retryDelaySeconds`
- Health evaluation (`SchedulerHealth`)

## Domain model

| Entity | Table |
|--------|-------|
| `ScheduledJobRecord` | `scheduler_jobs` |
| `JobExecutionLog` | `scheduler_execution_logs` |
| `SchedulerHealth` | computed in-memory |

## Service

`SchedulerService.processDueJobs()` marks jobs running, writes execution logs, and completes or retries failed runs.

## UI

`/workflows/scheduler` — health metrics and manual "process due jobs" action.

## Relation to automation

`lib/core/business/engines/automation/scheduler_engine.dart` remains for the automation feature module. Workflow uses workflow-domain entities and `wf_*` / `scheduler_*` tables to avoid coupling.
