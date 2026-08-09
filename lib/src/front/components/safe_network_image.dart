import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';
import 'package:mymangatheque/src/const/assets.dart';

class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final double scale;
  final BoxFit fit;

  const SafeNetworkImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.scale = 1.0,
    this.fit = BoxFit.cover,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = imageUrl?.trim() ?? '';
    final networkUrl = parseSafeHttpsUri(normalized)?.toString();

    Widget placeholder() => Image.asset(
      Assets.images.unknown,
      width: width,
      height: height,
      scale: scale,
      fit: fit,
    );

    if (normalized.isEmpty || normalized.toLowerCase() == 'null') {
      return placeholder();
    }

    if (networkUrl == null) {
      return placeholder();
    }

    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    int? decodeSize(double? logicalSize) {
      if (logicalSize == null || !logicalSize.isFinite || logicalSize <= 0) {
        return null;
      }
      return (logicalSize * devicePixelRatio).ceil().clamp(1, 4096);
    }

    final cacheWidth = decodeSize(width);
    final cacheHeight = decodeSize(height);
    final animationsDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return CachedNetworkImage(
      imageUrl: networkUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      maxWidthDiskCache: cacheWidth,
      maxHeightDiskCache: cacheHeight,
      fadeInDuration: animationsDisabled
          ? Duration.zero
          : const Duration(milliseconds: 120),
      placeholder: (context, url) => placeholder(),
      errorWidget: (context, url, error) => placeholder(),
    );
  }
}
