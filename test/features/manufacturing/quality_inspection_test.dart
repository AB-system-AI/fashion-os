import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/manufacturing/manufacturing_engine.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/enums/manufacturing_enums.dart';

void main() {
  late ManufacturingEngine engine;

  setUp(() {
    engine = ManufacturingEngine();
  });

  test('quality inspection pass when all units pass', () {
    final result = engine.evaluateInspection(inspected: 100, passed: 100, failed: 0);
    expect(result, QualityResult.pass);
  });

  test('quality inspection fail when all units fail', () {
    final result = engine.evaluateInspection(inspected: 50, passed: 0, failed: 50);
    expect(result, QualityResult.fail);
  });

  test('quality inspection hold on mixed results', () {
    final result = engine.evaluateInspection(inspected: 20, passed: 12, failed: 8);
    expect(result, QualityResult.hold);
  });

  test('quality inspection rework when partial pass without fail', () {
    final result = engine.evaluateInspection(inspected: 20, passed: 15, failed: 0);
    expect(result, QualityResult.rework);
  });
}
