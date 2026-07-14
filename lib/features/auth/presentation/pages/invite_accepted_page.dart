import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/extensions/context_extensions.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:fashion_pos_enterprise/features/auth/routing/auth_route_paths.dart';

class InviteAcceptedPage extends ConsumerStatefulWidget {
  const InviteAcceptedPage({this.token, super.key});

  final String? token;

  @override
  ConsumerState<InviteAcceptedPage> createState() => _InviteAcceptedPageState();
}

class _InviteAcceptedPageState extends ConsumerState<InviteAcceptedPage> {
  @override
  void initState() {
    super.initState();
    if (widget.token != null && widget.token!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _accept());
    }
  }

  Future<void> _accept() async {
    final success = await ref
        .read(authControllerProvider.notifier)
        .acceptInvitation(widget.token!);
    if (success && mounted) context.go(AuthRoutePaths.home);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return AuthScaffold(
      title: context.l10n.inviteAccepted,
      subtitle: context.l10n.inviteAcceptedSubtitle,
      child: Column(
        children: [
          Icon(Icons.group_add, size: 64, color: context.colorScheme.primary),
          const Gap(AppSpacing.xl),
          if (widget.token == null)
            AppButton(
              label: context.l10n.login,
              onPressed: () => context.go(AuthRoutePaths.login),
              isExpanded: true,
            )
          else
            AppButton(
              label: context.l10n.acceptInvitation,
              onPressed: auth.isLoading ? null : _accept,
              isLoading: auth.isLoading,
              isExpanded: true,
            ),
        ],
      ),
    );
  }
}
