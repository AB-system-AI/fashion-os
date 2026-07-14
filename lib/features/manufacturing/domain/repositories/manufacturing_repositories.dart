import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/bom.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/material.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/planning.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/production.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/quality.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/work_center.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/work_order.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/enums/manufacturing_enums.dart';

abstract class ManufacturingRepository implements BaseLocalRepository<ManufacturingSettings> {
  Future<ManufacturingSettings?> getSettings(String tenantId);
  Future<ManufacturingSettings> saveSettings(ManufacturingSettings settings);
}

abstract class BomRepository implements BaseLocalRepository<BillOfMaterial> {
  Future<BillOfMaterial?> findByCode(String tenantId, String code);
  Future<PaginatedResult<BillOfMaterial>> getPage(RepositoryQuery query);
  Future<BomLine> createLine(BomLine line);
  Future<List<BomLine>> listLines(String tenantId, String bomId);
  Future<BomVersion> createVersion(BomVersion version);
}

abstract class ProductionRepository implements BaseLocalRepository<ProductionOrder> {
  Future<ProductionOrder?> findByOrderNumber(String tenantId, String orderNumber);
  Future<List<ProductionOrder>> listByStatus(String tenantId, ProductionStatus status);
  Future<ProductionOrderLine> createLine(ProductionOrderLine line);
  Future<List<ProductionOrderLine>> listLines(String tenantId, String productionOrderId);
  Future<MaterialIssue> createMaterialIssue(MaterialIssue issue);
  Future<MaterialReturn> createMaterialReturn(MaterialReturn materialReturn);
  Future<ProductionOutput> createOutput(ProductionOutput output);
  Future<ProductionScrap> createScrap(ProductionScrap scrap);
  Future<FinishedGoodsReceipt> createFinishedGoodsReceipt(FinishedGoodsReceipt receipt);
  Future<ProductionSchedule> createSchedule(ProductionSchedule schedule);
}

abstract class WorkOrderRepository implements BaseLocalRepository<WorkOrder> {
  Future<List<WorkOrder>> listByProductionOrder(String tenantId, String productionOrderId);
  Future<WorkCenter> createWorkCenter(WorkCenter center);
  Future<Machine> createMachine(Machine machine);
  Future<List<WorkCenter>> listWorkCenters(String tenantId);
  Future<Operation> createOperation(Operation operation);
}

abstract class QualityRepository implements BaseLocalRepository<QualityInspection> {
  Future<List<QualityInspection>> listByProductionOrder(String tenantId, String productionOrderId);
  Future<List<QualityInspection>> listAll(String tenantId);
  Future<MaintenanceRequest> createMaintenance(MaintenanceRequest request);
}

abstract class CapacityRepository implements BaseLocalRepository<CapacityPlan> {
  Future<List<CapacityPlan>> listByWorkCenter(String tenantId, String workCenterId);
  Future<List<CapacityPlan>> listByDateRange(String tenantId, DateTime from, DateTime to);
}
