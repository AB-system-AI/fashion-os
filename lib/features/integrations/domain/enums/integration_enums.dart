enum ConnectorType {
  email,
  sms,
  push,
  whatsapp,
  oauth,
  storage,
  printer,
  webhook,
  custom;

  String get value => name;

  static ConnectorType fromValue(String? v) =>
      ConnectorType.values.firstWhere((e) => e.name == v, orElse: () => ConnectorType.custom);
}

enum ConnectorStatus {
  active,
  inactive,
  error,
  pendingAuth;

  String get value => name;

  static ConnectorStatus fromValue(String? v) =>
      ConnectorStatus.values.firstWhere((e) => e.name == v, orElse: () => ConnectorStatus.inactive);
}

enum WebhookStatus {
  active,
  inactive,
  failing;

  String get value => name;

  static WebhookStatus fromValue(String? v) =>
      WebhookStatus.values.firstWhere((e) => e.name == v, orElse: () => WebhookStatus.inactive);
}

enum ApiKeyStatus {
  active,
  revoked,
  expired;

  String get value => name;

  static ApiKeyStatus fromValue(String? v) =>
      ApiKeyStatus.values.firstWhere((e) => e.name == v, orElse: () => ApiKeyStatus.active);
}

enum IntegrationLogLevel {
  debug,
  info,
  warn,
  error;

  String get value => name;

  static IntegrationLogLevel fromValue(String? v) =>
      IntegrationLogLevel.values.firstWhere((e) => e.name == v, orElse: () => IntegrationLogLevel.info);
}

enum ImportJobStatus {
  pending,
  running,
  completed,
  failed,
  cancelled;

  String get value => name;

  static ImportJobStatus fromValue(String? v) =>
      ImportJobStatus.values.firstWhere((e) => e.name == v, orElse: () => ImportJobStatus.pending);
}

enum ExportJobStatus {
  pending,
  running,
  completed,
  failed,
  cancelled;

  String get value => name;

  static ExportJobStatus fromValue(String? v) =>
      ExportJobStatus.values.firstWhere((e) => e.name == v, orElse: () => ExportJobStatus.pending);
}

enum OAuthConnectionStatus {
  pending,
  connected,
  expired,
  revoked;

  String get value => name;

  static OAuthConnectionStatus fromValue(String? v) =>
      OAuthConnectionStatus.values.firstWhere((e) => e.name == v, orElse: () => OAuthConnectionStatus.pending);
}

enum PrinterConnectionType {
  network,
  usb,
  bluetooth,
  cloud;

  String get value => name;

  static PrinterConnectionType fromValue(String? v) =>
      PrinterConnectionType.values.firstWhere((e) => e.name == v, orElse: () => PrinterConnectionType.network);
}

enum MessageDeliveryStatus {
  queued,
  sent,
  delivered,
  failed,
  bounced;

  String get value => name;

  static MessageDeliveryStatus fromValue(String? v) =>
      MessageDeliveryStatus.values.firstWhere((e) => e.name == v, orElse: () => MessageDeliveryStatus.queued);
}
