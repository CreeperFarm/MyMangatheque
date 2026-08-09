import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';

void main() {
  Future<void> render(
    WidgetTester tester,
    String? url, {
    bool disableAnimations = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(disableAnimations: disableAnimations),
              child: SafeNetworkImage(
                imageUrl: url,
                width: 120,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('uses the local placeholder for missing and unsafe URLs', (
    tester,
  ) async {
    for (final url in <String?>[
      null,
      '',
      ' null ',
      'http://cdn.example/cover.webp',
      'javascript:alert(1)',
      'https://user:password@cdn.example/cover.webp',
    ]) {
      await render(tester, url);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<ExactAssetImage>(), reason: 'URL: $url');
      expect(image.width, 120);
      expect(image.height, 180);
      expect(image.fit, BoxFit.contain);
    }
  });

  testWidgets('uses a network provider only for a valid HTTPS URL', (
    tester,
  ) async {
    await render(
      tester,
      '  https://cdn.example/cover.webp?size=large  ',
    );
    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.imageUrl, 'https://cdn.example/cover.webp?size=large');
    expect(image.memCacheWidth, (120 * tester.view.devicePixelRatio).ceil());
    expect(image.memCacheHeight, (180 * tester.view.devicePixelRatio).ceil());
    expect(image.maxWidthDiskCache, image.memCacheWidth);
    expect(image.maxHeightDiskCache, image.memCacheHeight);
  });

  testWidgets('removes image fades when reduced motion is enabled', (
    tester,
  ) async {
    await render(
      tester,
      'https://cdn.example/cover.webp',
      disableAnimations: true,
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.fadeInDuration, Duration.zero);
  });
}
