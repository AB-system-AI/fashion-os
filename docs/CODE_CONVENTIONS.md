# Code Conventions

## Dart Style
- Follow effective_dart and analysis_options.yaml
- Use trailing commas on multi-line constructs
- Prefer const constructors where possible
- Use sealed classes for exhaustive pattern matching
- Use final for all local variables unless mutation required

## Architecture Rules
1. Domain layer has zero Flutter imports
2. Repository interfaces live in domain, implementations in data
3. Use Result<T> for repository return types
4. Map exceptions to failures at repository boundary
5. One public class per file (exceptions: related sealed classes)

## Riverpod
- Providers in presentation/providers/ for features
- Core providers in core/di/ or core/services/
- Use Notifier for mutable state, Provider for dependencies
- Override providers in bootstrap for config and prefs

## Widgets
- StatelessWidget by default; ConsumerWidget when reading providers
- Extract widgets when build method exceeds 80 lines
- Use design system components, never raw Material widgets in features

## Imports
Order: dart, flutter, packages, project (alphabetical within groups)
Use package imports only: package:fashion_pos_enterprise/...
