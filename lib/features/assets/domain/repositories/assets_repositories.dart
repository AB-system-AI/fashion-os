import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/asset.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/audit.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/contracts.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/depreciation.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/disposal.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/maintenance.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/settings.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/transfer.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/enums/assets_enums.dart';

abstract class AssetRepository implements BaseLocalRepository<Asset> {
  Future<List<Asset>> listByStatus(String tenantId, AssetStatus status);
  Future<List<Asset>> listByLocation(String tenantId, String locationId);
  Future<List<Asset>> listByCategory(String tenantId, String categoryId);
}

abstract class AssetCategoryRepository implements BaseLocalRepository<AssetCategory> {
  Future<List<AssetCategory>> listActive(String tenantId);
}

abstract class AssetLocationRepository implements BaseLocalRepository<AssetLocation> {
  Future<List<AssetLocation>> listActive(String tenantId);
}

abstract class AssetDepreciationRepository implements BaseLocalRepository<AssetDepreciation> {
  Future<List<AssetDepreciation>> listByAsset(String tenantId, String assetId);
  Future<AssetDepreciation?> latestForAsset(String tenantId, String assetId);
}

abstract class AssetTransferRepository implements BaseLocalRepository<AssetTransfer> {
  Future<List<AssetTransfer>> listByAsset(String tenantId, String assetId);
  Future<List<AssetTransfer>> listPending(String tenantId);
}

abstract class AssetDisposalRepository implements BaseLocalRepository<AssetDisposal> {
  Future<List<AssetDisposal>> listByAsset(String tenantId, String assetId);
}

abstract class MaintenanceRequestRepository implements BaseLocalRepository<MaintenanceRequest> {
  Future<List<MaintenanceRequest>> listByAsset(String tenantId, String assetId);
  Future<List<MaintenanceRequest>> listOpen(String tenantId);
}

abstract class MaintenanceScheduleRepository implements BaseLocalRepository<MaintenanceSchedule> {
  Future<List<MaintenanceSchedule>> listDue(String tenantId, DateTime before);
  Future<List<MaintenanceSchedule>> listByAsset(String tenantId, String assetId);
}

abstract class MaintenanceTaskRepository implements BaseLocalRepository<MaintenanceTask> {
  Future<List<MaintenanceTask>> listByRequest(String tenantId, String requestId);
}

abstract class MaintenanceCostRepository implements BaseLocalRepository<MaintenanceCost> {
  Future<List<MaintenanceCost>> listByRequest(String tenantId, String requestId);
  Future<double> totalByAsset(String tenantId, String assetId);
}

abstract class ServiceContractRepository implements BaseLocalRepository<ServiceContract> {
  Future<List<ServiceContract>> listActive(String tenantId);
  Future<List<ServiceContract>> listByAsset(String tenantId, String assetId);
}

abstract class WarrantyRepository implements BaseLocalRepository<Warranty> {
  Future<List<Warranty>> listByAsset(String tenantId, String assetId);
  Future<List<Warranty>> listExpiring(String tenantId, DateTime before);
}

abstract class AssetAuditRepository implements BaseLocalRepository<AssetAudit> {
  Future<List<AssetAudit>> listByStatus(String tenantId, AssetAuditStatus status);
}

abstract class AssetSettingsRepository implements BaseLocalRepository<AssetSettings> {
  Future<AssetSettings?> getSettings(String tenantId);
  Future<AssetSettings> saveSettings(AssetSettings settings);
}
