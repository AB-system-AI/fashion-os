/// Local sync status for offline-first entities.
enum LocalSyncStatus {
  synced,
  pending,
  syncing,
  conflict,
  failed;

  String get value => name;

  static LocalSyncStatus fromValue(String value) {
    return LocalSyncStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LocalSyncStatus.pending,
    );
  }
}

/// Sync queue item processing status.
enum SyncQueueStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled;

  String get value => name;

  static SyncQueueStatus fromValue(String value) {
    return SyncQueueStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SyncQueueStatus.pending,
    );
  }
}

/// Sync operation type.
enum SyncOperation {
  create,
  update,
  delete,
  restore;

  String get value => name;

  static SyncOperation fromValue(String value) {
    return SyncOperation.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SyncOperation.update,
    );
  }
}

/// Conflict resolution strategies — configurable per entity or operation.
enum ConflictResolutionStrategy {
  serverWins,
  clientWins,
  lastWriteWins,
  manualMerge,
  custom;

  String get value => name;

  static ConflictResolutionStrategy fromValue(String value) {
    return ConflictResolutionStrategy.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ConflictResolutionStrategy.lastWriteWins,
    );
  }
}

/// Overall sync engine state.
enum SyncEngineState {
  idle,
  syncing,
  paused,
  offline,
  failed;

  String get value => name;
}

/// Sync trigger source.
enum SyncTrigger {
  manual,
  automatic,
  background,
  networkRecovery,
  scheduled;

  String get value => name;
}

/// Network connection classification.
enum NetworkConnectionType {
  wifi,
  mobile,
  ethernet,
  offline,
  unknown;

  String get value => name;
}

/// Network quality level.
enum NetworkQuality {
  excellent,
  good,
  poor,
  captivePortal,
  offline;

  String get value => name;
}
