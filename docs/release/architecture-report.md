# Architecture Report — RC1

## Layer Diagram

```mermaid
flowchart TB
    subgraph presentation [Presentation Layer]
        Pages[Feature Pages]
        Providers[Riverpod Providers]
    end
    subgraph domain [Domain Layer]
        Entities[Syncable Entities]
        Services[Domain Services]
        Repos[Repository Interfaces]
        Engines[Business Engines]
    end
    subgraph data [Data Layer]
        RepoImpl[Repository Implementations]
        SyncProc[Sync Processors]
        Remote[Remote DataSources]
    end
    subgraph infra [Infrastructure]
        Drift[(Drift DB)]
        SyncQ[Sync Queue]
        Supa[(Supabase)]
    end
    Pages --> Providers --> Services
    Services --> Repos --> RepoImpl
    Services --> Engines
    RepoImpl --> Drift
    RepoImpl --> SyncQ
    SyncProc --> Remote --> Supa
    SyncQ --> SyncProc
```

## Cross-Cutting Concerns

| Concern | Implementation |
|---------|----------------|
| DI | Riverpod providers per module + `bootstrap.dart` initializers |
| Events | `DomainEventBus` for cross-module business events |
| Numbers | `NumberGeneratorEngine` with tenant-scoped sequences |
| Permissions | `PermissionEngine` + `permission_codes.dart` |
| Audit | `AuditService` on all mutating service methods |
| Offline | Drift `syncable_records` + `SyncQueueWriter` |
| Encryption | SQLCipher-compatible Drift database |

## Module Dependency Graph (simplified)

- **Automation** → RuleEngine, WorkflowEngine, NotificationEngine
- **Integrations** → ImportExportService, NotificationEngine
- **System** → AuditService, SyncCoordinator
- **Sales OMS** → InventoryEngine, ManufacturingEngine, CRM
- **Analytics** → cross-module report services (read-only)

## Folder Structure Standard

```
lib/features/{module}/
  domain/entities|enums|repositories|services|value_objects
  data/datasources|repositories|sync
  presentation/pages|providers|widgets
  routing/
  di/
```

All 16 modules conform to this structure.
