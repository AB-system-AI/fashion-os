import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/catalog/product_image_gallery.dart';
import 'package:fashion_pos_enterprise/features/products/domain/models/product_gallery_image.dart';

void main() {
  testWidgets('ProductImageGallery shows sync status and reorder handles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductImageGallery(
            images: const [
              ProductGalleryImage(
                assetId: 'a1',
                syncStatus: MediaSyncStatus.localOnly,
                isPrimary: true,
                thumbnailBytes: [1, 2, 3],
              ),
            ],
            onReorder: (_, __) {},
            onDelete: (_) {},
            onAdd: () {},
          ),
        ),
      ),
    );

    expect(find.text('Primary image'), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
    expect(find.byIcon(Icons.drag_handle), findsOneWidget);
  });
}
