/// Generates insights from automation execution history.
abstract class InsightsService {
  Future<List<String>> generateInsights({required String tenantId});

  Future<Map<String, dynamic>> summarizePerformance({required String tenantId});
}

class DefaultInsightsService implements InsightsService {
  @override
  Future<List<String>> generateInsights({required String tenantId}) async => const [];

  @override
  Future<Map<String, dynamic>> summarizePerformance({required String tenantId}) async => const {};
}
