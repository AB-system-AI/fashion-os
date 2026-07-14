# Riverpod Provider Lifetime Strategy

Phase 4.2 optimizes memory for feature-scoped state while keeping infrastructure singletons alive.

## Global (keep alive)

These providers must survive for the app session:

- `appDatabaseProvider`, `syncCoordinatorProvider`, `networkMonitorProvider`
- `authControllerProvider`, `permissionEngineProvider`
- `mediaEngineProvider` (after bootstrap), `productCatalogServiceProvider`

## Auto-dispose (feature scoped)

| Provider | Rationale |
|---|---|
| `productListControllerProvider` | List state discarded when leaving product list route |
| `productMediaGalleryControllerProvider` (family) | Gallery state per product; disposed when page closes |

## Selective rebuilds

- `productDataPortAdapterProvider` watches `authControllerProvider.select((s) => s.user?.tenantId)` to avoid rebuilding on unrelated auth state changes.

## Bootstrap order

`infrastructureInitializerProvider`:

1. Database
2. **Media key + vault** (`mediaInitializerProvider`)
3. Network monitor
4. Sync coordinator (crash recovery)
5. Background tasks, analytics, feature flags

Media-dependent providers throw until step 2 completes.

## Guidelines

- Use `autoDispose` on `NotifierProvider` / family controllers tied to a single page.
- Do **not** auto-dispose sync, database, or auth infrastructure.
- Prefer `ref.read` in imperative service methods; use `ref.watch` only in widgets/controllers that need rebuilds.
