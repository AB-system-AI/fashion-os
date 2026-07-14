# Known Limitations — RC2

> Carries forward RC1 limitations. See `docs/release/known-limitations.md` for Phase 14–16 detail.

## Phase 18 — Production Hardening

| Limitation | Impact | Workaround |
|------------|--------|------------|
| Permission seed migration manual | Existing tenants need role updates for namespaced codes | Run seed script mapping legacy → RC2 codes |
| Flutter/Dart not in CI sandbox | Automated analyze/test requires local/CI runner | Configure GitHub Actions with Flutter SDK |

## Treasury

| Limitation | Impact | Workaround |
|------------|--------|------------|
| Bank feed import not integrated | Manual reconciliation only | CSV import via Integrations hub |
| Cheque printing stub | Cheque records only | Wire printer profile from Integrations |
| Multi-currency FX rates manual | No live rate feed | Configure rates in treasury settings |

## Assets

| Limitation | Impact | Workaround |
|------------|--------|------------|
| Barcode/RFID asset tagging stub | Manual asset lookup | Integrate scanner SDK |
| Physical audit mobile workflow basic | List-based audit UI | Enhance with camera/barcode |
| Lease accounting (IFRS 16) partial | Contract tracking only | Full lease engine in v1.2 |

## Workflow

| Limitation | Impact | Workaround |
|------------|--------|------------|
| Visual workflow designer not implemented | Template list only | Use Automation rule designer |
| Delegation rules basic | Single assignee per step | Multi-assignee in v1.1 |
| SLA breach auto-escalation computed only | No background worker | Platform scheduler integration |

## Carryover from RC1

- AI/communication providers are NoOp
- MFA abstraction only
- Route-level permission guards not in GoRouter redirect
- Picking/packing scaffolds in Sales OMS
- CI pipeline not in repository
- Localization incomplete for new module strings

## Platform

| Limitation | Notes |
|------------|-------|
| `flutter analyze` / `flutter test` | Must be run in environment with Flutter SDK |
| E2E tests | No live Supabase integration tests |
