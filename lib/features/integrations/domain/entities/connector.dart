import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/enums/integration_enums.dart';

class IntegrationConnector extends Equatable implements SyncableEntity {
  const IntegrationConnector({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.connectorType,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = ConnectorStatus.inactive,
    this.providerKey,
    this.config = const {},
    this.isEnabled = true,
    this.lastSuccessAt,
    this.lastFailureAt,
    this.consecutiveFailures = 0,
    this.rateLimitPerMinute = 60,
    this.deletedAt,
  });

  static const entityTypeName = 'integration_connector';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final ConnectorType connectorType;
  final ConnectorStatus status;
  final String? providerKey;
  final Map<String, dynamic> config;
  final bool isEnabled;
  final DateTime? lastSuccessAt;
  final DateTime? lastFailureAt;
  final int consecutiveFailures;
  final int rateLimitPerMinute;
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

  IntegrationConnector copyWith({
    ConnectorStatus? status,
    bool? isEnabled,
    DateTime? lastSuccessAt,
    DateTime? lastFailureAt,
    int? consecutiveFailures,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      IntegrationConnector(
        id: id,
        tenantId: tenantId,
        name: name,
        connectorType: connectorType,
        status: status ?? this.status,
        providerKey: providerKey,
        config: config,
        isEnabled: isEnabled ?? this.isEnabled,
        lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
        lastFailureAt: lastFailureAt ?? this.lastFailureAt,
        consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
        rateLimitPerMinute: rateLimitPerMinute,
        version: version ?? this.version,
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
        'name': name,
        'connector_type': connectorType.value,
        'status': status.value,
        'provider_key': providerKey,
        'config': config,
        'is_enabled': isEnabled,
        'last_success_at': lastSuccessAt?.toIso8601String(),
        'last_failure_at': lastFailureAt?.toIso8601String(),
        'consecutive_failures': consecutiveFailures,
        'rate_limit_per_minute': rateLimitPerMinute,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static IntegrationConnector fromPayload(Map<String, dynamic> json, LocalRecord record) => IntegrationConnector(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        connectorType: ConnectorType.fromValue(json['connector_type'] as String?),
        status: ConnectorStatus.fromValue(json['status'] as String?),
        providerKey: json['provider_key'] as String?,
        config: Map<String, dynamic>.from(json['config'] as Map? ?? {}),
        isEnabled: json['is_enabled'] as bool? ?? true,
        lastSuccessAt: json['last_success_at'] != null ? DateTime.tryParse(json['last_success_at'] as String) : null,
        lastFailureAt: json['last_failure_at'] != null ? DateTime.tryParse(json['last_failure_at'] as String) : null,
        consecutiveFailures: json['consecutive_failures'] as int? ?? 0,
        rateLimitPerMinute: json['rate_limit_per_minute'] as int? ?? 60,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, connectorType, status, version];
}

class ApiKey extends Equatable implements SyncableEntity {
  const ApiKey({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.keyPrefix,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = ApiKeyStatus.active,
    this.scopes = const [],
    this.expiresAt,
    this.lastUsedAt,
    this.createdBy,
    this.deletedAt,
  });

  static const entityTypeName = 'api_key';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String keyPrefix;
  final ApiKeyStatus status;
  final List<String> scopes;
  final DateTime? expiresAt;
  final DateTime? lastUsedAt;
  final String? createdBy;
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

  ApiKey copyWith({
    ApiKeyStatus? status,
    DateTime? lastUsedAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      ApiKey(
        id: id,
        tenantId: tenantId,
        name: name,
        keyPrefix: keyPrefix,
        status: status ?? this.status,
        scopes: scopes,
        expiresAt: expiresAt,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
        createdBy: createdBy,
        version: version ?? this.version,
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
        'name': name,
        'key_prefix': keyPrefix,
        'status': status.value,
        'scopes': scopes,
        'expires_at': expiresAt?.toIso8601String(),
        'last_used_at': lastUsedAt?.toIso8601String(),
        'created_by': createdBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ApiKey fromPayload(Map<String, dynamic> json, LocalRecord record) => ApiKey(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        keyPrefix: json['key_prefix'] as String? ?? '',
        status: ApiKeyStatus.fromValue(json['status'] as String?),
        scopes: List<String>.from(json['scopes'] as List? ?? []),
        expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'] as String) : null,
        lastUsedAt: json['last_used_at'] != null ? DateTime.tryParse(json['last_used_at'] as String) : null,
        createdBy: json['created_by'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, keyPrefix, status, version];
}

class WebhookEndpoint extends Equatable implements SyncableEntity {
  const WebhookEndpoint({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.url,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = WebhookStatus.inactive,
    this.events = const [],
    this.secretHash,
    this.failureCount = 0,
    this.lastTriggeredAt,
    this.deletedAt,
  });

  static const entityTypeName = 'webhook_endpoint';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String url;
  final WebhookStatus status;
  final List<String> events;
  final String? secretHash;
  final int failureCount;
  final DateTime? lastTriggeredAt;
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

  WebhookEndpoint copyWith({
    WebhookStatus? status,
    int? failureCount,
    DateTime? lastTriggeredAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      WebhookEndpoint(
        id: id,
        tenantId: tenantId,
        name: name,
        url: url,
        status: status ?? this.status,
        events: events,
        secretHash: secretHash,
        failureCount: failureCount ?? this.failureCount,
        lastTriggeredAt: lastTriggeredAt ?? this.lastTriggeredAt,
        version: version ?? this.version,
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
        'name': name,
        'url': url,
        'status': status.value,
        'events': events,
        'secret_hash': secretHash,
        'failure_count': failureCount,
        'last_triggered_at': lastTriggeredAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static WebhookEndpoint fromPayload(Map<String, dynamic> json, LocalRecord record) => WebhookEndpoint(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        url: json['url'] as String? ?? '',
        status: WebhookStatus.fromValue(json['status'] as String?),
        events: List<String>.from(json['events'] as List? ?? []),
        secretHash: json['secret_hash'] as String?,
        failureCount: json['failure_count'] as int? ?? 0,
        lastTriggeredAt: json['last_triggered_at'] != null ? DateTime.tryParse(json['last_triggered_at'] as String) : null,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, url, status, version];
}

class OAuthConnection extends Equatable implements SyncableEntity {
  const OAuthConnection({
    required this.id,
    required this.tenantId,
    required this.provider,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = OAuthConnectionStatus.pending,
    this.accountLabel,
    this.scopes = const [],
    this.expiresAt,
    this.connectorId,
    this.deletedAt,
  });

  static const entityTypeName = 'oauth_connection';

  @override
  final String id;
  @override
  final String tenantId;
  final String provider;
  final OAuthConnectionStatus status;
  final String? accountLabel;
  final List<String> scopes;
  final DateTime? expiresAt;
  final String? connectorId;
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
        'provider': provider,
        'status': status.value,
        'account_label': accountLabel,
        'scopes': scopes,
        'expires_at': expiresAt?.toIso8601String(),
        'connector_id': connectorId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static OAuthConnection fromPayload(Map<String, dynamic> json, LocalRecord record) => OAuthConnection(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        provider: json['provider'] as String? ?? record.searchName ?? '',
        status: OAuthConnectionStatus.fromValue(json['status'] as String?),
        accountLabel: json['account_label'] as String?,
        scopes: List<String>.from(json['scopes'] as List? ?? []),
        expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'] as String) : null,
        connectorId: json['connector_id'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, provider, status, version];
}

class PrinterProfile extends Equatable implements SyncableEntity {
  const PrinterProfile({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.connectionType,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.address,
    this.isDefault = false,
    this.paperWidthMm = 80,
    this.config = const {},
    this.deletedAt,
  });

  static const entityTypeName = 'printer_profile';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final PrinterConnectionType connectionType;
  final String? address;
  final bool isDefault;
  final int paperWidthMm;
  final Map<String, dynamic> config;
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
        'name': name,
        'connection_type': connectionType.value,
        'address': address,
        'is_default': isDefault,
        'paper_width_mm': paperWidthMm,
        'config': config,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static PrinterProfile fromPayload(Map<String, dynamic> json, LocalRecord record) => PrinterProfile(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        connectionType: PrinterConnectionType.fromValue(json['connection_type'] as String?),
        address: json['address'] as String?,
        isDefault: json['is_default'] as bool? ?? false,
        paperWidthMm: json['paper_width_mm'] as int? ?? 80,
        config: Map<String, dynamic>.from(json['config'] as Map? ?? {}),
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, connectionType, version];
}
