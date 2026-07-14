import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/hr/hr_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/manufacturing/manufacturing_engine.dart';

void main() {
  test('work order labor cost uses HR overtime calculation', () {
    final hr = HREngine();
    final mfg = ManufacturingEngine();
    final overtime = hr.calculateOvertimeAmount(hourlyRate: 20, hours: 2);
    expect(overtime, 60);
    final cost = mfg.calculateProductionCost(
      materialCost: 100,
      laborHours: 10,
      laborRate: 20,
      overheadRate: 0.25,
      completedQty: 5,
    );
    expect(cost.laborCost, 200);
    expect(cost.totalCost, greaterThan(100));
  });
}
