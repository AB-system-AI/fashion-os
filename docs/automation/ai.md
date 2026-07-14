# AI Services

## Abstractions

| Service | Purpose |
|---------|---------|
| `AIProvider` | LLM completion, embeddings, structured output |
| `PromptService` | Prompt templates for rules/workflows/insights |
| `RecommendationService` | Suggest rules, workflows, schedules |
| `ForecastService` | Predict load and failure rates |
| `InsightsService` | Summarize execution performance |
| `NaturalLanguageQueryService` | Ask questions about automation data |

## Default implementations

All ship with no-op / empty defaults. Replace `aiProviderProvider` with a real provider when enabling AI.

## Permissions

`AiPermissions.view` required for `SmartSuggestionService` and AI Assistant page.

## Settings

`AutomationSettings.enableAiAssistant` gates AI features per tenant.
