# Release Checklist — RC1

## Build & Verify

- [ ] `dart pub get`
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter analyze` — 0 errors
- [ ] `flutter test` — all green
- [ ] Android debug build succeeds
- [ ] iOS debug build succeeds (if applicable)
- [ ] Windows debug build succeeds

## Database

- [ ] `supabase db push` applies migrations 01–15
- [ ] RLS policies verified on new tables (13–15)
- [ ] Seed data includes new permission codes for admin role

## Functional Smoke Tests

### Foundation Page
- [ ] All 14 module buttons navigate correctly

### Automation (`/automation`)
- [ ] Dashboard loads
- [ ] Create automation rule offline → syncs on reconnect
- [ ] Scheduled job list displays
- [ ] Execution logs page loads
- [ ] AI assistant page loads (NoOp responses)

### Integrations (`/integrations`)
- [ ] Dashboard loads
- [ ] Connector list/create
- [ ] Webhook list/create
- [ ] API key list
- [ ] Import/export hub opens
- [ ] Health status page shows connector health

### System (`/system`)
- [ ] Dashboard loads
- [ ] Feature flags toggle
- [ ] Audit explorer shows entries
- [ ] Permission/role manager pages load
- [ ] Health monitor displays
- [ ] Sync monitor displays
- [ ] Maintenance mode toggle
- [ ] Diagnostics page runs checks

### Regression (Prior Phases)
- [ ] Auth login/logout
- [ ] Product catalog CRUD
- [ ] POS sale flow
- [ ] Sales OMS quotation → order
- [ ] Manufacturing production order

## Security

- [ ] No secrets in committed files
- [ ] API keys stored as hashes only
- [ ] Tenant isolation verified (cross-tenant read blocked)

## Documentation

- [ ] `docs/release/RC1_IMPLEMENTATION_REPORT.md` reviewed
- [ ] Module README files present for automation, integrations, system

## Tag & Release

- [ ] Git tag `v1.0.0-rc1`
- [ ] Release notes published
- [ ] Handoff to QA team
