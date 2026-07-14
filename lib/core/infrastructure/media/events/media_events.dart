import 'package:equatable/equatable.dart';

/// Media lifecycle domain events.
abstract class MediaEvent extends Equatable {
  const MediaEvent({required this.eventId, required this.occurredAt, required this.assetId});

  final String eventId;
  final DateTime occurredAt;
  final String assetId;

  @override
  List<Object?> get props => [eventId, occurredAt, assetId];
}

class MediaUploadedEvent extends MediaEvent {
  const MediaUploadedEvent({
    required super.eventId,
    required super.occurredAt,
    required super.assetId,
    required this.remotePath,
    required this.bucket,
  });

  final String remotePath;
  final String bucket;

  @override
  String get eventType => 'media.uploaded';
}

class MediaDeletedEvent extends MediaEvent {
  const MediaDeletedEvent({required super.eventId, required super.occurredAt, required super.assetId});

  @override
  String get eventType => 'media.deleted';
}

class MediaSyncConflictEvent extends MediaEvent {
  const MediaSyncConflictEvent({
    required super.eventId,
    required super.occurredAt,
    required super.assetId,
    required this.reason,
  });

  final String reason;

  @override
  String get eventType => 'media.sync_conflict';
}
