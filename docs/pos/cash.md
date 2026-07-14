# Cash Drawer

## Session lifecycle

1. **Open** — `CashDrawerService.openSession` with opening float; one open session per register.
2. **Sales** — completed sales update session expected cash and totals.
3. **Movements** — safe drop, cash in/out, expense recorded via `CashMovement`.
4. **Close** — count actual cash; difference computed; `CashSessionClosedEvent` published.

## Permissions

- `sale.cash` — open session, movements
- `sale.close_session` — close with manager approval workflow (UI hook)

## Tables

- `cash_sessions`
- `cash_session_movements` (local entity: `cash_movement`)
