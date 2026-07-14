# FashionOS Enterprise Workflow, Approvals & Notifications

Phase 16 PARTIAL delivers tenant-configurable workflows, approval matrices, delegation, escalation, and an in-app notification center — offline-first with sync, separate from the `/automation` module.

## Quick start

1. Bootstrap registers `workflowModuleInitializerProvider` (10 sync processors).
2. Navigate to `/workflows` from Foundation ("Open Workflows").
3. Sub-routes: `/approvals`, `/notifications`, `/workflows/approval-templates`, `/workflows/escalation-rules`.

## Permissions

| Permission | Code |
|------------|------|
| Workflow admin | `workflow.admin` |
| View approvals | `approval.view` |
| Manage approvals | `approval.manage` |
| View notifications | `notification.view` |
| Manage notifications | `notification.manage` |

## Related docs

- [architecture.md](architecture.md)
- [approvals.md](approvals.md)
- [notifications.md](notifications.md)
- [sync.md](sync.md)
- [testing-strategy.md](testing-strategy.md)
