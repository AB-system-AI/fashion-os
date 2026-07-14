import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/integrations/data/datasources/integrations_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/integrations/data/sync/integrations_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/connector.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/import_export_job.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/integration_log.dart';

void main() {
  test('integrations sync processors map entity types to remote tables', () {
    final remote = IntegrationsRemoteDataSource();
    expect(
      IntegrationsSyncProcessor(remote: remote, entityTypeName: IntegrationConnector.entityTypeName, remoteTable: 'integration_connectors').entityType,
      'integration_connector',
    );
    expect(
      IntegrationsSyncProcessor(remote: remote, entityTypeName: WebhookEndpoint.entityTypeName, remoteTable: 'webhooks').entityType,
      'webhook_endpoint',
    );
    expect(
      IntegrationsSyncProcessor(remote: remote, entityTypeName: ApiKey.entityTypeName, remoteTable: 'api_keys').entityType,
      'api_key',
    );
    expect(
      IntegrationsSyncProcessor(remote: remote, entityTypeName: IntegrationLog.entityTypeName, remoteTable: 'integration_logs').entityType,
      'integration_log',
    );
    expect(
      IntegrationsSyncProcessor(remote: remote, entityTypeName: ImportJob.entityTypeName, remoteTable: 'import_jobs').entityType,
      'import_job',
    );
    expect(
      IntegrationsSyncProcessor(remote: remote, entityTypeName: ExportJob.entityTypeName, remoteTable: 'export_jobs').entityType,
      'export_job',
    );
    expect(
      IntegrationsSyncProcessor(remote: remote, entityTypeName: OAuthConnection.entityTypeName, remoteTable: 'oauth_connections').entityType,
      'oauth_connection',
    );
    expect(
      IntegrationsSyncProcessor(remote: remote, entityTypeName: PrinterProfile.entityTypeName, remoteTable: 'printer_profiles').entityType,
      'printer_profile',
    );
  });
}
