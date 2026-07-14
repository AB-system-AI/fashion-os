import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/business/di/business_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/integrations/data/datasources/integrations_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/integrations/data/repositories/integrations_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/integrations/data/sync/integrations_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/connector.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/import_export_job.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/integration_log.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/repositories/integration_repositories.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/services/integration_abstractions.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/services/integration_services.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/services/integrations_cross_module_service.dart';

final integrationsRemoteDataSourceProvider = Provider<IntegrationsRemoteDataSource>((ref) => IntegrationsRemoteDataSource());

final integrationConnectorRepositoryProvider = Provider<IntegrationConnectorRepository>((ref) {
  return IntegrationConnectorLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final webhookRepositoryProvider = Provider<WebhookRepository>((ref) {
  return WebhookLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final apiKeyRepositoryProvider = Provider<ApiKeyRepository>((ref) {
  return ApiKeyLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final integrationLogRepositoryProvider = Provider<IntegrationLogRepository>((ref) {
  return IntegrationLogLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final importJobRepositoryProvider = Provider<ImportJobRepository>((ref) {
  return ImportJobLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final exportJobRepositoryProvider = Provider<ExportJobRepository>((ref) {
  return ExportJobLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final oauthConnectionRepositoryProvider = Provider<OAuthConnectionRepository>((ref) {
  return OAuthConnectionLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final printerProfileRepositoryProvider = Provider<PrinterProfileRepository>((ref) {
  return PrinterProfileLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final emailProviderProvider = Provider<EmailProvider>((ref) => NoOpEmailProvider());
final smsProviderProvider = Provider<SmsProvider>((ref) => NoOpSmsProvider());
final pushProviderProvider = Provider<PushProvider>((ref) => NoOpPushProvider());
final whatsAppProviderProvider = Provider<WhatsAppProvider>((ref) => NoOpWhatsAppProvider());
final oauthProviderProvider = Provider<OAuthProvider>((ref) => NoOpOAuthProvider());
final cloudStorageProviderProvider = Provider<CloudStorageProvider>((ref) => NoOpCloudStorageProvider());

final rateLimiterServiceProvider = Provider<RateLimiterService>((ref) => RateLimiterService(engine: ref.watch(integrationConnectorEngineProvider)));

final integrationLogServiceProvider = Provider<IntegrationLogService>((ref) => IntegrationLogService(repository: ref.watch(integrationLogRepositoryProvider)));

final healthCheckServiceProvider = Provider<HealthCheckService>((ref) => HealthCheckService(
      connectors: ref.watch(integrationConnectorRepositoryProvider),
      engine: ref.watch(integrationConnectorEngineProvider),
    ));

final connectorServiceProvider = Provider<ConnectorService>((ref) => ConnectorService(
      repository: ref.watch(integrationConnectorRepositoryProvider),
      engine: ref.watch(integrationConnectorEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      logs: ref.watch(integrationLogServiceProvider),
    ));

final webhookServiceProvider = Provider<WebhookService>((ref) => WebhookService(
      repository: ref.watch(webhookRepositoryProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      logs: ref.watch(integrationLogServiceProvider),
    ));

final apiKeyServiceProvider = Provider<ApiKeyService>((ref) => ApiKeyService(
      repository: ref.watch(apiKeyRepositoryProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final emailIntegrationServiceProvider = Provider<EmailIntegrationService>((ref) => EmailIntegrationService(
      provider: ref.watch(emailProviderProvider),
      logs: ref.watch(integrationLogServiceProvider),
    ));

final smsIntegrationServiceProvider = Provider<SmsIntegrationService>((ref) => SmsIntegrationService(
      provider: ref.watch(smsProviderProvider),
      logs: ref.watch(integrationLogServiceProvider),
    ));

final pushIntegrationServiceProvider = Provider<PushIntegrationService>((ref) => PushIntegrationService(
      provider: ref.watch(pushProviderProvider),
      logs: ref.watch(integrationLogServiceProvider),
    ));

final importExportIntegrationServiceProvider = Provider<ImportExportIntegrationService>((ref) => ImportExportIntegrationService(
      importExport: ref.watch(importExportServiceProvider),
      importJobs: ref.watch(importJobRepositoryProvider),
      exportJobs: ref.watch(exportJobRepositoryProvider),
      permissions: ref.watch(permissionEngineProvider),
      audit: ref.watch(auditServiceProvider),
    ));

final printerServiceProvider = Provider<PrinterService>((ref) => PrinterService(
      repository: ref.watch(printerProfileRepositoryProvider),
      permissions: ref.watch(permissionEngineProvider),
      audit: ref.watch(auditServiceProvider),
    ));

final oauthConnectorServiceProvider = Provider<OAuthConnectorService>((ref) => OAuthConnectorService(
      provider: ref.watch(oauthProviderProvider),
      connections: ref.watch(oauthConnectionRepositoryProvider),
      connectors: ref.watch(connectorServiceProvider),
    ));

final integrationsCrossModuleServiceProvider = Provider<IntegrationsCrossModuleService>((ref) => IntegrationsCrossModuleService(
      eventBus: ref.watch(domainEventBusProvider),
      audit: ref.watch(auditServiceProvider),
    ));

IntegrationsSyncProcessor _processor(Ref ref, String entityType, String table) => IntegrationsSyncProcessor(
      remote: ref.watch(integrationsRemoteDataSourceProvider),
      entityTypeName: entityType,
      remoteTable: table,
    );

final integrationConnectorSyncProcessorProvider = Provider<IntegrationConnectorSyncProcessor>((ref) => _processor(ref, IntegrationConnector.entityTypeName, 'integration_connectors'));
final webhookSyncProcessorProvider = Provider<WebhookSyncProcessor>((ref) => _processor(ref, WebhookEndpoint.entityTypeName, 'webhooks'));
final apiKeySyncProcessorProvider = Provider<ApiKeySyncProcessor>((ref) => _processor(ref, ApiKey.entityTypeName, 'api_keys'));
final integrationLogSyncProcessorProvider = Provider<IntegrationLogSyncProcessor>((ref) => _processor(ref, IntegrationLog.entityTypeName, 'integration_logs'));
final importJobSyncProcessorProvider = Provider<ImportJobSyncProcessor>((ref) => _processor(ref, ImportJob.entityTypeName, 'import_jobs'));
final exportJobSyncProcessorProvider = Provider<ExportJobSyncProcessor>((ref) => _processor(ref, ExportJob.entityTypeName, 'export_jobs'));
final oauthConnectionSyncProcessorProvider = Provider<OAuthConnectionSyncProcessor>((ref) => _processor(ref, OAuthConnection.entityTypeName, 'oauth_connections'));
final printerProfileSyncProcessorProvider = Provider<PrinterProfileSyncProcessor>((ref) => _processor(ref, PrinterProfile.entityTypeName, 'printer_profiles'));
