import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/features/workflow/domain/enums/workflow_enums.dart';

/// Extended approval pattern configuration.
class ApprovalPattern extends Equatable {
  const ApprovalPattern({
    required this.type,
    this.requiredApprovers = 1,
    this.requiredPercentage,
    this.departmentId,
    this.roleId,
    this.userId,
    this.minAmount,
    this.maxAmount,
    this.conditionField,
    this.conditionValue,
  });

  final ApprovalPatternType type;
  final int requiredApprovers;
  final double? requiredPercentage;
  final String? departmentId;
  final String? roleId;
  final String? userId;
  final double? minAmount;
  final double? maxAmount;
  final String? conditionField;
  final dynamic conditionValue;

  bool matchesContext({
    double? amount,
    String? departmentId,
    String? roleId,
    String? userId,
    Map<String, dynamic>? context,
  }) {
    return switch (type) {
      ApprovalPatternType.sequential => true,
      ApprovalPatternType.parallel => true,
      ApprovalPatternType.conditional => _matchesCondition(context),
      ApprovalPatternType.percentage => true,
      ApprovalPatternType.department => departmentId == null || this.departmentId == departmentId,
      ApprovalPatternType.role => roleId == null || this.roleId == roleId,
      ApprovalPatternType.user => userId == null || this.userId == userId,
      ApprovalPatternType.amount => _matchesAmount(amount),
    };
  }

  bool _matchesAmount(double? amount) {
    if (amount == null) return minAmount == null && maxAmount == null;
    if (minAmount != null && amount < minAmount!) return false;
    if (maxAmount != null && amount > maxAmount!) return false;
    return true;
  }

  bool _matchesCondition(Map<String, dynamic>? context) {
    if (conditionField == null || context == null) return true;
    return '${context[conditionField]}' == '$conditionValue';
  }

  Map<String, dynamic> toJson() => {
        'type': type.value,
        'required_approvers': requiredApprovers,
        'required_percentage': requiredPercentage,
        'department_id': departmentId,
        'role_id': roleId,
        'user_id': userId,
        'min_amount': minAmount,
        'max_amount': maxAmount,
        'condition_field': conditionField,
        'condition_value': conditionValue,
      };

  static ApprovalPattern fromJson(Map<String, dynamic> json) => ApprovalPattern(
        type: ApprovalPatternType.fromValue(json['type'] as String?),
        requiredApprovers: json['required_approvers'] as int? ?? 1,
        requiredPercentage: (json['required_percentage'] as num?)?.toDouble(),
        departmentId: json['department_id'] as String?,
        roleId: json['role_id'] as String?,
        userId: json['user_id'] as String?,
        minAmount: (json['min_amount'] as num?)?.toDouble(),
        maxAmount: (json['max_amount'] as num?)?.toDouble(),
        conditionField: json['condition_field'] as String?,
        conditionValue: json['condition_value'],
      );

  @override
  List<Object?> get props => [type, requiredApprovers, departmentId, roleId, userId];
}

/// Step in an extended approval flow.
class ExtendedApprovalStep extends Equatable {
  const ExtendedApprovalStep({
    required this.order,
    required this.name,
    required this.patterns,
    this.isOptional = false,
  });

  final int order;
  final String name;
  final List<ApprovalPattern> patterns;
  final bool isOptional;

  Map<String, dynamic> toJson() => {
        'order': order,
        'name': name,
        'patterns': patterns.map((p) => p.toJson()).toList(),
        'is_optional': isOptional,
      };

  static ExtendedApprovalStep fromJson(Map<String, dynamic> json) => ExtendedApprovalStep(
        order: json['order'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        patterns: (json['patterns'] as List? ?? [])
            .map((p) => ApprovalPattern.fromJson(Map<String, dynamic>.from(p as Map)))
            .toList(),
        isOptional: json['is_optional'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [order, name, patterns, isOptional];
}

/// Resolved extended approval plan for a request context.
class ExtendedApprovalPlan extends Equatable {
  const ExtendedApprovalPlan({
    required this.steps,
    this.skippedOptional = 0,
  });

  final List<ExtendedApprovalStep> steps;
  final int skippedOptional;

  bool get hasSteps => steps.isNotEmpty;

  int get totalSteps => steps.length;

  @override
  List<Object?> get props => [steps, skippedOptional];
}

/// Vote tally for parallel/percentage approval patterns.
class ApprovalVoteTally extends Equatable {
  const ApprovalVoteTally({
    required this.approved,
    required this.rejected,
    required this.totalEligible,
  });

  final int approved;
  final int rejected;
  final int totalEligible;

  double get approvalRate => totalEligible == 0 ? 0 : approved / totalEligible;

  bool meetsPercentage(double requiredPercentage) => approvalRate * 100 >= requiredPercentage;

  @override
  List<Object?> get props => [approved, rejected, totalEligible];
}

/// Analytics snapshot for approval patterns.
class ApprovalAnalyticsSnapshot extends Equatable {
  const ApprovalAnalyticsSnapshot({
    required this.totalRequests,
    required this.approvedCount,
    required this.rejectedCount,
    required this.avgResolutionHours,
    required this.byPattern,
  });

  final int totalRequests;
  final int approvedCount;
  final int rejectedCount;
  final double avgResolutionHours;
  final Map<ApprovalPatternType, int> byPattern;

  double get approvalRate => totalRequests == 0 ? 0 : approvedCount / totalRequests;

  @override
  List<Object?> get props => [totalRequests, approvedCount, rejectedCount, avgResolutionHours];
}
