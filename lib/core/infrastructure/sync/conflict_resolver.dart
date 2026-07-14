import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/entity_sync_processor.dart';

/// Result of conflict resolution.
class ConflictResolutionResult {
  const ConflictResolutionResult({
    required this.resolvedPayload,
    required this.strategy,
    required this.requiresManualReview,
  });

  final Map<String, dynamic> resolvedPayload;
  final ConflictResolutionStrategy strategy;
  final bool requiresManualReview;
}

/// Configurable conflict resolver for sync operations.
class ConflictResolver {
  ConflictResolver({
    this.defaultStrategy = ConflictResolutionStrategy.lastWriteWins,
    Map<String, ConflictResolutionStrategy>? entityStrategies,
    ConflictResolutionStrategy Function(SyncConflict conflict)? customResolver,
  })  : _entityStrategies = entityStrategies ?? const {},
        _customResolver = customResolver;

  final ConflictResolutionStrategy defaultStrategy;
  final Map<String, ConflictResolutionStrategy> _entityStrategies;
  final ConflictResolutionStrategy Function(SyncConflict conflict)? _customResolver;

  ConflictResolutionResult resolve(
    SyncConflict conflict, {
    ConflictResolutionStrategy? overrideStrategy,
  }) {
    final strategy = overrideStrategy ??
        _entityStrategies[conflict.entityType] ??
        defaultStrategy;

    if (strategy == ConflictResolutionStrategy.custom && _customResolver != null) {
      return _resolveWithStrategy(conflict, _customResolver!(conflict));
    }

    return _resolveWithStrategy(conflict, strategy);
  }

  ConflictResolutionResult _resolveWithStrategy(
    SyncConflict conflict,
    ConflictResolutionStrategy strategy,
  ) {
    return switch (strategy) {
      ConflictResolutionStrategy.serverWins => ConflictResolutionResult(
          resolvedPayload: conflict.serverPayload,
          strategy: strategy,
          requiresManualReview: false,
        ),
      ConflictResolutionStrategy.clientWins => ConflictResolutionResult(
          resolvedPayload: conflict.clientPayload,
          strategy: strategy,
          requiresManualReview: false,
        ),
      ConflictResolutionStrategy.lastWriteWins => _lastWriteWins(conflict, strategy),
      ConflictResolutionStrategy.manualMerge => ConflictResolutionResult(
          resolvedPayload: conflict.clientPayload,
          strategy: strategy,
          requiresManualReview: true,
        ),
      ConflictResolutionStrategy.custom => ConflictResolutionResult(
          resolvedPayload: conflict.clientPayload,
          strategy: strategy,
          requiresManualReview: true,
        ),
    };
  }

  ConflictResolutionResult _lastWriteWins(
    SyncConflict conflict,
    ConflictResolutionStrategy strategy,
  ) {
    final clientUpdated = _parseUpdatedAt(conflict.clientPayload);
    final serverUpdated = _parseUpdatedAt(conflict.serverPayload);
    final useServer = serverUpdated.isAfter(clientUpdated);
    return ConflictResolutionResult(
      resolvedPayload: useServer ? conflict.serverPayload : conflict.clientPayload,
      strategy: strategy,
      requiresManualReview: false,
    );
  }

  DateTime _parseUpdatedAt(Map<String, dynamic> payload) {
    final raw = payload['updated_at'] ?? payload['updatedAt'];
    if (raw is String) return DateTime.parse(raw);
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}
