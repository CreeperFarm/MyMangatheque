import 'package:flutter/material.dart';
import 'package:mymangatheque/src/const/assets.dart';

class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final double scale;
  final BoxFit fit;

  const SafeNetworkImage({required this.imageUrl, this.width, this.height, this.scale = 1.0, this.fit = BoxFit.cover, super.key});

  @override
  Widget build(BuildContext context) {
    final normalized = imageUrl?.trim() ?? '';
    final networkUrl = normalized.startsWith('https://') || normalized.startsWith('http://') ? normalized : null;

    Widget placeholder() => Image.asset(Assets.images.unknown, width: width, height: height, scale: scale, fit: fit);

    if (normalized.isEmpty || normalized.toLowerCase() == 'null') {
      return placeholder();
    }

    if (networkUrl == null) {
      return const SizedBox.shrink();
    }

    return Image.network(
      networkUrl,
      width: width,
      height: height,
      scale: scale,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
