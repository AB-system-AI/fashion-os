# Monitoring Checklist — RC2

## Application Monitoring

- [ ] Error logging enabled (`AppLogger` level appropriate for production)
- [ ] Crash reporting integrated (Sentry/Firebase Crashlytics recommended)
- [ ] Performance monitoring for slow screens (optional: Firebase Performance)

## Supabase Monitoring

- [ ] Database CPU/memory alerts configured
- [ ] Connection pool usage monitored
- [ ] Auth failure rate alert
- [ ] Storage usage alert
- [ ] API rate limit monitoring

## Sync Health

- [ ] System Admin → Sync Monitor reviewed daily
- [ ] Alert on sync queue depth > threshold (e.g., 500 pending)
- [ ] Alert on consecutive push failures > 10
- [ ] Weekly sync latency review

## Business Metrics (Dashboards)

| Metric | Source |
|--------|--------|
| Daily sales (POS) | Analytics / POS reports |
| Open purchase orders | Purchasing dashboard |
| Cash position | Treasury dashboard |
| Pending approvals | Workflow dashboard |
| Asset depreciation due | Assets dashboard |
| Failed automation jobs | Automation logs |

## Security Monitoring

- [ ] Login failure rate alert
- [ ] Unusual session count per user
- [ ] API key usage anomalies
- [ ] Supabase audit log review (weekly)

## On-Call

- [ ] Escalation path documented
- [ ] Runbook for common issues (sync stuck, auth down)
- [ ] Access to Supabase dashboard for on-call engineer

## RC2-Specific Checks

- [ ] Treasury voucher approval SLA breaches
- [ ] Workflow escalation rule triggers logged
- [ ] Asset maintenance overdue alerts
