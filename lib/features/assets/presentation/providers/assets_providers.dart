import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/business/di/business_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/assets/data/datasources/assets_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/assets/data/repositories/assets_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/assets/data/sync/assets_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/asset.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/audit.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/contracts.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/depreciation.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/disposal.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/maintenance.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/settings.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/transfer.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/repositories/assets_repositories.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/services/asset_integration_service.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/services/assets_services.dart';

final assetsRemoteDataSourceProvider = Provider<AssetsRemoteDataSource>((ref) => AssetsRemoteDataSource());

final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  return AssetLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final assetCategoryRepositoryProvider = Provider<AssetCategoryRepository>((ref) {
  return AssetCategoryLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final assetLocationRepositoryProvider = Provider<AssetLocationRepository>((ref) {
  return AssetLocationLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final assetDepreciationRepositoryProvider = Provider<AssetDepreciationRepository>((ref) {
  return AssetDepreciationLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final assetTransferRepositoryProvider = Provider<AssetTransferRepository>((ref) {
  return AssetTransferLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final assetDisposalRepositoryProvider = Provider<AssetDisposalRepository>((ref) {
  return AssetDisposalLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final maintenanceRequestRepositoryProvider = Provider<MaintenanceRequestRepository>((ref) {
  return MaintenanceRequestLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final maintenanceScheduleRepositoryProvider = Provider<MaintenanceScheduleRepository>((ref) {
  return MaintenanceScheduleLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final maintenanceTaskRepositoryProvider = Provider<MaintenanceTaskRepository>((ref) {
  return MaintenanceTaskLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final maintenanceCostRepositoryProvider = Provider<MaintenanceCostRepository>((ref) {
  return MaintenanceCostLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final serviceContractRepositoryProvider = Provider<ServiceContractRepository>((ref) {
  return ServiceContractLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final warrantyRepositoryProvider = Provider<WarrantyRepository>((ref) {
  return WarrantyLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final assetAuditRepositoryProvider = Provider<AssetAuditRepository>((ref) {
  return AssetAuditLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final assetSettingsRepositoryProvider = Provider<AssetSettingsRepository>((ref) {
  return AssetSettingsLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final assetServiceProvider = Provider<AssetService>((ref) => AssetService(
      assets: ref.watch(assetRepositoryProvider),
      categories: ref.watch(assetCategoryRepositoryProvider),
      locations: ref.watch(assetLocationRepositoryProvider),
      settings: ref.watch(assetSettingsRepositoryProvider),
      engine: ref.watch(assetsEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final depreciationServiceProvider = Provider<DepreciationService>((ref) => DepreciationService(
      assets: ref.watch(assetRepositoryProvider),
      depreciation: ref.watch(assetDepreciationRepositoryProvider),
      engine: ref.watch(assetsEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final maintenanceServiceProvider = Provider<MaintenanceService>((ref) => MaintenanceService(
      requests: ref.watch(maintenanceRequestRepositoryProvider),
      schedules: ref.watch(maintenanceScheduleRepositoryProvider),
      costs: ref.watch(maintenanceCostRepositoryProvider),
      assets: ref.watch(assetRepositoryProvider),
      engine: ref.watch(assetsEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final transferServiceProvider = Provider<TransferService>((ref) => TransferService(
      assets: ref.watch(assetRepositoryProvider),
      transfers: ref.watch(assetTransferRepositoryProvider),
      engine: ref.watch(assetsEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final disposalServiceProvider = Provider<DisposalService>((ref) => DisposalService(
      assets: ref.watch(assetRepositoryProvider),
      disposals: ref.watch(assetDisposalRepositoryProvider),
      settings: ref.watch(assetSettingsRepositoryProvider),
      engine: ref.watch(assetsEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final assetIntegrationServiceProvider = Provider<AssetIntegrationService>((ref) => AssetIntegrationService(
      eventBus: ref.watch(domainEventBusProvider),
      audit: ref.watch(auditServiceProvider),
    ));

AssetsSyncProcessor _processor(Ref ref, String entityType, String table) => AssetsSyncProcessor(
      remote: ref.watch(assetsRemoteDataSourceProvider),
      entityTypeName: entityType,
      remoteTable: table,
    );

final assetSyncProcessorProvider = Provider<AssetSyncProcessor>((ref) => _processor(ref, Asset.entityTypeName, 'assets'));
final assetCategorySyncProcessorProvider = Provider<AssetsSyncProcessor>((ref) => _processor(ref, AssetCategory.entityTypeName, 'asset_categories'));
final assetLocationSyncProcessorProvider = Provider<AssetsSyncProcessor>((ref) => _processor(ref, AssetLocation.entityTypeName, 'asset_locations'));
final assetDepreciationSyncProcessorProvider = Provider<DepreciationSyncProcessor>((ref) => _processor(ref, AssetDepreciation.entityTypeName, 'asset_depreciation'));
final assetTransferSyncProcessorProvider = Provider<AssetsSyncProcessor>((ref) => _processor(ref, AssetTransfer.entityTypeName, 'asset_transfers'));
final assetDisposalSyncProcessorProvider = Provider<DisposalSyncProcessor>((ref) => _processor(ref, AssetDisposal.entityTypeName, 'asset_disposals'));
final maintenanceRequestSyncProcessorProvider = Provider<MaintenanceSyncProcessor>((ref) => _processor(ref, MaintenanceRequest.entityTypeName, 'maintenance_requests'));
final maintenanceScheduleSyncProcessorProvider = Provider<MaintenanceSyncProcessor>((ref) => _processor(ref, MaintenanceSchedule.entityTypeName, 'maintenance_schedules'));
final maintenanceTaskSyncProcessorProvider = Provider<MaintenanceSyncProcessor>((ref) => _processor(ref, MaintenanceTask.entityTypeName, 'maintenance_tasks'));
final maintenanceCostSyncProcessorProvider = Provider<MaintenanceSyncProcessor>((ref) => _processor(ref, MaintenanceCost.entityTypeName, 'maintenance_costs'));
final serviceContractSyncProcessorProvider = Provider<AssetsSyncProcessor>((ref) => _processor(ref, ServiceContract.entityTypeName, 'service_contracts'));
final warrantySyncProcessorProvider = Provider<AssetsSyncProcessor>((ref) => _processor(ref, Warranty.entityTypeName, 'warranties'));
final assetAuditSyncProcessorProvider = Provider<AssetsSyncProcessor>((ref) => _processor(ref, AssetAudit.entityTypeName, 'asset_audits'));
final assetSettingsSyncProcessorProvider = Provider<AssetsSyncProcessor>((ref) => _processor(ref, AssetSettings.entityTypeName, 'asset_settings'));
