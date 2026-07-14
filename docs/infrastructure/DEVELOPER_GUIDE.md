# Infrastructure Developer Guide

## Adding a New Feature Module

1. **Define entity** implementing `SyncableEntity` or use `LocalRecord` directly
2. **Create repository** extending `BaseLocalRepository`
3. **Register sync processor** implementing `EntitySyncProcessor`
4. **Wire providers** in feature `*_providers.dart`
5. **Never access Drift directly from UI** — always through repository

## Repository Example

```dart
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});
```

## Sync Processor Example

```dart
class ProductSyncProcessor implements EntitySyncProcessor {
  @override
  String get entityType => 'product';

  @override
  Future<SyncProcessResult> push(Map<String, dynamic> queueItem) async {
    // Push to Supabase, detect conflicts
    return const SyncProcessResult(success: true);
  }

  @override
  Future<void> pullDelta({
    required String tenantId,
    required String deviceId,
    required DateTime since,
    required int sinceVersion,
  }) async {
    // Incremental pull from server
  }
}
```

Register in bootstrap or feature init:

```dart
ref.read(syncCoordinatorProvider).registerProcessor(ProductSyncProcessor());
```

## Conflict Resolution

Configure per entity:

```dart
ConflictResolver(
  defaultStrategy: ConflictResolutionStrategy.lastWriteWins,
  entityStrategies: {
    'product': ConflictResolutionStrategy.serverWins,
    'sale': ConflictResolutionStrategy.clientWins,
  },
);
```

## Feature Flags

```dart
final enabled = await ref.read(featureFlagServiceProvider).isEnabled('new_pos_ui');
```

## Logging

```dart
await ref.read(centralLoggerProvider).info('Sale completed', {'sale_id': id});
```

## Testing

Use in-memory database:

```dart
final db = AppDatabase.inMemory();
await db.executor.ensureOpen(db);
```

See [TESTING_STRATEGY.md](./TESTING_STRATEGY.md).
