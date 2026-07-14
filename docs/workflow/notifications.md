# Notifications

## Entities

- **NotificationCenterItem** — tenant-scoped in-app inbox entry
- **ReminderRule** — interval/cron reminders for pending approvals
- **EscalationRule** — timeout triggers with target role escalation
- **AutomationRuleRef** — optional link to automation module rules

## NotificationCenterService

Uses core `NotificationEngine` for channel dispatch and persists items locally for offline inbox.

Channels supported by the engine: `inApp`, `push`, `email`, `sms`, `whatsApp`, `background`.

## Reminder & escalation

- **ReminderSchedulerService** — compares `interval_hours` against request age, dispatches in-app reminders
- **EscalationService** — uses `ApprovalEngine.evaluateEscalation`, updates request status, notifies assignee

## Permissions

- `notification.view` — read inbox
- `notification.manage` — mark read, archive
