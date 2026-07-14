import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/manufacturing/manufacturing_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/bom.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/entities/work_center.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/enums/manufacturing_enums.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/value_objects/manufacturing_value_objects.dart';

void main() {
  late ManufacturingEngine engine;

  setUp(() {
    engine = ManufacturingEngine();
  });

  test('explodeBom scales quantities with scrap', () {
    final now = DateTime.utc(2025, 7, 1);
    final bom = BillOfMaterial(
      id: 'b1',
      tenantId: 't1',
      code: 'BOM-001',
      name: 'Shirt BOM',
      finishedProductId: 'p-finished',
      quantity: 1,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    final lines = [
      BomLine(
        id: 'l1',
        tenantId: 't1',
        bomId: 'b1',
        componentProductId: 'fabric',
        quantity: 2,
        scrapPercent: 10,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      ),
    ];

    final reqs = engine.explodeBom(bom: bom, lines: lines, orderQty: 10);
    expect(reqs.length, 1);
    expect(reqs.first.productId, 'fabric');
    expect(reqs.first.requiredQty, 22);
  });

  test('explodeBom supports multi-level sub-BOMs', () {
    final now = DateTime.utc(2025, 7, 1);
    final bom = BillOfMaterial(
      id: 'b1',
      tenantId: 't1',
      code: 'BOM-002',
      name: 'Assembly',
      finishedProductId: 'p-finished',
      quantity: 1,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    final lines = [
      BomLine(
        id: 'l1',
        tenantId: 't1',
        bomId: 'b1',
        componentProductId: 'sub-assembly',
        quantity: 1,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      ),
    ];
    final subLines = [
      BomLine(
        id: 'l2',
        tenantId: 't1',
        bomId: 'b2',
        componentProductId: 'bolt',
        quantity: 4,
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      ),
    ];

    final reqs = engine.explodeBom(
      bom: bom,
      lines: lines,
      orderQty: 5,
      subBomsByProduct: {'sub-assembly': subLines},
    );
    expect(reqs.any((r) => r.productId == 'bolt' && r.requiredQty == 20), isTrue);
  });

  test('detectShortages and suggestPurchases for MRP', () {
    final reqs = [
      const MaterialRequirement(productId: 'a', requiredQty: 100),
      const MaterialRequirement(productId: 'b', requiredQty: 50),
    ];
    final shortages = engine.detectShortages(
      requirements: reqs,
      availableStock: {'a': 60, 'b': 80},
    );
    expect(shortages.length, 1);
    expect(shortages.first.productId, 'a');
    expect(shortages.first.shortage, 40);

    final purchases = engine.suggestPurchases(shortages);
    expect(purchases.first.suggestedQty, 40);
  });

  test('calculateProductionCost includes labor and overhead', () {
    final cost = engine.calculateProductionCost(
      materialCost: 500,
      laborHours: 10,
      laborRate: 20,
      overheadRate: 0.5,
      completedQty: 25,
    );
    expect(cost.laborCost, 200);
    expect(cost.overheadCost, 100);
    expect(cost.totalCost, 800);
    expect(cost.unitCost, 32);
  });

  test('calculateVariance tracks yield and scrap', () {
    final variance = engine.calculateVariance(plannedQty: 100, completedQty: 90, scrappedQty: 5);
    expect(variance.yieldVariance, lessThan(0));
    expect(variance.scrapVariance, greaterThan(0));
  });

  test('calculateCapacity detects overloaded work center', () {
    final wc = WorkCenter(
      id: 'wc1',
      tenantId: 't1',
      code: 'WC-01',
      name: 'Sewing',
      capacityHoursPerDay: 8,
      costPerHour: 25,
      version: 1,
      createdAt: DateTime.utc(2025),
      updatedAt: DateTime.utc(2025),
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    final cap = engine.calculateCapacity(workCenter: wc, scheduledHours: 10, utilizedHours: 9);
    expect(cap.scheduled, 10);
    expect(cap.remaining, 0);
  });

  test('validateProductionTransition rejects invalid moves', () {
    expect(
      engine.validateProductionTransition(ProductionStatus.draft, ProductionStatus.completed).isFailure,
      isTrue,
    );
    expect(
      engine.validateProductionTransition(ProductionStatus.draft, ProductionStatus.planned).isSuccess,
      isTrue,
    );
  });

  test('evaluateInspection returns pass fail hold rework', () {
    expect(engine.evaluateInspection(inspected: 10, passed: 10, failed: 0), QualityResult.pass);
    expect(engine.evaluateInspection(inspected: 10, passed: 0, failed: 10), QualityResult.fail);
    expect(engine.evaluateInspection(inspected: 10, passed: 5, failed: 5), QualityResult.hold);
  });

  test('expectedCompletion uses operation duration', () {
    final start = DateTime.utc(2025, 7, 1, 8);
    const duration = OperationDuration(setupMinutes: 30, runMinutesPerUnit: 6);
    final end = engine.expectedCompletion(start: start, remainingQty: 5, duration: duration);
    expect(end, start.add(const Duration(minutes: 60)));
  });
}
