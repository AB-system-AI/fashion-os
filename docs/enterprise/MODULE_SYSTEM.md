# Module System

Fashion POS Enterprise uses a **feature-first, module-independent** architecture. Each module owns its domain, data, and presentation layers.

## Core Modules

| ID | Module | Route Prefix | Status |
|----|--------|--------------|--------|
| `auth` | Authentication | `/auth` | Implemented (Phase 3) |
| `dashboard` | Dashboard | `/dashboard` | Planned |
| `products` | Products | `/products` | Planned |
| `inventory` | Inventory | `/inventory` | Planned |
| `pos` | Point of Sale | `/pos` | Planned |
| `customers` | Customers | `/customers` | Planned |
| `suppliers` | Suppliers | `/suppliers` | Planned |
| `purchasing` | Purchasing | `/purchasing` | Planned |
| `accounting` | Accounting Ready | `/accounting` | Architecture only |
| `expenses` | Expenses | `/expenses` | Planned |
| `reports` | Reports | `/reports` | Planned |
| `notifications` | Notifications | `/notifications` | Planned |
| `settings` | Settings | `/settings` | Planned |
| `ai` | AI | `/ai` | Extension points only |

## Module Structure

```
lib/features/<module>/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   └── providers/
└── routing/
    └── <module>_router.dart
```

## Independence Rules

1. **No cross-feature imports** — modules communicate via:
   - Shared `lib/core/` services
   - Domain events (future event bus)
   - Navigation (GoRouter)

2. **Own providers** — each module defines `*_providers.dart`

3. **Own tests** — `test/features/<module>/`

4. **Own documentation** — `docs/<module>/README.md`

## Registration

```dart
// Future: custom vertical module
class PharmacyModule implements FashionModule {
  @override
  ModuleDescriptor get descriptor => const ModuleDescriptor(
    id: 'pharmacy',
    name: 'Pharmacy',
    routePrefix: '/pharmacy',
    dependencies: ['products', 'inventory', 'pos'],
    permissions: ['product.read', 'inventory.read'],
  );

  @override
  Future<void> onRegister() async { /* wire routes, providers */ }

  @override
  Future<void> onActivate() async {}

  @override
  Future<void> onDeactivate() async {}
}
```

## Vertical Support Without Core Changes

| Vertical | Extension Mechanism |
|----------|---------------------|
| Clothing/Shoes/Bags | Core catalog (variants: color × size) |
| Supermarket | `PluginSlots.supermarket` — weighted items, PLU |
| Pharmacy | `PluginSlots.pharmacy` — expiry, prescriptions |
| Restaurant | `PluginSlots.restaurant` — tables, modifiers |
| Electronics | Serial numbers via `metadata` JSONB + plugin |
| Cosmetics | Batch/lot via inventory plugin |

## Accounting Ready

Modules emit **journal-ready facts** without implementing full accounting:

- `sale_orders` + `sale_payments` → revenue entries
- `inventory_movements` → COGS entries
- `purchase_receipts` → AP entries

Future `accounting` module consumes these via read-only repository adapters.

## API Ready

Each module's repository interface is the contract for:

- Flutter UI (current)
- Web dashboard (future)
- Public REST API (future)
- Third-party integrations

Keep repository methods transport-agnostic.

## Checklist for New Modules

- [ ] `ModuleDescriptor` registered
- [ ] GoRouter routes with auth guards
- [ ] RLS policies for new tables
- [ ] Local SQLite mirror tables (if offline)
- [ ] Sync entity type in `sync_queue`
- [ ] Audit events for mutations
- [ ] Unit + widget tests
- [ ] `docs/<module>/README.md`
