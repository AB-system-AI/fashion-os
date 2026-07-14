import 'package:collection/collection.dart';

import 'package:fashion_pos_enterprise/core/business/domain/entities/rule_models.dart';
import 'package:fashion_pos_enterprise/core/business/engines/notification_engine.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';

/// Action handler for business rules.
typedef RuleActionHandler = Future<void> Function(RuleAction action, Map<String, dynamic> context);

/// Configurable IF-THEN business rule engine with custom registration.
class RuleEngine {
  RuleEngine({
    List<BusinessRule> rules = const [],
    NotificationEngine? notificationEngine,
  })  : _rules = List.of(rules),
        _notificationEngine = notificationEngine;

  final List<BusinessRule> _rules;
  final NotificationEngine? _notificationEngine;
  final Map<String, RuleActionHandler> _actionHandlers = {};

  void registerRule(BusinessRule rule) => _rules.add(rule);

  void registerActionHandler(String actionType, RuleActionHandler handler) {
    _actionHandlers[actionType] = handler;
  }

  List<RuleEvaluationResult> evaluate(Map<String, dynamic> context) {
    final active = _rules.where((r) => r.isActive).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    return active.map((rule) {
      final matched = rule.condition.evaluate(context);
      return RuleEvaluationResult(
        ruleId: rule.id,
        matched: matched,
        action: matched ? rule.action : null,
        message: matched ? 'Rule ${rule.name} matched' : null,
      );
    }).toList();
  }

  Future<List<RuleEvaluationResult>> evaluateAndExecute(Map<String, dynamic> context) async {
    final results = evaluate(context);
    for (final result in results.where((r) => r.matched && r.action != null)) {
      await _executeAction(result.action!, context);
    }
    return results;
  }

  Future<void> _executeAction(RuleAction action, Map<String, dynamic> context) async {
    final handler = _actionHandlers[action.type];
    if (handler != null) {
      await handler(action, context);
      return;
    }

    if (action.type == 'notify' && _notificationEngine != null) {
      await _notificationEngine!.send(
        NotificationMessage(
          channel: _parseChannel(action.parameters['channel'] as String?),
          title: action.parameters['title'] as String? ?? 'Business Alert',
          body: action.parameters['body'] as String? ?? '',
          recipientId: action.parameters['recipient_id'] as String?,
        ),
      );
    }
  }

  NotificationChannel _parseChannel(String? value) {
    return NotificationChannel.values.firstWhereOrNull((c) => c.name == value) ??
        NotificationChannel.inApp;
  }
}
