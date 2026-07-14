# Automation Architecture

## Layers

```
presentation/     → pages, providers, routes
domain/           → entities, repositories, services, AI abstractions
data/             → repository impl, remote datasource, sync processors
core/business/    → AutomationEngine, SchedulerEngine (pure logic)
```

## Engines

- **AutomationEngine** — orchestrates `RuleEngine` and `WorkflowEngine`, approvals, suggestions, execution lifecycle.
- **SchedulerEngine** — cron/recurring/delayed scheduling, due-job detection, priority sorting.

## Entity types (sync)

`automation_rule`, `automation_workflow`, `workflow_step`, `scheduled_job`, `job_queue_item`, `automation_execution`, `automation_log`, `approval_workflow`, `approval_request`, `document_template`, `automation_settings`

## Permissions

| Group | Codes |
|-------|-------|
| AutomationPermissions | `automation.view`, `automation.manage` |
| WorkflowPermissions | `workflow.manage` |
| RulePermissions | `rule.manage` |
| SchedulerPermissions | `scheduler.manage` |
| ApprovalWorkflowPermissions | `approval.manage` |
| AiPermissions | `ai.view` |
