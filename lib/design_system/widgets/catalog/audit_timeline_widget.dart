import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';

/// Chronological audit timeline for product history.
class AuditTimelineWidget extends StatelessWidget {
  const AuditTimelineWidget({required this.entries, super.key});

  final List<AuditEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Text('No activity recorded yet.');
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(_iconFor(entry.action), size: 20, color: Theme.of(context).colorScheme.primary),
                if (index < entries.length - 1)
                  Container(width: 2, height: 32, color: Theme.of(context).colorScheme.outlineVariant),
              ],
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_labelFor(entry), style: Theme.of(context).textTheme.titleSmall),
                  Text(_formatTime(entry.createdAt), style: Theme.of(context).textTheme.bodySmall),
                  if (entry.metadata.isNotEmpty)
                    Text(entry.metadata.toString(), style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _iconFor(AuditAction action) => switch (action) {
        AuditAction.create => Icons.add_circle_outline,
        AuditAction.update => Icons.edit_outlined,
        AuditAction.delete => Icons.delete_outline,
        AuditAction.priceChange => Icons.sell_outlined,
        AuditAction.importData => Icons.upload_file,
        AuditAction.export => Icons.download,
        AuditAction.inventoryChange => Icons.inventory_2_outlined,
        _ => Icons.history,
      };

  String _labelFor(AuditEntry entry) {
    final meta = entry.metadata;
    if (meta['change_type'] == 'variants') return 'Variants updated';
    if (meta['change_type'] == 'media') return 'Image changed';
    if (meta['change_type'] == 'barcode') return 'Barcode changed';
    if (meta['action'] == 'restore') return 'Product restored';
    if (meta['bulk'] != null) return 'Bulk ${meta['bulk']}';
    return entry.action.value.replaceAll('_', ' ');
  }

  String _formatTime(DateTime time) => '${time.toLocal()}';
}
