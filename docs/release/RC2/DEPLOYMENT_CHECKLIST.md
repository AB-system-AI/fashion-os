# Deployment Checklist — RC2

## Pre-Deployment

- [ ] RC2 release checklist complete
- [ ] Staging environment validated
- [ ] Database backup taken (see BACKUP_CHECKLIST.md)
- [ ] Rollback plan reviewed (see ROLLBACK_CHECKLIST.md)

## Supabase Setup

- [ ] Production project created/isolated
- [ ] Migrations 01–18 applied
- [ ] RLS policies enabled on all tables
- [ ] Auth settings configured (email, session duration)
- [ ] Storage buckets created (if using media)
- [ ] Edge functions deployed (if any)

## Application Build

- [ ] Production flavor `.env.production` configured
- [ ] `AppFlavor.production` build
- [ ] Code signing certificates valid (iOS/Android)
- [ ] Version bumped in `pubspec.yaml`

## Environment Variables

| Variable | Set |
|----------|-----|
| SUPABASE_URL | [ ] |
| SUPABASE_ANON_KEY | [ ] |
| LOG_LEVEL | [ ] production = warn/error |

## Post-Deploy Verification

- [ ] App launches and authenticates
- [ ] Foundation page → each module loads
- [ ] Offline create → reconnect → sync succeeds
- [ ] Admin can access System Admin
- [ ] Monitoring alerts configured (see MONITORING_CHECKLIST.md)

## Communication

- [ ] Stakeholders notified of deployment window
- [ ] Support team briefed on RC2 changes
- [ ] Release notes distributed
