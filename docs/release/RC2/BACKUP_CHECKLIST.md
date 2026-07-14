# Backup Checklist — RC2

## Supabase Database

- [ ] Daily automated backups enabled (Supabase Pro+)
- [ ] Point-in-time recovery (PITR) enabled if available
- [ ] Backup retention policy documented (minimum 7 days)
- [ ] Monthly restore drill to staging

## Pre-Deployment Backup

- [ ] Full database dump before migration 16–18 apply
- [ ] Export `role_definitions` and `permission_assignments`
- [ ] Export `tenant` configuration
- [ ] Timestamp and store off-site

## Local Device Data (Drift)

- [ ] Users informed that local DB is device-specific
- [ ] Critical data must sync before device decommission
- [ ] SQLCipher key managed per device (not centrally backed up)

## Media / Storage

- [ ] Supabase Storage bucket backup policy
- [ ] Product images and attachments included in backup scope

## Configuration Backup

| Item | Location | Backed Up |
|------|----------|-----------|
| Environment settings | `environment_settings` table | [ ] |
| Feature flags | `feature_flags` table | [ ] |
| Approval templates | `approval_templates` table | [ ] |
| Automation rules | `automation_rules` table | [ ] |
| Integration connectors | `integration_connectors` table | [ ] |

## Recovery Testing

- [ ] Restore to staging environment quarterly
- [ ] Verify auth, products, POS after restore
- [ ] Document RTO (Recovery Time Objective): target < 4 hours
- [ ] Document RPO (Recovery Point Objective): target < 24 hours

## Disaster Recovery Contacts

- [ ] DBA / Supabase admin contact
- [ ] Application owner contact
- [ ] Cloud provider support tier documented
