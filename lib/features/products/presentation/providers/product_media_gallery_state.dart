import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/models/product_gallery_image.dart';

class ProductMediaGalleryState extends Equatable {
  const ProductMediaGalleryState({
    this.product,
    this.images = const [],
    this.isLoading = false,
    this.isBusy = false,
    this.error,
  });

  final Product? product;
  final List<ProductGalleryImage> images;
  final bool isLoading;
  final bool isBusy;
  final String? error;

  ProductMediaGalleryState copyWith({
    Product? product,
    List<ProductGalleryImage>? images,
    bool? isLoading,
    bool? isBusy,
    String? error,
    bool clearError = false,
  }) {
    return ProductMediaGalleryState(
      product: product ?? this.product,
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [product?.id, images, isLoading, isBusy, error];
}
