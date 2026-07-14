import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';

/// Notification message to dispatch.
class NotificationMessage extends Equatable {
  const NotificationMessage({
    required this.channel,
    required this.title,
    required this.body,
    this.recipientId,
    this.recipientAddress,
    this.data = const {},
    this.priority = 'normal',
  });

  final NotificationChannel channel;
  final String title;
  final String body;
  final String? recipientId;
  final String? recipientAddress;
  final Map<String, dynamic> data;
  final String priority;

  @override
  List<Object?> get props => [channel, title, recipientId];
}

/// Notification delivery result.
class NotificationResult extends Equatable {
  const NotificationResult({
    required this.channel,
    required this.success,
    this.messageId,
    this.errorMessage,
  });

  final NotificationChannel channel;
  final bool success;
  final String? messageId;
  final String? errorMessage;

  @override
  List<Object?> get props => [channel, success];
}

/// Provider contract for a notification channel.
abstract class NotificationProvider {
  NotificationChannel get channel;

  Future<NotificationResult> send(NotificationMessage message);
}

/// No-op notification provider for offline/testing.
class NoOpNotificationProvider implements NotificationProvider {
  NoOpNotificationProvider(this.channel);

  @override
  final NotificationChannel channel;

  @override
  Future<NotificationResult> send(NotificationMessage message) async {
    return NotificationResult(channel: channel, success: true, messageId: 'noop');
  }
}

/// Coordinates multi-channel notification dispatch.
class NotificationEngine {
  NotificationEngine({List<NotificationProvider> providers = const []})
      : _providers = {for (final p in providers) p.channel: p};

  final Map<NotificationChannel, NotificationProvider> _providers;

  void registerProvider(NotificationProvider provider) {
    _providers[provider.channel] = provider;
  }

  Future<List<NotificationResult>> send(NotificationMessage message) async {
    final provider = _providers[message.channel];
    if (provider == null) {
      return [
        NotificationResult(
          channel: message.channel,
          success: false,
          errorMessage: 'No provider for ${message.channel.name}',
        ),
      ];
    }
    return [await provider.send(message)];
  }

  Future<List<NotificationResult>> broadcast({
    required List<NotificationChannel> channels,
    required String title,
    required String body,
    String? recipientId,
    Map<String, dynamic> data = const {},
  }) async {
    final results = <NotificationResult>[];
    for (final channel in channels) {
      results.addAll(
        await send(
          NotificationMessage(
            channel: channel,
            title: title,
            body: body,
            recipientId: recipientId,
            data: data,
          ),
        ),
      );
    }
    return results;
  }
}
