import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/value_objects/automation_value_objects.dart';
import 'package:fashion_pos_enterprise/features/automation/presentation/providers/automation_providers.dart';

class AiAssistantPage extends ConsumerStatefulWidget {
  const AiAssistantPage({super.key});

  @override
  ConsumerState<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends ConsumerState<AiAssistantPage> {
  List<SmartSuggestion> _suggestions = const [];
  List<String> _insights = const [];
  bool _loading = true;
  final _questionController = TextEditingController();
  String? _answer;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    setState(() => _loading = true);
    final suggestions = await ref.read(smartSuggestionServiceProvider).suggest(user: user);
    final insights = await ref.read(smartSuggestionServiceProvider).insights(user: user);
    if (!mounted) return;
    setState(() {
      _suggestions = suggestions.dataOrNull ?? const [];
      _insights = insights.dataOrNull ?? const [];
      _loading = false;
    });
  }

  Future<void> _ask() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || _questionController.text.trim().isEmpty) return;
    final answer = await ref.read(naturalLanguageQueryServiceProvider).ask(
          tenantId: user.tenantId!,
          question: _questionController.text.trim(),
        );
    setState(() => _answer = answer);
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(AiPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: AiPermissions.view));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('AI Assistant')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      labelText: 'Ask about your automations',
                      suffixIcon: IconButton(icon: const Icon(Icons.send), onPressed: _ask),
                    ),
                    onSubmitted: (_) => _ask(),
                  ),
                  if (_answer != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Card(child: Padding(padding: const EdgeInsets.all(AppSpacing.md), child: Text(_answer!))),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Text('Suggestions', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  ..._suggestions.map((s) => Card(
                        child: ListTile(
                          title: Text(s.title),
                          subtitle: Text(s.description),
                          trailing: Text('${(s.confidence * 100).toStringAsFixed(0)}%'),
                        ),
                      )),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Insights', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  ..._insights.map((i) => ListTile(leading: const Icon(Icons.lightbulb_outline), title: Text(i))),
                ],
              ),
            ),
    );
  }
}
