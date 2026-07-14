import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/business/di/business_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/data/datasources/manufacturing_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/data/repositories/manufacturing_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/data/sync/manufacturing_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/bom.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/material.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/planning.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/production.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/quality.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/work_order.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/repositories/manufacturing_repositories.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/services/manufacturing_integration_service.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/services/manufacturing_services.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/providers/purchasing_providers.dart';

final manufacturingRemoteDataSourceProvider = Provider<ManufacturingRemoteDataSource>((ref) => ManufacturingRemoteDataSource());

final manufacturingSettingsRepositoryProvider = Provider<ManufacturingRepository>((ref) {
  return ManufacturingLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final bomRepositoryProvider = Provider<BomRepository>((ref) {
  return BomLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final productionRepositoryProvider = Provider<ProductionRepository>((ref) {
  return ProductionLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final workOrderRepositoryProvider = Provider<WorkOrderRepository>((ref) {
  return WorkOrderLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final qualityRepositoryProvider = Provider<QualityRepository>((ref) {
  return QualityLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final capacityRepositoryProvider = Provider<CapacityRepository>((ref) {
  return CapacityLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final bomServiceProvider = Provider<BomService>((ref) => BomService(
      repository: ref.watch(bomRepositoryProvider),
      engine: ref.watch(manufacturingEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final productionPlanningServiceProvider = Provider<ProductionPlanningService>((ref) => ProductionPlanningService(
      bomRepository: ref.watch(bomRepositoryProvider),
      capacityRepository: ref.watch(capacityRepositoryProvider),
      engine: ref.watch(manufacturingEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
      stockMovement: ref.watch(stockMovementServiceProvider),
      productRepository: ref.watch(productRepositoryProvider),
      purchaseOrderService: ref.watch(purchaseOrderServiceProvider),
    ));

final productionOrderServiceProvider = Provider<ProductionOrderService>((ref) => ProductionOrderService(
      repository: ref.watch(productionRepositoryProvider),
      bomRepository: ref.watch(bomRepositoryProvider),
      engine: ref.watch(manufacturingEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      numberGenerator: ref.watch(numberGeneratorEngineProvider),
      stockMovement: ref.watch(stockMovementServiceProvider),
      stockLevels: ref.watch(stockLevelRepositoryProvider),
      reservations: ref.watch(stockReservationRepositoryProvider),
      inventoryEngine: ref.watch(inventoryEngineProvider),
      planningService: ref.watch(productionPlanningServiceProvider),
    ));

final workOrderServiceProvider = Provider<WorkOrderService>((ref) => WorkOrderService(
      repository: ref.watch(workOrderRepositoryProvider),
      engine: ref.watch(manufacturingEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      numberGenerator: ref.watch(numberGeneratorEngineProvider),
      hrEngine: ref.watch(hrEngineProvider),
    ));

final materialConsumptionServiceProvider = Provider<MaterialConsumptionService>((ref) => MaterialConsumptionService(
      repository: ref.watch(productionRepositoryProvider),
      engine: ref.watch(manufacturingEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      stockMovement: ref.watch(stockMovementServiceProvider),
    ));

final productionReceiptServiceProvider = Provider<ProductionReceiptService>((ref) => ProductionReceiptService(
      repository: ref.watch(productionRepositoryProvider),
      engine: ref.watch(manufacturingEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
      stockMovement: ref.watch(stockMovementServiceProvider),
    ));

final qualityInspectionServiceProvider = Provider<QualityInspectionService>((ref) => QualityInspectionService(
      repository: ref.watch(qualityRepositoryProvider),
      engine: ref.watch(manufacturingEngineProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final capacityPlanningServiceProvider = Provider<CapacityPlanningService>((ref) => CapacityPlanningService(
      repository: ref.watch(capacityRepositoryProvider),
      workOrderRepository: ref.watch(workOrderRepositoryProvider),
      engine: ref.watch(manufacturingEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final maintenanceServiceProvider = Provider<MaintenanceService>((ref) => MaintenanceService(
      repository: ref.watch(qualityRepositoryProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final manufacturingReportServiceProvider = Provider<ManufacturingReportService>((ref) => ManufacturingReportService(
      engine: ref.watch(manufacturingEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
      productionRepository: ref.watch(productionRepositoryProvider),
      workOrderRepository: ref.watch(workOrderRepositoryProvider),
      capacityRepository: ref.watch(capacityRepositoryProvider),
    ));

final manufacturingBarcodeServiceProvider = Provider<ManufacturingBarcodeService>((ref) => ManufacturingBarcodeService(
      permissions: ref.watch(permissionEngineProvider),
      productionRepository: ref.watch(productionRepositoryProvider),
      workOrderRepository: ref.watch(workOrderRepositoryProvider),
      materialConsumption: ref.watch(materialConsumptionServiceProvider),
      productionReceipt: ref.watch(productionReceiptServiceProvider),
    ));

final manufacturingIntegrationServiceProvider = Provider<ManufacturingIntegrationService>((ref) {
  return ManufacturingIntegrationService(
    eventBus: ref.watch(domainEventBusProvider),
    audit: ref.watch(auditServiceProvider),
    productionRepository: ref.watch(productionRepositoryProvider),
  );
});

ManufacturingSyncProcessor _processor(Ref ref, String entityType, String table) => ManufacturingSyncProcessor(
      remote: ref.watch(manufacturingRemoteDataSourceProvider),
      entityTypeName: entityType,
      remoteTable: table,
    );

final bomSyncProcessorProvider = Provider<BomSyncProcessor>((ref) => _processor(ref, BillOfMaterial.entityTypeName, 'bills_of_materials'));
final bomLineSyncProcessorProvider = Provider<ManufacturingSyncProcessor>((ref) => _processor(ref, BomLine.entityTypeName, 'bom_lines'));
final bomVersionSyncProcessorProvider = Provider<ManufacturingSyncProcessor>((ref) => _processor(ref, BomVersion.entityTypeName, 'bom_versions'));
final productionSyncProcessorProvider = Provider<ProductionSyncProcessor>((ref) => _processor(ref, ProductionOrder.entityTypeName, 'production_orders'));
final workOrderSyncProcessorProvider = Provider<WorkOrderSyncProcessor>((ref) => _processor(ref, WorkOrder.entityTypeName, 'work_orders'));
final materialIssueSyncProcessorProvider = Provider<MaterialIssueSyncProcessor>((ref) => _processor(ref, MaterialIssue.entityTypeName, 'material_issues'));
final productionOutputSyncProcessorProvider = Provider<ProductionOutputSyncProcessor>((ref) => _processor(ref, ProductionOutput.entityTypeName, 'production_outputs'));
final qualityInspectionSyncProcessorProvider = Provider<QualityInspectionSyncProcessor>((ref) => _processor(ref, QualityInspection.entityTypeName, 'quality_inspections'));
final capacityPlanSyncProcessorProvider = Provider<CapacityPlanSyncProcessor>((ref) => _processor(ref, CapacityPlan.entityTypeName, 'capacity_plans'));
