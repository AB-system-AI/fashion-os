import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/features/products/domain/models/product_gallery_image.dart';

/// Reorderable product image gallery integrated with MediaEngine view models.
class ProductImageGallery extends StatelessWidget {
  const ProductImageGallery({
    required this.images,
    required this.onReorder,
    required this.onDelete,
    required this.onAdd,
    this.onReplace,
    this.onSetPrimary,
    this.onRetry,
    this.isBusy = false,
    super.key,
  });

  final List<ProductGalleryImage> images;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<String> onDelete;
  final VoidCallback onAdd;
  final void Function(String assetId)? onReplace;
  final ValueChanged<int>? onSetPrimary;
  final ValueChanged<String>? onRetry;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Images', style: Theme.of(context).textTheme.titleMedium),
            if (isBusy) ...[
              const Gap(AppSpacing.sm),
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
            const Spacer(),
            TextButton.icon(
              onPressed: isBusy ? null : onAdd,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Add'),
            ),
          ],
        ),
        const Gap(AppSpacing.md),
        if (images.isEmpty)
          const _ImagePlaceholder()
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: images.length,
            onReorder: isBusy ? (_, __) {} : onReorder,
            itemBuilder: (context, index) {
              final image = images[index];
              return Card(
                key: ValueKey(image.assetId),
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: _Thumbnail(image: image),
                  title: Text(image.isPrimary ? 'Primary image' : 'Image ${index + 1}'),
                  subtitle: _SyncStatusChip(status: image.syncStatus, needsRetry: image.needsRetry),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (image.needsRetry && onRetry != null)
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Retry upload',
                          onPressed: isBusy ? null : () => onRetry!(image.uploadJobId ?? image.assetId),
                        ),
                      if (onSetPrimary != null && !image.isPrimary)
                        IconButton(
                          icon: const Icon(Icons.star_outline),
                          tooltip: 'Set as primary',
                          onPressed: isBusy ? null : () => onSetPrimary!(index),
                        ),
                      if (onReplace != null)
                        IconButton(
                          icon: const Icon(Icons.swap_horiz),
                          tooltip: 'Replace',
                          onPressed: isBusy ? null : () => onReplace!(image.assetId),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                        onPressed: isBusy ? null : () => onDelete(image.assetId),
                      ),
                      const Icon(Icons.drag_handle),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.image});

  final ProductGalleryImage image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 56,
        height: 56,
        child: _buildImage(context),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final bytes = image.thumbnailBytes;
    if (bytes != null) {
      return Image.memory(Uint8List.fromList(bytes), fit: BoxFit.cover);
    }
    if (image.displayUrl != null) {
      return Image.network(
        image.displayUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.image_outlined),
    );
  }
}

class _SyncStatusChip extends StatelessWidget {
  const _SyncStatusChip({required this.status, required this.needsRetry});

  final MediaSyncStatus status;
  final bool needsRetry;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      MediaSyncStatus.synced => ('Synced', Colors.green),
      MediaSyncStatus.uploading || MediaSyncStatus.pendingUpload => ('Uploading', Colors.orange),
      MediaSyncStatus.failed => ('Failed', Colors.red),
      MediaSyncStatus.localOnly => ('Offline', Colors.blueGrey),
      MediaSyncStatus.conflict => ('Conflict', Colors.deepOrange),
    };
    return Chip(
      label: Text(needsRetry ? 'Retry needed' : label, style: const TextStyle(fontSize: 11)),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('No images — add from camera or gallery'),
    );
  }
}
