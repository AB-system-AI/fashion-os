# Approvals

## Entities

- **ApprovalTemplate** — named template per entity type with `min_approvers`
- **ApprovalMatrix** — ordered steps with `required_role` and optional amount thresholds
- **ApprovalRequest** — runtime request linked to template and optional workflow instance
- **ApprovalHistory** — immutable audit trail (approved, rejected, delegated, escalated)
- **ApprovalDelegation** — time-bounded authority transfer between users

## ApprovalEngine

Pure logic in `lib/core/business/engines/workflow/approval_engine.dart`:

1. **resolveMatrix** — filter matrix rows by amount, sort by step order
2. **resolveApprover** — apply active delegations
3. **evaluateEscalation** — detect timeout breaches
4. **canActorApprove** — role check against current matrix step
5. **advanceWorkflowOnApproval** — delegate to core `WorkflowEngine`

## Flow

```
Request created → matrix resolved → approver assigned
     → approve (per step) → history recorded → workflow advanced
     → reject → workflow rejected
     → timeout → escalation rule → status escalated + notification
```

## Permissions

- `approval.view` — list pending approvals
- `approval.manage` — approve/reject actions
- `workflow.admin` — templates, matrices, escalation rules
