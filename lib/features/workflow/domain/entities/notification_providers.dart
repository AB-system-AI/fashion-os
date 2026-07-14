import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/notification_engine.dart';

/// Workflow notification provider contract — delegates to [NotificationEngine].
abstract class WorkflowNotificationProvider implements NotificationProvider {
  @override
  NotificationChannel get channel;
}

class EmailNotificationProvider extends NoOpNotificationProvider implements WorkflowNotificationProvider {
  EmailNotificationProvider({NotificationEngine? engine})
      : _engine = engine,
        super(NotificationChannel.email);

  final NotificationEngine? _engine;

  @override
  Future<NotificationResult> send(NotificationMessage message) async {
    if (_engine != null) return (await _engine.send(message)).first;
    return super.send(message);
  }
}

class SmsNotificationProvider extends NoOpNotificationProvider implements WorkflowNotificationProvider {
  SmsNotificationProvider({NotificationEngine? engine})
      : _engine = engine,
        super(NotificationChannel.sms);

  final NotificationEngine? _engine;

  @override
  Future<NotificationResult> send(NotificationMessage message) async {
    if (_engine != null) return (await _engine.send(message)).first;
    return super.send(message);
  }
}

class WhatsAppNotificationProvider extends NoOpNotificationProvider implements WorkflowNotificationProvider {
  WhatsAppNotificationProvider({NotificationEngine? engine})
      : _engine = engine,
        super(NotificationChannel.whatsApp);

  final NotificationEngine? _engine;

  @override
  Future<NotificationResult> send(NotificationMessage message) async {
    if (_engine != null) return (await _engine.send(message)).first;
    return super.send(message);
  }
}

class PushNotificationProvider extends NoOpNotificationProvider implements WorkflowNotificationProvider {
  PushNotificationProvider({NotificationEngine? engine})
      : _engine = engine,
        super(NotificationChannel.push);

  final NotificationEngine? _engine;

  @override
  Future<NotificationResult> send(NotificationMessage message) async {
    if (_engine != null) return (await _engine.send(message)).first;
    return super.send(message);
  }
}

class InternalNotificationProvider extends NoOpNotificationProvider implements WorkflowNotificationProvider {
  InternalNotificationProvider({NotificationEngine? engine})
      : _engine = engine,
        super(NotificationChannel.inApp);

  final NotificationEngine? _engine;

  @override
  Future<NotificationResult> send(NotificationMessage message) async {
    if (_engine != null) return (await _engine.send(message)).first;
    return super.send(message);
  }
}

class SlackNotificationProvider extends NoOpNotificationProvider implements WorkflowNotificationProvider {
  SlackNotificationProvider({NotificationEngine? engine})
      : _engine = engine,
        super(NotificationChannel.slack);

  final NotificationEngine? _engine;

  @override
  Future<NotificationResult> send(NotificationMessage message) async {
    if (_engine != null) return (await _engine.send(message)).first;
    return super.send(message);
  }
}

class TeamsNotificationProvider extends NoOpNotificationProvider implements WorkflowNotificationProvider {
  TeamsNotificationProvider({NotificationEngine? engine})
      : _engine = engine,
        super(NotificationChannel.teams);

  final NotificationEngine? _engine;

  @override
  Future<NotificationResult> send(NotificationMessage message) async {
    if (_engine != null) return (await _engine.send(message)).first;
    return super.send(message);
  }
}

class WebhookNotificationProvider extends NoOpNotificationProvider implements WorkflowNotificationProvider {
  WebhookNotificationProvider({NotificationEngine? engine})
      : _engine = engine,
        super(NotificationChannel.webhook);

  final NotificationEngine? _engine;

  @override
  Future<NotificationResult> send(NotificationMessage message) async {
    if (_engine != null) return (await _engine.send(message)).first;
    return super.send(message);
  }
}

/// Registers all workflow providers with the core [NotificationEngine].
void registerWorkflowNotificationProviders(NotificationEngine engine) {
  engine
    ..registerProvider(EmailNotificationProvider(engine: engine))
    ..registerProvider(SmsNotificationProvider(engine: engine))
    ..registerProvider(WhatsAppNotificationProvider(engine: engine))
    ..registerProvider(PushNotificationProvider(engine: engine))
    ..registerProvider(InternalNotificationProvider(engine: engine))
    ..registerProvider(SlackNotificationProvider(engine: engine))
    ..registerProvider(TeamsNotificationProvider(engine: engine))
    ..registerProvider(WebhookNotificationProvider(engine: engine));
}
