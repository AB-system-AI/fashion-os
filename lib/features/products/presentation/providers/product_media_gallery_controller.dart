import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/product_media_gallery_service.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_media_gallery_state.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';

class ProductMediaGalleryController extends FamilyNotifier<ProductMediaGalleryState, String> {
  @override
  ProductMediaGalleryState build(String productId) {
    Future.microtask(() => load(productId));
    return const ProductMediaGalleryState(isLoading: true);
  }

  ProductMediaGalleryService get _gallery => ref.read(productMediaGalleryServiceProvider);

  Future<void> load(String productId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final user = ref.read(authControllerProvider).user;
    final catalog = ref.read(productCatalogServiceProvider);
    final result = await catalog.getById(productId, user: user);
    if (result.isFailure) {
      state = state.copyWith(isLoading: false, error: result.failureOrNull?.message);
      return;
    }
    final product = result.dataOrNull!;
    await _gallery.processOfflineQueue();
    final images = await _gallery.loadGallery(product: product);
    state = state.copyWith(isLoading: false, product: product, images: images);
  }

  Future<void> addImage({required Uint8List bytes, required String filename, bool primary = false}) async {
    final user = ref.read(authControllerProvider).user;
    final product = state.product;
    if (user == null || product == null) return;

    state = state.copyWith(isBusy: true, clearError: true);
    final result = await _gallery.uploadImage(
      user: user,
      product: product,
      bytes: bytes,
      filename: filename,
      primary: primary,
    );
    if (result.isFailure) {
      state = state.copyWith(isBusy: false, error: result.failureOrNull?.message);
      return;
    }
    await _refresh(result.dataOrNull!);
  }

  Future<void> replaceImage({
    required String assetId,
    required Uint8List bytes,
    required String filename,
  }) async {
    final user = ref.read(authControllerProvider).user;
    final product = state.product;
    if (user == null || product == null) return;

    state = state.copyWith(isBusy: true, clearError: true);
    final result = await _gallery.replaceImage(
      user: user,
      product: product,
      oldAssetId: assetId,
      bytes: bytes,
      filename: filename,
    );
    if (result.isFailure) {
      state = state.copyWith(isBusy: false, error: result.failureOrNull?.message);
      return;
    }
    await _refresh(result.dataOrNull!);
  }

  Future<void> deleteImage(String assetId) async {
    final user = ref.read(authControllerProvider).user;
    final product = state.product;
    if (user == null || product == null) return;

    state = state.copyWith(isBusy: true, clearError: true);
    final result = await _gallery.deleteImage(user: user, product: product, assetId: assetId);
    if (result.isFailure) {
      state = state.copyWith(isBusy: false, error: result.failureOrNull?.message);
      return;
    }
    await _refresh(result.dataOrNull!);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final user = ref.read(authControllerProvider).user;
    final product = state.product;
    if (user == null || product == null) return;

    final ids = state.images.map((i) => i.assetId).toList();
    if (newIndex > oldIndex) newIndex -= 1;
    final item = ids.removeAt(oldIndex);
    ids.insert(newIndex, item);

    state = state.copyWith(isBusy: true, clearError: true);
    final result = await _gallery.reorderImages(user: user, product: product, imageAssetIds: ids);
    if (result.isFailure) {
      state = state.copyWith(isBusy: false, error: result.failureOrNull?.message);
      return;
    }
    await _refresh(result.dataOrNull!);
  }

  Future<void> setPrimary(int index) async {
    if (index <= 0) return;
    await reorder(index, 0);
  }

  Future<void> retryUpload(String jobId) async {
    state = state.copyWith(isBusy: true, clearError: true);
    await _gallery.retryFailedUpload(jobId);
    final product = state.product;
    if (product != null) await _refresh(product);
  }

  Future<void> _refresh(Product product) async {
    final images = await _gallery.loadGallery(product: product);
    state = state.copyWith(isBusy: false, product: product, images: images);
  }
}

final productMediaGalleryControllerProvider =
    NotifierProvider.autoDispose.family<ProductMediaGalleryController, ProductMediaGalleryState, String>(
  ProductMediaGalleryController.new,
);
