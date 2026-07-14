/// Natural language query interface for automation data.
abstract class NaturalLanguageQueryService {
  Future<String> ask({required String tenantId, required String question});

  Future<List<Map<String, dynamic>>> queryExecutions({
    required String tenantId,
    required String naturalLanguageFilter,
  });
}

class DefaultNaturalLanguageQueryService implements NaturalLanguageQueryService {
  @override
  Future<String> ask({required String tenantId, required String question}) async =>
      'NLQ is not configured for tenant $tenantId. Question: $question';

  @override
  Future<List<Map<String, dynamic>>> queryExecutions({
    required String tenantId,
    required String naturalLanguageFilter,
  }) async =>
      [];
}
