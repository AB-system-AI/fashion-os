# Post Go-Live Checklist — RC2

## Day 1

- [ ] Monitor error logs every 2 hours
- [ ] Review sync queue depth
- [ ] Check auth success rate
- [ ] Verify first production sales processed
- [ ] Confirm treasury vouchers posting correctly
- [ ] Triage user-reported issues

## Week 1

- [ ] Daily sync health review
- [ ] Permission/access issues triaged (especially RC2 namespace changes)
- [ ] Performance compared to staging baseline
- [ ] Collect user feedback on Treasury, Assets, Workflow UIs
- [ ] Review failed automation/workflow jobs

## Week 2–4

- [ ] Weekly security log review
- [ ] Backup restore drill (staging)
- [ ] Address P1/P2 bugs from go-live
- [ ] Update KNOWN_LIMITATIONS if new issues found
- [ ] Plan v1.0.0 production hardening items

## Metrics Review

| Metric | Target | Actual |
|--------|--------|--------|
| App crash rate | < 0.1% sessions | |
| Sync success rate | > 99% | |
| Auth failure rate | < 2% | |
| Avg approval turnaround | Per SLA | |
| User adoption (active tenants) | Per plan | |

## Documentation Updates

- [ ] Update runbooks with production-specific notes
- [ ] Document any hotfixes applied
- [ ] Publish post-go-live retrospective
- [ ] Update FUTURE_ROADMAP based on feedback

## RC2 Permission Migration Follow-Up

- [ ] Confirm all tenant roles migrated to namespaced codes
- [ ] Remove legacy permission codes from roles (if dual-granted during cutover)
- [ ] Audit permission_denied events in logs

## Handoff to Operations

- [ ] On-call runbook delivered
- [ ] Monitoring dashboards shared
- [ ] Escalation contacts updated
- [ ] RC2 marked stable or RC3 planned
