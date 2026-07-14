/// Abstraction for AI provider integrations (OpenAI, local models, etc.).
abstract class AIProvider {
  Future<String> complete({required String prompt, Map<String, dynamic>? options});

  Future<List<double>> embed({required String text});

  Future<Map<String, dynamic>> structuredOutput({
    required String prompt,
    required Map<String, dynamic> schema,
  });
}

/// No-op AI provider for offline / disabled AI mode.
class NoOpAIProvider implements AIProvider {
  @override
  Future<String> complete({required String prompt, Map<String, dynamic>? options}) async =>
      'AI assistant is disabled. Enable AI in automation settings.';

  @override
  Future<List<double>> embed({required String text}) async => List.filled(8, 0);

  @override
  Future<Map<String, dynamic>> structuredOutput({
    required String prompt,
    required Map<String, dynamic> schema,
  }) async =>
      {'message': 'AI disabled', 'schema': schema.keys.toList()};
}
