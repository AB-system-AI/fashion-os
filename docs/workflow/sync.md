# Workflow Sync

## Processors (10)

| Entity | Local type | Remote table |
|--------|------------|--------------|
| Tenant workflow definition | `wf_definition` | `wf_definitions` |
| Tenant workflow instance | `wf_instance` | `wf_instances` |
| Approval template | `wf_approval_template` | `wf_approval_templates` |
| Approval matrix | `wf_approval_matrix` | `wf_approval_matrices` |
| Approval request | `wf_approval_request` | `wf_approval_requests` |
| Approval history | `wf_approval_history` | `wf_approval_history` |
| Approval delegation | `wf_approval_delegation` | `wf_approval_delegations` |
| Notification | `wf_notification` | `wf_notifications` |
| Reminder rule | `wf_reminder_rule` | `wf_reminder_rules` |
| Escalation rule | `wf_escalation_rule` | `wf_escalation_rules` |

Registered in `workflowModuleInitializerProvider` during bootstrap.

## Migration

`supabase/migrations/20250712000018_workflow_enterprise.sql`

All tables are tenant-scoped with soft-delete (`deleted_at`) and `version` for optimistic concurrency.
