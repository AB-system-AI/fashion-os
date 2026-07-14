import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/communication.dart';

/// Outbound email provider contract.
abstract class EmailProvider {
  String get providerKey;

  Future<Result<EmailMessage>> send({
    required String tenantId,
    required String to,
    required String subject,
    String? body,
    String? from,
    Map<String, dynamic> metadata = const {},
  });
}

class NoOpEmailProvider implements EmailProvider {
  @override
  String get providerKey => 'noop_email';

  @override
  Future<Result<EmailMessage>> send({
    required String tenantId,
    required String to,
    required String subject,
    String? body,
    String? from,
    Map<String, dynamic> metadata = const {},
  }) async {
    return Success(EmailMessage(
      id: 'noop-${DateTime.now().millisecondsSinceEpoch}',
      tenantId: tenantId,
      to: to,
      from: from,
      subject: subject,
      body: body,
      createdAt: DateTime.now().toUtc(),
    ));
  }
}

/// Outbound SMS provider contract.
abstract class SmsProvider {
  String get providerKey;

  Future<Result<SmsMessage>> send({
    required String tenantId,
    required String to,
    required String body,
    Map<String, dynamic> metadata = const {},
  });
}

class NoOpSmsProvider implements SmsProvider {
  @override
  String get providerKey => 'noop_sms';

  @override
  Future<Result<SmsMessage>> send({
    required String tenantId,
    required String to,
    required String body,
    Map<String, dynamic> metadata = const {},
  }) async {
    return Success(SmsMessage(
      id: 'noop-${DateTime.now().millisecondsSinceEpoch}',
      tenantId: tenantId,
      to: to,
      body: body,
      createdAt: DateTime.now().toUtc(),
    ));
  }
}

/// Push notification provider contract.
abstract class PushProvider {
  String get providerKey;

  Future<Result<PushMessage>> send({
    required String tenantId,
    required String title,
    String? body,
    String? deviceToken,
    Map<String, dynamic> data = const {},
  });
}

class NoOpPushProvider implements PushProvider {
  @override
  String get providerKey => 'noop_push';

  @override
  Future<Result<PushMessage>> send({
    required String tenantId,
    required String title,
    String? body,
    String? deviceToken,
    Map<String, dynamic> data = const {},
  }) async {
    return Success(PushMessage(
      id: 'noop-${DateTime.now().millisecondsSinceEpoch}',
      tenantId: tenantId,
      title: title,
      body: body,
      deviceToken: deviceToken,
      data: data,
      createdAt: DateTime.now().toUtc(),
    ));
  }
}

/// WhatsApp messaging provider contract.
abstract class WhatsAppProvider {
  String get providerKey;

  Future<Result<WhatsAppMessage>> send({
    required String tenantId,
    required String to,
    required String body,
    String? templateName,
    Map<String, dynamic> metadata = const {},
  });
}

class NoOpWhatsAppProvider implements WhatsAppProvider {
  @override
  String get providerKey => 'noop_whatsapp';

  @override
  Future<Result<WhatsAppMessage>> send({
    required String tenantId,
    required String to,
    required String body,
    String? templateName,
    Map<String, dynamic> metadata = const {},
  }) async {
    return Success(WhatsAppMessage(
      id: 'noop-${DateTime.now().millisecondsSinceEpoch}',
      tenantId: tenantId,
      to: to,
      body: body,
      templateName: templateName,
      createdAt: DateTime.now().toUtc(),
    ));
  }
}

/// OAuth connector provider contract.
abstract class OAuthProvider {
  String get providerKey;

  Future<Result<String>> buildAuthorizationUrl({
    required String tenantId,
    required String redirectUri,
    List<String> scopes = const [],
  });

  Future<Result<({String accessToken, String? refreshToken, DateTime? expiresAt})>> exchangeCode({
    required String tenantId,
    required String code,
    required String redirectUri,
  });
}

class NoOpOAuthProvider implements OAuthProvider {
  @override
  String get providerKey => 'noop_oauth';

  @override
  Future<Result<String>> buildAuthorizationUrl({
    required String tenantId,
    required String redirectUri,
    List<String> scopes = const [],
  }) async =>
      const Success('https://example.com/oauth/noop');

  @override
  Future<Result<({String accessToken, String? refreshToken, DateTime? expiresAt})>> exchangeCode({
    required String tenantId,
    required String code,
    required String redirectUri,
  }) async =>
      Success((accessToken: 'noop-token', refreshToken: null, expiresAt: null));
}

/// Cloud storage provider contract.
abstract class CloudStorageProvider {
  String get providerKey;

  Future<Result<String>> upload({
    required String tenantId,
    required String path,
    required List<int> bytes,
    String? contentType,
  });

  Future<Result<List<int>>> download({
    required String tenantId,
    required String path,
  });
}

class NoOpCloudStorageProvider implements CloudStorageProvider {
  @override
  String get providerKey => 'noop_storage';

  @override
  Future<Result<String>> upload({
    required String tenantId,
    required String path,
    required List<int> bytes,
    String? contentType,
  }) async =>
      Success('noop://$tenantId/$path');

  @override
  Future<Result<List<int>>> download({
    required String tenantId,
    required String path,
  }) async =>
      const Success([]);
}
