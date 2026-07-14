import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/asset.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/audit.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/contracts.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/depreciation.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/disposal.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/maintenance.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/settings.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/transfer.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/enums/assets_enums.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/repositories/assets_repositories.dart';

typedef AssetsEntityMapper<T> = T Function(Map<String, dynamic> json, LocalRecord record);

class AssetsRepositoryImpl<T extends SyncableEntity> extends BaseLocalRepository<T> {
  AssetsRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
    required String entityType,
    required this.fromPayload,
    required this.toSearchFields,
  })  : _database = database,
        _syncQueue = syncQueue,
        super(database: database, entityType: entityType, syncQueue: syncQueue);

  final AppDatabase _database;
  final SyncQueueWriter _syncQueue;
  final AssetsEntityMapper<T> fromPayload;
  final ({String? name, String? sku, String? barcode, String? storeId}) Function(T entity) toSearchFields;

  @override
  T mapFromLocalRecord(LocalRecord record) => fromPayload(record.payload, record);

  @override
  LocalRecord mapToLocalRecord(T entity) {
    final search = toSearchFields(entity);
    return LocalRecord(
      id: entity.id,
      tenantId: entity.tenantId,
      entityType: entity.entityType,
      storeId: search.storeId,
      payload: entity.toPayload(),
      version: entity.version,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      syncStatus: entity.syncStatus,
      isDirty: entity.isDirty,
      searchName: search.name,
      searchSku: search.sku,
      searchBarcode: search.barcode,
    );
  }

  AssetsRepositoryImpl<R> child<R extends SyncableEntity>({
    required String entityType,
    required AssetsEntityMapper<R> fromPayload,
    required ({String? name, String? sku, String? barcode, String? storeId}) Function(R) toSearch,
  }) =>
      AssetsRepositoryImpl<R>(
        database: _database,
        syncQueue: _syncQueue,
        entityType: entityType,
        fromPayload: fromPayload,
        toSearchFields: toSearch,
      );
}

class AssetLocalRepository extends AssetsRepositoryImpl<Asset> implements AssetRepository {
  AssetLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: Asset.entityTypeName,
          fromPayload: Asset.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.assetTag, barcode: e.serialNumber, storeId: null),
        );

  @override
  Future<List<Asset>> listByStatus(String tenantId, AssetStatus status) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((a) => a.status == status && a.deletedAt == null).toList();
  }

  @override
  Future<List<Asset>> listByLocation(String tenantId, String locationId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((a) => a.locationId == locationId && a.deletedAt == null).toList();
  }

  @override
  Future<List<Asset>> listByCategory(String tenantId, String categoryId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((a) => a.categoryId == categoryId && a.deletedAt == null).toList();
  }
}

class AssetCategoryLocalRepository extends AssetsRepositoryImpl<AssetCategory> implements AssetCategoryRepository {
  AssetCategoryLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: AssetCategory.entityTypeName,
          fromPayload: AssetCategory.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.code, barcode: null, storeId: null),
        );

  @override
  Future<List<AssetCategory>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((c) => c.deletedAt == null).toList();
  }
}

class AssetLocationLocalRepository extends AssetsRepositoryImpl<AssetLocation> implements AssetLocationRepository {
  AssetLocationLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: AssetLocation.entityTypeName,
          fromPayload: AssetLocation.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.code, barcode: e.storeId, storeId: e.storeId),
        );

  @override
  Future<List<AssetLocation>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((l) => l.deletedAt == null).toList();
  }
}

class AssetDepreciationLocalRepository extends AssetsRepositoryImpl<AssetDepreciation> implements AssetDepreciationRepository {
  AssetDepreciationLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: AssetDepreciation.entityTypeName,
          fromPayload: AssetDepreciation.fromPayload,
          toSearchFields: (e) => (name: e.assetId, sku: '${e.period}', barcode: null, storeId: null),
        );

  @override
  Future<List<AssetDepreciation>> listByAsset(String tenantId, String assetId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((d) => d.assetId == assetId).toList()..sort((a, b) => a.period.compareTo(b.period));
  }

  @override
  Future<AssetDepreciation?> latestForAsset(String tenantId, String assetId) async {
    final list = await listByAsset(tenantId, assetId);
    return list.isEmpty ? null : list.last;
  }
}

class AssetTransferLocalRepository extends AssetsRepositoryImpl<AssetTransfer> implements AssetTransferRepository {
  AssetTransferLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: AssetTransfer.entityTypeName,
          fromPayload: AssetTransfer.fromPayload,
          toSearchFields: (e) => (name: e.assetId, sku: e.status.value, barcode: e.toLocationId, storeId: null),
        );

  @override
  Future<List<AssetTransfer>> listByAsset(String tenantId, String assetId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((t) => t.assetId == assetId).toList();
  }

  @override
  Future<List<AssetTransfer>> listPending(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((t) => t.status == TransferStatus.pending || t.status == TransferStatus.inTransit).toList();
  }
}

class AssetDisposalLocalRepository extends AssetsRepositoryImpl<AssetDisposal> implements AssetDisposalRepository {
  AssetDisposalLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: AssetDisposal.entityTypeName,
          fromPayload: AssetDisposal.fromPayload,
          toSearchFields: (e) => (name: e.assetId, sku: e.method.value, barcode: null, storeId: null),
        );

  @override
  Future<List<AssetDisposal>> listByAsset(String tenantId, String assetId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((d) => d.assetId == assetId).toList();
  }
}

class MaintenanceRequestLocalRepository extends AssetsRepositoryImpl<MaintenanceRequest> implements MaintenanceRequestRepository {
  MaintenanceRequestLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: MaintenanceRequest.entityTypeName,
          fromPayload: MaintenanceRequest.fromPayload,
          toSearchFields: (e) => (name: e.title, sku: e.assetId, barcode: e.status.value, storeId: null),
        );

  @override
  Future<List<MaintenanceRequest>> listByAsset(String tenantId, String assetId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((r) => r.assetId == assetId).toList();
  }

  @override
  Future<List<MaintenanceRequest>> listOpen(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((r) => r.status != MaintenanceRequestStatus.completed && r.status != MaintenanceRequestStatus.cancelled).toList();
  }
}

class MaintenanceScheduleLocalRepository extends AssetsRepositoryImpl<MaintenanceSchedule> implements MaintenanceScheduleRepository {
  MaintenanceScheduleLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: MaintenanceSchedule.entityTypeName,
          fromPayload: MaintenanceSchedule.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.assetId, barcode: null, storeId: null),
        );

  @override
  Future<List<MaintenanceSchedule>> listDue(String tenantId, DateTime before) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((s) => s.isActive && s.nextDueAt != null && !s.nextDueAt!.isAfter(before)).toList();
  }

  @override
  Future<List<MaintenanceSchedule>> listByAsset(String tenantId, String assetId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((s) => s.assetId == assetId).toList();
  }
}

class MaintenanceTaskLocalRepository extends AssetsRepositoryImpl<MaintenanceTask> implements MaintenanceTaskRepository {
  MaintenanceTaskLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: MaintenanceTask.entityTypeName,
          fromPayload: MaintenanceTask.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.requestId, barcode: null, storeId: null),
        );

  @override
  Future<List<MaintenanceTask>> listByRequest(String tenantId, String requestId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((t) => t.requestId == requestId).toList();
  }
}

class MaintenanceCostLocalRepository extends AssetsRepositoryImpl<MaintenanceCost> implements MaintenanceCostRepository {
  MaintenanceCostLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: MaintenanceCost.entityTypeName,
          fromPayload: MaintenanceCost.fromPayload,
          toSearchFields: (e) => (name: e.costType, sku: e.requestId, barcode: null, storeId: null),
        );

  @override
  Future<List<MaintenanceCost>> listByRequest(String tenantId, String requestId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((c) => c.requestId == requestId).toList();
  }

  @override
  Future<double> totalByAsset(String tenantId, String assetId) async {
    final requests = await _database.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: MaintenanceRequest.entityTypeName, pageSize: 500),
    );
    final requestIds = requests.map((r) => MaintenanceRequest.fromPayload(r.payload, r)).where((r) => r.assetId == assetId).map((r) => r.id).toSet();
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((c) => requestIds.contains(c.requestId)).fold(0.0, (s, c) => s + c.amount);
  }
}

class ServiceContractLocalRepository extends AssetsRepositoryImpl<ServiceContract> implements ServiceContractRepository {
  ServiceContractLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: ServiceContract.entityTypeName,
          fromPayload: ServiceContract.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.assetId, barcode: e.vendorId, storeId: null),
        );

  @override
  Future<List<ServiceContract>> listActive(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((c) => c.isActive).toList();
  }

  @override
  Future<List<ServiceContract>> listByAsset(String tenantId, String assetId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((c) => c.assetId == assetId).toList();
  }
}

class WarrantyLocalRepository extends AssetsRepositoryImpl<Warranty> implements WarrantyRepository {
  WarrantyLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: Warranty.entityTypeName,
          fromPayload: Warranty.fromPayload,
          toSearchFields: (e) => (name: e.provider, sku: e.assetId, barcode: e.status.value, storeId: null),
        );

  @override
  Future<List<Warranty>> listByAsset(String tenantId, String assetId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((w) => w.assetId == assetId).toList();
  }

  @override
  Future<List<Warranty>> listExpiring(String tenantId, DateTime before) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((w) => w.endDate != null && !w.endDate!.isAfter(before) && w.status == WarrantyStatus.active).toList();
  }
}

class AssetAuditLocalRepository extends AssetsRepositoryImpl<AssetAudit> implements AssetAuditRepository {
  AssetAuditLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: AssetAudit.entityTypeName,
          fromPayload: AssetAudit.fromPayload,
          toSearchFields: (e) => (name: e.name, sku: e.status.value, barcode: e.locationId, storeId: null),
        );

  @override
  Future<List<AssetAudit>> listByStatus(String tenantId, AssetAuditStatus status) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 500));
    return page.items.where((a) => a.status == status).toList();
  }
}

class AssetSettingsLocalRepository extends AssetsRepositoryImpl<AssetSettings> implements AssetSettingsRepository {
  AssetSettingsLocalRepository({required AppDatabase database, required SyncQueueWriter syncQueue})
      : super(
          database: database,
          syncQueue: syncQueue,
          entityType: AssetSettings.entityTypeName,
          fromPayload: AssetSettings.fromPayload,
          toSearchFields: (e) => (name: e.tenantId, sku: null, barcode: null, storeId: null),
        );

  @override
  Future<AssetSettings?> getSettings(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1));
    return page.items.isEmpty ? null : page.items.first;
  }

  @override
  Future<AssetSettings> saveSettings(AssetSettings settings) => update(settings);
}
