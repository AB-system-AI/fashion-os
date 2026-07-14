import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/notification_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/notification_providers.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/notification_queue.dart';

void main() {
  test('registerWorkflowNotificationProviders wires all channels', () async {
    final engine = NotificationEngine();
    registerWorkflowNotificationProviders(engine);

    for (final channel in [
      NotificationChannel.email,
      NotificationChannel.sms,
      NotificationChannel.whatsApp,
      NotificationChannel.push,
      NotificationChannel.inApp,
      NotificationChannel.slack,
      NotificationChannel.teams,
      NotificationChannel.webhook,
    ]) {
      final results = await engine.send(NotificationMessage(
        channel: channel,
        title: 'Test',
        body: 'Body',
        recipientId: 'user-1',
      ));
      expect(results, hasLength(1));
      expect(results.first.success, isTrue);
    }
  });

  test('NotificationPreference respects quiet hours', () {
    final pref = NotificationPreference(
      id: 'pref-1',
      tenantId: 'tenant-1',
      userId: 'user-1',
      quietHours: QuietHours(startHour: 22, endHour: 7),
      version: 1,
      createdAt: _t,
      updatedAt: _t,
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    expect(pref.isInQuietHours(DateTime.utc(2025, 6, 1, 23)), isTrue);
    expect(pref.isInQuietHours(DateTime.utc(2025, 6, 1, 12)), isFalse);
  });

  test('NotificationQueueItem tracks retry state', () {
    final item = NotificationQueueItem(
      id: 'q-1',
      tenantId: 'tenant-1',
      recipientId: 'user-1',
      title: 'Hello',
      body: 'World',
      channel: NotificationChannel.email,
      attemptCount: 2,
      maxAttempts: 3,
      version: 1,
      createdAt: _t,
      updatedAt: _t,
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    final updated = item.copyWith(attemptCount: 3, status: NotificationQueueStatus.deadLetter);
    expect(updated.status, NotificationQueueStatus.deadLetter);
    expect(updated.attemptCount, 3);
  });
}

final _t = DateTime.utc(2025, 1, 1);
