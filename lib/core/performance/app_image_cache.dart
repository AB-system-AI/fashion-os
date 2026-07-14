import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Centralized image cache configuration for product and branding assets.
abstract final class AppImageCache {
  static const Duration stalePeriod = Duration(days: 7);
  static const int maxCacheObjects = 500;

  static void configure() {
    PaintingBinding.instance.imageCache.maximumSize = maxCacheObjects;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20;
  }

  static Widget network({
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: width != null ? (width * 2).toInt() : null,
      memCacheHeight: height != null ? (height * 2).toInt() : null,
      placeholder: placeholder != null ? (_, _) => placeholder : null,
      errorWidget: errorWidget != null ? (_, _, _) => errorWidget : null,
    );
  }

  static Future<void> clearCache() => CachedNetworkImage.evictFromCache('');
}
