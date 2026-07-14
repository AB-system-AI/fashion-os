import 'package:fashion_pos_enterprise/features/automation/domain/services/ai/ai_provider.dart';

/// Builds and manages prompts for automation AI features.
abstract class PromptService {
  String buildRuleSuggestionPrompt({required Map<String, dynamic> context});

  String buildWorkflowPrompt({required String workflowName, required List<String> steps});

  String buildInsightPrompt({required Map<String, dynamic> metrics});
}

class DefaultPromptService implements PromptService {
  DefaultPromptService({AIProvider? provider}) : _provider = provider ?? NoOpAIProvider();

  final AIProvider _provider;

  @override
  String buildRuleSuggestionPrompt({required Map<String, dynamic> context}) =>
      'Suggest automation rules for: ${context.entries.map((e) => '${e.key}=${e.value}').join(', ')}';

  @override
  String buildWorkflowPrompt({required String workflowName, required List<String> steps}) =>
      'Design workflow "$workflowName" with steps: ${steps.join(' -> ')}';

  @override
  String buildInsightPrompt({required Map<String, dynamic> metrics}) =>
      'Analyze automation metrics: $metrics';

  Future<String> generate(String prompt) => _provider.complete(prompt: prompt);
}
