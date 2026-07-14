import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';

/// Sync progress snapshot for UI and monitoring.
class SyncProgress extends Equatable {
  const SyncProgress({
    required this.state,
    required this.trigger,
    this.total = 0,
    this.processed = 0,
    this.failed = 0,
    this.currentEntityType,
    this.message,
  });

  final SyncEngineState state;
  final SyncTrigger trigger;
  final int total;
  final int processed;
  final int failed;
  final String? currentEntityType;
  final String? message;

  double get fraction => total == 0 ? 0 : processed / total;

  SyncProgress copyWith({
    SyncEngineState? state,
    SyncTrigger? trigger,
    int? total,
    int? processed,
    int? failed,
    String? currentEntityType,
    String? message,
  }) {
    return SyncProgress(
      state: state ?? this.state,
      trigger: trigger ?? this.trigger,
      total: total ?? this.total,
      processed: processed ?? this.processed,
      failed: failed ?? this.failed,
      currentEntityType: currentEntityType ?? this.currentEntityType,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [state, trigger, total, processed, failed];
}

/// Sync lifecycle events emitted to subscribers.
sealed class SyncEvent {
  const SyncEvent();
}

class SyncStarted extends SyncEvent {
  const SyncStarted(this.trigger);
  final SyncTrigger trigger;
}

class SyncProgressUpdated extends SyncEvent {
  const SyncProgressUpdated(this.progress);
  final SyncProgress progress;
}

class SyncCompleted extends SyncEvent {
  const SyncCompleted({required this.processed, required this.failed});
  final int processed;
  final int failed;
}

class SyncFailed extends SyncEvent {
  const SyncFailed(this.error);
  final Object error;
}

class SyncPaused extends SyncEvent {
  const SyncPaused();
}

class SyncResumed extends SyncEvent {
  const SyncResumed();
}

class SyncCancelled extends SyncEvent {
  const SyncCancelled();
}

class NetworkRecovered extends SyncEvent {
  const NetworkRecovered();
}
