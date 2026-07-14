import 'package:fashion_pos_enterprise/core/business/domain/entities/rule_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/rule_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RuleEngine', () {
    late RuleEngine engine;

    setUp(() {
      engine = RuleEngine();
    });

    test('evaluates stock below minimum rule', () {
      engine.registerRule(
        const BusinessRule(
          id: 'r1',
          name: 'Low Stock Alert',
          priority: 10,
          condition: RuleCondition(
            field: 'stock',
            operator: RuleOperator.lessThan,
            value: 10,
          ),
          action: RuleAction(
            type: 'notify',
            parameters: {'title': 'Low Stock', 'body': 'Reorder needed'},
          ),
        ),
      );

      final results = engine.evaluate({'stock': 5});
      expect(results, hasLength(1));
      expect(results.first.matched, isTrue);
    });

    test('does not match when condition fails', () {
      engine.registerRule(
        const BusinessRule(
          id: 'r2',
          name: 'VIP Upgrade',
          condition: RuleCondition(
            field: 'points',
            operator: RuleOperator.greaterThan,
            value: 1000,
          ),
          action: RuleAction(type: 'upgrade_tier', parameters: {'tier': 'gold'}),
        ),
      );

      final results = engine.evaluate({'points': 500});
      expect(results.first.matched, isFalse);
    });

    test('executes custom action handler', () async {
      var executed = false;
      engine.registerActionHandler('custom_action', (_, __) async {
        executed = true;
      });
      engine.registerRule(
        const BusinessRule(
          id: 'r3',
          name: 'Custom',
          condition: RuleCondition(
            field: 'flag',
            operator: RuleOperator.equal,
            value: true,
          ),
          action: RuleAction(type: 'custom_action', parameters: {}),
        ),
      );

      await engine.evaluateAndExecute({'flag': true});
      expect(executed, isTrue);
    });
  });
}
