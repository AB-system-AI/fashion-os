import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/catalog/product_image_gallery.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_media_gallery_controller.dart';

/// Product image gallery section — camera/gallery capture via image_picker, storage via MediaEngine.
class ProductImageGallerySection extends ConsumerWidget {
  const ProductImageGallerySection({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productMediaGalleryControllerProvider(productId));
    final controller = ref.read(productMediaGalleryControllerProvider(productId).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.error != null) ...[
          Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const Gap(AppSpacing.sm),
        ],
        ProductImageGallery(
          images: state.images,
          isBusy: state.isBusy || state.isLoading,
          onAdd: () => _pickImage(context, controller),
          onDelete: controller.deleteImage,
          onReorder: controller.reorder,
          onSetPrimary: controller.setPrimary,
          onReplace: (assetId) => _pickImage(context, controller, replaceAssetId: assetId),
          onRetry: (jobId) => controller.retryUpload(jobId),
        ),
      ],
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    ProductMediaGalleryController controller, {
    String? replaceAssetId,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final filename = file.name.isNotEmpty ? file.name : 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';

    if (replaceAssetId != null) {
      await controller.replaceImage(assetId: replaceAssetId, bytes: bytes, filename: filename);
    } else {
      await controller.addImage(bytes: bytes, filename: filename, primary: false);
    }
  }
}
