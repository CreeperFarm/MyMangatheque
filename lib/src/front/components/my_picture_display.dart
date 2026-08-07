import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mymangatheque/src/front/components/safe_network_image.dart';

class MyPictureDisplay extends StatelessWidget {
  final String pictureUrl;
  final bool blurMainPicture;
  final Widget? blurOverlay;

  const MyPictureDisplay({
    required this.pictureUrl,
    this.blurMainPicture = false,
    this.blurOverlay,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final computedHeight = (MediaQuery.of(context).size.width * 16.5) / 24;
    final double height;
    if (computedHeight > 500) {
      height = 500.0;
    } else if (computedHeight < 275) {
      height = 275.0;
    } else {
      height = computedHeight;
    }
    return SizedBox(
      height: height,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          // Image Background with blur effect
          SizedBox(
            height: height,
            width: ((MediaQuery.of(context).size.width * 16.5) / 24 * 10),
            child: ClipRRect(
              child: Wrap(
                children: [
                  Transform.translate(
                    offset: Offset(0, -MediaQuery.of(context).size.width / 2),
                    child: SafeNetworkImage(
                      imageUrl: pictureUrl,
                      scale: 1 / (MediaQuery.of(context).size.width / height),
                      fit: BoxFit.fill,
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.grey.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Image
          SizedBox(
            height: height,
            width: ((height * 16.5) / 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SafeNetworkImage(imageUrl: pictureUrl, fit: BoxFit.fill),
                  if (blurMainPicture)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  if (blurMainPicture && blurOverlay != null)
                    Positioned.fill(child: blurOverlay!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
