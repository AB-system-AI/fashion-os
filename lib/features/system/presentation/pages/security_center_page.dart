import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/providers/system_providers.dart';

class SecurityCenterPage extends ConsumerWidget {
  const SecurityCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManage = ref.watch(permissionCheckProvider(SecurityPermissions.manage));
    if (!canManage) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: SecurityPermissions.manage));
    }
    final user = ref.watch(currentUserProvider);
    if (user == null) return const AppScaffold(body: Center(child: Text('Not signed in')));

    final service = ref.read(securityCenterServiceProvider);
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Security Center')),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(tabs: [
              Tab(text: 'Sessions'),
              Tab(text: 'Devices'),
              Tab(text: 'Logins'),
            ]),
            Expanded(
              child: TabBarView(
                children: [
                  _SessionList(future: service.activeSessions(user)),
                  _DeviceList(future: service.trustedDevices(user)),
                  _LoginList(future: service.recentLogins(user)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({required this.future});
  final Future<dynamic> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final sessions = snapshot.data!.dataOrNull as List? ?? [];
        if (sessions.isEmpty) return const Center(child: Text('No active sessions'));
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: sessions.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final s = sessions[i];
            return ListTile(
              title: Text(s.userId),
              subtitle: Text(s.status.value),
              leading: const Icon(Icons.person_outline),
            );
          },
        );
      },
    );
  }
}

class _DeviceList extends StatelessWidget {
  const _DeviceList({required this.future});
  final Future<dynamic> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final devices = snapshot.data!.dataOrNull as List? ?? [];
        if (devices.isEmpty) return const Center(child: Text('No trusted devices'));
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: devices.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final d = devices[i];
            return ListTile(
              title: Text(d.deviceName),
              subtitle: Text('${d.platform ?? 'unknown'} · ${d.trustLevel.value}'),
              leading: const Icon(Icons.devices),
            );
          },
        );
      },
    );
  }
}

class _LoginList extends StatelessWidget {
  const _LoginList({required this.future});
  final Future<dynamic> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final logins = snapshot.data!.dataOrNull as List? ?? [];
        if (logins.isEmpty) return const Center(child: Text('No login history'));
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: logins.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final l = logins[i];
            return ListTile(
              title: Text(l.userId),
              subtitle: Text('${l.success ? 'Success' : 'Failed'} · ${l.occurredAt.toLocal()}'),
              leading: Icon(l.success ? Icons.check_circle_outline : Icons.cancel_outlined),
            );
          },
        );
      },
    );
  }
}
