# Workflow Reports

## Overview

Workflow reporting aggregates execution outcomes and approval analytics for operational visibility.

## Entities

| Entity | Table | Metrics |
|--------|-------|---------|
| `WorkflowExecution` | `wf_executions` | Runtime instances |
| `WorkflowExecutionLog` | `wf_execution_logs` | Step-level audit |
| `WorkflowStatistics` | `wf_statistics` | Period aggregates |
| `ApprovalAnalyticsSnapshot` | computed | Approval KPIs |

## Service

`WorkflowReportService`:

- `loadStatistics()` — list stored period aggregates
- `aggregatePeriod()` — compute and persist stats for a template and date range

`ApprovalExtendedService.loadAnalytics()` — approval counts and pattern breakdown.

## UI

- `/workflows/reports` — execution statistics
- `/workflows/approval-analytics` — approval KPI cards

## Key metrics

- Total / completed / failed executions
- Success rate and average duration
- Approval rate and average resolution time
