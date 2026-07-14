# Rules

## AutomationRule

IF-THEN business rules evaluated against event context.

## Structure

- **Trigger** — `TriggerEventType` + optional `trigger_entity_type`
- **Condition** — field, operator, value (mapped to `RuleEngine`)
- **Action** — type + parameters (notify, webhook, etc.)

## Lifecycle

1. Create rule (`RuleAutomationService.create`)
2. Activate (`activate`) — sets status to `active`
3. On matching events, `AutomationEngine.evaluateAndExecuteRules` runs via `RuleEngine`

## Priority

Higher `priority` rules evaluate first. Inactive or draft rules are skipped.
