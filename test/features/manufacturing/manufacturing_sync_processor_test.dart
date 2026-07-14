import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/manufacturing/data/datasources/manufacturing_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/data/sync/manufacturing_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/bom.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/material.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/planning.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/production.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/quality.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/work_order.dart';

void main() {
  test('manufacturing sync processors map entity types to remote tables', () {
    final remote = ManufacturingRemoteDataSource();
    final bom = ManufacturingSyncProcessor(remote: remote, entityTypeName: BillOfMaterial.entityTypeName, remoteTable: 'bills_of_materials');
    final bomLine = ManufacturingSyncProcessor(remote: remote, entityTypeName: BomLine.entityTypeName, remoteTable: 'bom_lines');
    final bomVersion = ManufacturingSyncProcessor(remote: remote, entityTypeName: BomVersion.entityTypeName, remoteTable: 'bom_versions');
    final production = ManufacturingSyncProcessor(remote: remote, entityTypeName: ProductionOrder.entityTypeName, remoteTable: 'production_orders');
    final workOrder = ManufacturingSyncProcessor(remote: remote, entityTypeName: WorkOrder.entityTypeName, remoteTable: 'work_orders');
    final materialIssue = ManufacturingSyncProcessor(remote: remote, entityTypeName: MaterialIssue.entityTypeName, remoteTable: 'material_issues');
    final output = ManufacturingSyncProcessor(remote: remote, entityTypeName: ProductionOutput.entityTypeName, remoteTable: 'production_outputs');
    final quality = ManufacturingSyncProcessor(remote: remote, entityTypeName: QualityInspection.entityTypeName, remoteTable: 'quality_inspections');
    final capacity = ManufacturingSyncProcessor(remote: remote, entityTypeName: CapacityPlan.entityTypeName, remoteTable: 'capacity_plans');

    expect(bom.entityType, 'bill_of_material');
    expect(bomLine.entityType, 'bom_line');
    expect(bomVersion.entityType, 'bom_version');
    expect(production.entityType, 'production_order');
    expect(workOrder.entityType, 'work_order');
    expect(materialIssue.entityType, 'material_issue');
    expect(output.entityType, 'production_output');
    expect(quality.entityType, 'quality_inspection');
    expect(capacity.entityType, 'capacity_plan');
  });
}
