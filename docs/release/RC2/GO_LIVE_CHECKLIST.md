# Go-Live Checklist — RC2

## T-7 Days

- [ ] RC2 staging sign-off complete
- [ ] UAT test cases passed
- [ ] Performance baseline established
- [ ] Security review complete
- [ ] Training materials distributed

## T-3 Days

- [ ] Production Supabase project provisioned
- [ ] Migrations 01–18 applied to production
- [ ] Admin users and roles seeded with RC2 permissions
- [ ] Production `.env` configured (not committed)
- [ ] Backup verified (see BACKUP_CHECKLIST.md)

## T-1 Day

- [ ] Production app build signed and uploaded
- [ ] DNS / deep links configured (if applicable)
- [ ] Monitoring alerts active (see MONITORING_CHECKLIST.md)
- [ ] Support team on standby
- [ ] Rollback plan reviewed with team

## Go-Live Day (T-0)

### Morning
- [ ] Final database backup
- [ ] Deploy production app (or enable store release)
- [ ] Smoke test: login → foundation → POS sale
- [ ] Smoke test: treasury payment voucher
- [ ] Smoke test: approval workflow

### Cutover
- [ ] Legacy system read-only (if migrating)
- [ ] Data migration complete (if applicable)
- [ ] Users notified of go-live

### Evening
- [ ] Monitor error rates for 4 hours
- [ ] Review sync queue health
- [ ] Confirm no critical incidents

## Go/No-Go Criteria

| Criterion | Required |
|-----------|----------|
| `flutter test` all pass | Yes |
| Staging UAT sign-off | Yes |
| RLS verified | Yes |
| Backup confirmed | Yes |
| Rollback plan ready | Yes |
| On-call assigned | Yes |

## Sign-Off

| Role | Name | Date | Approved |
|------|------|------|----------|
| Product Owner | | | [ ] |
| Tech Lead | | | [ ] |
| QA Lead | | | [ ] |
| Operations | | | [ ] |
