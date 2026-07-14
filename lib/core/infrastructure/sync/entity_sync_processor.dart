import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/remote_sync_record.dart';

/// Result of processing a single sync queue item.
class SyncProcessResult extends Equatable {
  const SyncProcessResult({
    required this.success,
    this.conflict,
    this.errorMessage,
    this.serverVersion,
  });

  final bool success;
  final SyncConflict? conflict;
  final String? errorMessage;
  final int? serverVersion;

  @override
  List<Object?> get props => [success, conflict, errorMessage, serverVersion];
}

/// Conflict payload for processor implementations.
class SyncConflict {
  const SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.clientPayload,
    required this.serverPayload,
    required this.clientVersion,
    required this.serverVersion,
  });

  final String entityType;
  final String entityId;
  final Map<String, dynamic> clientPayload;
  final Map<String, dynamic> serverPayload;
  final int clientVersion;
  final int serverVersion;
}

/// Entity-specific sync processor — implemented by feature modules.
abstract class EntitySyncProcessor {
  String get entityType;

  Future<SyncProcessResult> push(Map<String, dynamic> queueItem);

  Future<PullDeltaResult> pullDelta({
    required String tenantId,
    required String deviceId,
    required DateTime since,
    required int sinceVersion,
  });
}
