import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';

class ManufacturingAuditTimeline extends ConsumerWidget {
  const ManufacturingAuditTimeline({super.key, required this.entityType, required this.entityId});

  final String entityType;
  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(auditServiceProvider).getEntityTimeline(entityType: entityType, entityId: entityId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final entries = snapshot.data!;
        if (entries.isEmpty) return const Text('No audit entries');
        return Column(
          children: entries
              .map((e) => ListTile(
                    dense: true,
                    title: Text('${e.action.value} — ${e.entityType}'),
                    subtitle: Text(e.createdAt.toIso8601String()),
                  ))
              .toList(),
        );
      },
    );
  }
}
