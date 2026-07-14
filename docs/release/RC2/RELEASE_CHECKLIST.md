# Release Checklist — RC2

## Build & Verify

- [ ] `dart pub get`
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter analyze` — 0 errors
- [ ] `flutter test` — all green
- [ ] Android debug build succeeds
- [ ] iOS debug build succeeds (if applicable)
- [ ] Windows debug build succeeds

## Database

- [ ] `supabase db push` applies migrations 01–18
- [ ] RLS policies verified on migrations 16–18
- [ ] Seed admin role with RC2 namespaced permission codes

## Functional Smoke Tests

### Foundation Page
- [ ] All 16 module buttons navigate correctly

### Treasury (`/treasury`)
- [ ] Dashboard loads
- [ ] Cash management CRUD offline → syncs
- [ ] Payment voucher with approval workflow
- [ ] Bank reconciliation page loads
- [ ] Forecast page displays projections

### Assets (`/assets`)
- [ ] Dashboard loads
- [ ] Asset register list/create
- [ ] Depreciation run
- [ ] Maintenance request create/complete
- [ ] Disposal workflow

### Workflow (`/workflow`)
- [ ] Dashboard loads
- [ ] Approval inbox displays pending items
- [ ] Approve/reject actions
- [ ] Notification center loads
- [ ] Approval templates list

### Regression (Prior Modules)
- [ ] Auth login/logout
- [ ] Product catalog CRUD
- [ ] POS sale flow
- [ ] Sales OMS quotation → order
- [ ] Automation rule create
- [ ] System audit explorer

## Security

- [ ] No secrets in committed files
- [ ] Permission namespaces verified (no collision)
- [ ] Tenant isolation verified

## Documentation

- [ ] `docs/release/RC2/RC2_IMPLEMENTATION_REPORT.md` reviewed
- [ ] All RC2 reports present in `docs/release/RC2/`
- [ ] Module docs for treasury, assets, workflow

## Tag & Release

- [ ] Git tag `v1.0.0-rc2`
- [ ] Release notes published
- [ ] Handoff to QA team
