import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/enums/workflow_enums.dart';

/// Queued outbound notification awaiting dispatch.
class NotificationQueueItem extends Equatable implements SyncableEntity {
  const NotificationQueueItem({
    required this.id,
    required this.tenantId,
    required this.recipientId,
    required this.title,
    required this.body,
    required this.channel,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = NotificationQueueStatus.pending,
    this.priority = NotificationPriority.normal,
    this.scheduledAt,
    this.attemptCount = 0,
    this.maxAttempts = 3,
    this.lastError,
    this.data = const {},
    this.deletedAt,
  });

  static const entityTypeName = 'notification_queue';

  @override
  final String id;
  @override
  final String tenantId;
  final String recipientId;
  final String title;
  final String body;
  final NotificationChannel channel;
  final NotificationQueueStatus status;
  final NotificationPriority priority;
  final DateTime? scheduledAt;
  final int attemptCount;
  final int maxAttempts;
  final String? lastError;
  final Map<String, dynamic> data;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  NotificationQueueItem copyWith({
    NotificationQueueStatus? status,
    int? attemptCount,
    String? lastError,
    DateTime? updatedAt,
    bool? isDirty,
    LocalSyncStatus? syncStatus,
  }) =>
      NotificationQueueItem(
        id: id,
        tenantId: tenantId,
        recipientId: recipientId,
        title: title,
        body: body,
        channel: channel,
        status: status ?? this.status,
        priority: priority,
        scheduledAt: scheduledAt,
        attemptCount: attemptCount ?? this.attemptCount,
        maxAttempts: maxAttempts,
        lastError: lastError ?? this.lastError,
        data: data,
        version: version,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
      );

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'recipient_id': recipientId,
        'title': title,
        'body': body,
        'channel': channel.name,
        'status': status.value,
        'priority': priority.value,
        'scheduled_at': scheduledAt?.toIso8601String(),
        'attempt_count': attemptCount,
        'max_attempts': maxAttempts,
        'last_error': lastError,
        'data': data,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static NotificationQueueItem fromPayload(Map<String, dynamic> json, LocalRecord record) => NotificationQueueItem(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        recipientId: json['recipient_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        channel: NotificationChannel.values.firstWhere(
          (c) => c.name == (json['channel'] as String? ?? 'inApp'),
          orElse: () => NotificationChannel.inApp,
        ),
        status: NotificationQueueStatus.fromValue(json['status'] as String?),
        priority: NotificationPriority.fromValue(json['priority'] as String?),
        scheduledAt: json['scheduled_at'] != null ? DateTime.tryParse(json['scheduled_at'] as String) : null,
        attemptCount: json['attempt_count'] as int? ?? 0,
        maxAttempts: json['max_attempts'] as int? ?? 3,
        lastError: json['last_error'] as String?,
        data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, recipientId, channel, status, version];
}

/// Dead-letter queue item after max retries.
class DeadLetterItem extends Equatable implements SyncableEntity {
  const DeadLetterItem({
    required this.id,
    required this.tenantId,
    required this.originalQueueId,
    required this.reason,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.payload = const {},
    this.deletedAt,
  });

  static const entityTypeName = 'notification_dead_letter';

  @override
  final String id;
  @override
  final String tenantId;
  final String originalQueueId;
  final String reason;
  final Map<String, dynamic> payload;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'original_queue_id': originalQueueId,
        'reason': reason,
        'payload': payload,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static DeadLetterItem fromPayload(Map<String, dynamic> json, LocalRecord record) => DeadLetterItem(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        originalQueueId: json['original_queue_id'] as String? ?? '',
        reason: json['reason'] as String? ?? '',
        payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, originalQueueId, reason, version];
}

/// Per-user notification channel preferences.
class NotificationPreference extends Equatable implements SyncableEntity {
  const NotificationPreference({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.enabledChannels = const {},
    this.quietHours,
    this.deletedAt,
  });

  static const entityTypeName = 'notification_preference';

  @override
  final String id;
  @override
  final String tenantId;
  final String userId;
  final Map<String, bool> enabledChannels;
  final QuietHours? quietHours;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  bool isChannelEnabled(NotificationChannel channel) => enabledChannels[channel.name] ?? true;

  bool isInQuietHours(DateTime at) => quietHours?.contains(at) ?? false;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'user_id': userId,
        'enabled_channels': enabledChannels,
        'quiet_hours': quietHours?.toJson(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static NotificationPreference fromPayload(Map<String, dynamic> json, LocalRecord record) => NotificationPreference(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        userId: json['user_id'] as String? ?? '',
        enabledChannels: Map<String, bool>.from(json['enabled_channels'] as Map? ?? {}),
        quietHours: json['quiet_hours'] != null
            ? QuietHours.fromJson(Map<String, dynamic>.from(json['quiet_hours'] as Map))
            : null,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, userId, version];
}

/// Quiet hours window for suppressing notifications.
class QuietHours extends Equatable {
  const QuietHours({
    required this.startHour,
    required this.endHour,
    this.timezone = 'UTC',
  });

  final int startHour;
  final int endHour;
  final String timezone;

  bool contains(DateTime at) {
    final hour = at.toUtc().hour;
    if (startHour <= endHour) {
      return hour >= startHour && hour < endHour;
    }
    return hour >= startHour || hour < endHour;
  }

  Map<String, dynamic> toJson() => {
        'start_hour': startHour,
        'end_hour': endHour,
        'timezone': timezone,
      };

  static QuietHours fromJson(Map<String, dynamic> json) => QuietHours(
        startHour: json['start_hour'] as int? ?? 22,
        endHour: json['end_hour'] as int? ?? 7,
        timezone: json['timezone'] as String? ?? 'UTC',
      );

  @override
  List<Object?> get props => [startHour, endHour, timezone];
}
