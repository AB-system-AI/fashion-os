# Dependency Audit Report — RC2

**Date:** 2026-07-14

## Core Dependencies

| Package | Version Constraint | Purpose | Risk |
|---------|-------------------|---------|------|
| flutter_riverpod | ^2.6.1 | State management & DI | Low |
| go_router | ^15.1.2 | Navigation | Low |
| drift | ^2.22.1 | Local SQLite | Low |
| supabase_flutter | ^2.9.0 | Remote backend | Low |
| sqlcipher_flutter_libs | ^0.6.6 | DB encryption | Low |
| flutter_secure_storage | ^9.2.4 | Token storage | Low |

## Internal Module Dependency Graph

| Consumer | Depends On |
|----------|------------|
| Treasury | Accounting (journal integration), Workflow (approvals) |
| Assets | Accounting (depreciation), Treasury (disposal proceeds) |
| Workflow | Automation engines, NotificationEngine |
| Automation | RuleEngine, WorkflowEngine, NotificationEngine |
| Integrations | ImportExportService, NotificationEngine |
| System | AuditService, SyncCoordinator |
| Sales OMS | Inventory, Manufacturing, CRM |
| Manufacturing | Inventory, Purchasing |
| POS | Products, Inventory, Customers, Accounting |

## Circular Dependency Check

- Domain layers do not import presentation ✅
- Feature modules import core, not each other's presentation ✅
- Cross-module via integration services only ✅

## External API Dependencies

**None required for RC2.** AI, OAuth, email, SMS, push remain abstracted with NoOp implementations.

## Dev Dependencies

| Package | Purpose |
|---------|---------|
| build_runner | Drift code generation |
| drift_dev | Schema codegen |
| mocktail | Test mocking |
| flutter_lints | Static analysis |

## Pre-Release Commands

```bash
dart pub get
dart pub outdated
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

## RC2 Dependency Changes

No new pubspec dependencies added in Phase 18. Hardening was audit/fix only.
