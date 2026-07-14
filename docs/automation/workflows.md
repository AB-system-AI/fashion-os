# Workflows

## AutomationWorkflow

Multi-step automation triggered by entity events or manual invocation.

## WorkflowStep types

- `action` — execute a configured action
- `condition` — branch on context
- `approval` — pause for human approval
- `delay` — wait before next step
- `notification` — send templated notification

## Lifecycle

1. Create workflow with steps (`WorkflowAutomationService.create`)
2. Activate after validation (`activate`)
3. Trigger via `AutomationService.triggerEvent` or scheduler
4. Steps execute in `step_order` sequence

## Integration

Uses core `WorkflowEngine` for step advancement semantics. Workflow definitions are tenant-scoped and synced via `automation_workflows` / `workflow_steps` tables.
