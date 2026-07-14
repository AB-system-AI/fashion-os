import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/features/integrations/domain/enums/integration_enums.dart';

/// Log/reference entity for outbound email — not synced to remote.
class EmailMessage extends Equatable {
  const EmailMessage({
    required this.id,
    required this.tenantId,
    required this.to,
    required this.subject,
    required this.createdAt,
    this.from,
    this.body,
    this.status = MessageDeliveryStatus.queued,
    this.connectorId,
    this.referenceType,
    this.referenceId,
    this.errorMessage,
  });

  final String id;
  final String tenantId;
  final String to;
  final String? from;
  final String subject;
  final String? body;
  final MessageDeliveryStatus status;
  final String? connectorId;
  final String? referenceType;
  final String? referenceId;
  final String? errorMessage;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, to, subject, status];
}

class SmsMessage extends Equatable {
  const SmsMessage({
    required this.id,
    required this.tenantId,
    required this.to,
    required this.body,
    required this.createdAt,
    this.status = MessageDeliveryStatus.queued,
    this.connectorId,
    this.referenceType,
    this.referenceId,
    this.errorMessage,
  });

  final String id;
  final String tenantId;
  final String to;
  final String body;
  final MessageDeliveryStatus status;
  final String? connectorId;
  final String? referenceType;
  final String? referenceId;
  final String? errorMessage;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, to, status];
}

class PushMessage extends Equatable {
  const PushMessage({
    required this.id,
    required this.tenantId,
    required this.title,
    required this.createdAt,
    this.body,
    this.deviceToken,
    this.status = MessageDeliveryStatus.queued,
    this.connectorId,
    this.data = const {},
    this.errorMessage,
  });

  final String id;
  final String tenantId;
  final String title;
  final String? body;
  final String? deviceToken;
  final MessageDeliveryStatus status;
  final String? connectorId;
  final Map<String, dynamic> data;
  final String? errorMessage;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, title, status];
}

class WhatsAppMessage extends Equatable {
  const WhatsAppMessage({
    required this.id,
    required this.tenantId,
    required this.to,
    required this.body,
    required this.createdAt,
    this.status = MessageDeliveryStatus.queued,
    this.connectorId,
    this.templateName,
    this.errorMessage,
  });

  final String id;
  final String tenantId;
  final String to;
  final String body;
  final MessageDeliveryStatus status;
  final String? connectorId;
  final String? templateName;
  final String? errorMessage;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, to, status];
}
