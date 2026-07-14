# Workflow Architecture

## Layering

```
lib/features/workflow/
├── domain/          entities, enums, repositories, services
├── data/            remote datasource, local repositories, sync processors
├── presentation/    pages, Riverpod providers
├── routing/         /workflows, /approvals, /notifications
└── di/              module initializer (sync registration)
```

## Core engines (reused, not duplicated)

| Engine | Location | Role |
|--------|----------|------|
| `WorkflowEngine` | `lib/core/business/engines/workflow_engine.dart` | Step advancement, reject, cancel |
| `ApprovalEngine` | `lib/core/business/engines/workflow/approval_engine.dart` | Matrix resolution, delegation, escalation, history |
| `NotificationEngine` | `lib/core/business/engines/notification_engine.dart` | Multi-channel dispatch |

`ApprovalEngine` wraps `WorkflowEngine` for approval-driven step transitions.

## Services

- **WorkflowAdminService** — dashboard metrics, definition listing
- **ApprovalService** — pending list, approve/reject with matrix validation
- **NotificationCenterService** — unread inbox, mark read, in-app dispatch
- **ReminderSchedulerService** — interval reminders for pending approvals
- **EscalationService** — timeout-based escalation with notifications

## Separation from automation

The existing `lib/features/automation/` module and `/automation` routes remain unchanged. Workflow uses `wf_*` tables and `/workflows` routes to avoid conflicts.
