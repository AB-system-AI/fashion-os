# Rollback Checklist — RC2

## When to Rollback

- Critical data corruption detected
- Authentication completely broken
- Sync causing data loss
- Security vulnerability discovered post-deploy

## Application Rollback

- [ ] Identify previous stable build artifact (RC1 or prior RC2 candidate)
- [ ] Redeploy previous app version to app stores / distribution
- [ ] Verify previous version connects to compatible backend
- [ ] Notify users if forced update required

## Database Rollback

> Migrations are forward-only. Schema rollback is NOT supported.

- [ ] Restore database from pre-deployment backup
- [ ] Verify backup timestamp is before failed deployment
- [ ] Re-apply migrations only if restoring to empty DB
- [ ] Document any data loss window

## Permission Rollback

If RC2 permission namespaces cause access issues:

- [ ] Temporarily grant both legacy and RC2 codes to admin role
- [ ] Or restore role_definitions from backup
- [ ] Fix seed script and re-deploy

## Sync Queue Recovery

- [ ] Pause sync coordinator if runaway push detected
- [ ] Inspect `sync_queue` for failed entries
- [ ] Clear poisoned queue items after root cause fix
- [ ] Re-enable sync and monitor

## Communication

- [ ] Incident channel opened
- [ ] Root cause documented
- [ ] Post-mortem scheduled within 48 hours

## Recovery Verification

- [ ] Auth works
- [ ] Core POS flow works
- [ ] No sync errors in logs
- [ ] Tenant data intact
