import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/connector.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/import_export_job.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/integration_log.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/enums/integration_enums.dart';

abstract class IntegrationConnectorRepository implements BaseLocalRepository<IntegrationConnector> {
  Future<List<IntegrationConnector>> listByType(String tenantId, ConnectorType type);
}

abstract class WebhookRepository implements BaseLocalRepository<WebhookEndpoint> {
  Future<List<WebhookEndpoint>> listByEvent(String tenantId, String event);
  Future<List<WebhookEndpoint>> listActive(String tenantId);
}

abstract class ApiKeyRepository implements BaseLocalRepository<ApiKey> {
  Future<List<ApiKey>> listActive(String tenantId);
}

abstract class IntegrationLogRepository implements BaseLocalRepository<IntegrationLog> {
  Future<PaginatedResult<IntegrationLog>> listRecent(String tenantId, {int limit = 100});
}

abstract class ImportJobRepository implements BaseLocalRepository<ImportJob> {
  Future<List<ImportJob>> listByStatus(String tenantId, ImportJobStatus status);
}

abstract class ExportJobRepository implements BaseLocalRepository<ExportJob> {
  Future<List<ExportJob>> listByStatus(String tenantId, ExportJobStatus status);
}

abstract class OAuthConnectionRepository implements BaseLocalRepository<OAuthConnection> {
  Future<OAuthConnection?> getByProvider(String tenantId, String provider);
}

abstract class PrinterProfileRepository implements BaseLocalRepository<PrinterProfile> {
  Future<PrinterProfile?> getDefault(String tenantId);
}
