import 'package:fashion_pos_enterprise/features/automation/domain/value_objects/automation_value_objects.dart';

/// Recommends rules, workflows, and optimizations based on usage patterns.
abstract class RecommendationService {
  Future<List<SmartSuggestion>> recommendRules({required String tenantId});

  Future<List<SmartSuggestion>> recommendWorkflows({required String tenantId});

  Future<List<SmartSuggestion>> recommendSchedules({required String tenantId});
}

class DefaultRecommendationService implements RecommendationService {
  @override
  Future<List<SmartSuggestion>> recommendRules({required String tenantId}) async => const [];

  @override
  Future<List<SmartSuggestion>> recommendWorkflows({required String tenantId}) async => const [];

  @override
  Future<List<SmartSuggestion>> recommendSchedules({required String tenantId}) async => const [];
}
