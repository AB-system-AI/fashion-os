import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';

/// Configurable business rule (IF condition THEN action).
class BusinessRule extends Equatable {
  const BusinessRule({
    required this.id,
    required this.name,
    required this.condition,
    required this.action,
    this.priority = 0,
    this.isActive = true,
    this.metadata = const {},
  });

  final String id;
  final String name;
  final RuleCondition condition;
  final RuleAction action;
  final int priority;
  final bool isActive;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [id, name, priority];
}

/// Rule condition expression.
class RuleCondition extends Equatable {
  const RuleCondition({
    required this.field,
    required this.operator,
    required this.value,
  });

  final String field;
  final RuleOperator operator;
  final dynamic value;

  bool evaluate(Map<String, dynamic> context) {
    final actual = context[field];
    if (actual == null) return false;
    return switch (operator) {
      RuleOperator.lessThan => _num(actual) < _num(value),
      RuleOperator.lessThanOrEqual => _num(actual) <= _num(value),
      RuleOperator.greaterThan => _num(actual) > _num(value),
      RuleOperator.greaterThanOrEqual => _num(actual) >= _num(value),
      RuleOperator.equal => actual == value,
      RuleOperator.notEqual => actual != value,
    };
  }

  double _num(dynamic v) => v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0;

  @override
  List<Object?> get props => [field, operator, value];
}

/// Rule action to execute when condition matches.
class RuleAction extends Equatable {
  const RuleAction({
    required this.type,
    required this.parameters,
  });

  final String type;
  final Map<String, dynamic> parameters;

  @override
  List<Object?> get props => [type, parameters];
}

/// Result of rule evaluation.
class RuleEvaluationResult extends Equatable {
  const RuleEvaluationResult({
    required this.ruleId,
    required this.matched,
    this.action,
    this.message,
  });

  final String ruleId;
  final bool matched;
  final RuleAction? action;
  final String? message;

  @override
  List<Object?> get props => [ruleId, matched];
}

/// Number sequence format template.
class NumberSequenceFormat extends Equatable {
  const NumberSequenceFormat({
    required this.type,
    required this.prefix,
    required this.padding,
    this.suffix = '',
    this.includeDate = true,
    this.dateFormat = 'yyyyMMdd',
  });

  final DocumentNumberType type;
  final String prefix;
  final int padding;
  final String suffix;
  final bool includeDate;
  final String dateFormat;

  String format(int sequence, DateTime at) {
    final padded = sequence.toString().padLeft(padding, '0');
    final datePart = includeDate
        ? '${at.year}${at.month.toString().padLeft(2, '0')}${at.day.toString().padLeft(2, '0')}'
        : '';
    return '$prefix$datePart$padded$suffix';
  }

  @override
  List<Object?> get props => [type, prefix, padding];
}

/// Generated document number.
class GeneratedNumber extends Equatable {
  const GeneratedNumber({
    required this.type,
    required this.value,
    required this.sequence,
    required this.generatedAt,
  });

  final DocumentNumberType type;
  final String value;
  final int sequence;
  final DateTime generatedAt;

  @override
  List<Object?> get props => [type, value];
}

/// Barcode generation result.
class BarcodePayload extends Equatable {
  const BarcodePayload({
    required this.format,
    required this.value,
    required this.displayValue,
    this.checkDigit,
    this.encodedData,
  });

  final BarcodeFormat format;
  final String value;
  final String displayValue;
  final String? checkDigit;
  final String? encodedData;

  @override
  List<Object?> get props => [format, value];
}
