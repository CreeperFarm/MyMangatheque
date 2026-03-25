import 'dart:ui';

import 'package:flutter/material.dart';

class MyPictureDisplay extends StatelessWidget {
  final String pictureUrl;

  const MyPictureDisplay({required this.pictureUrl, super.key});

  @override
  Widget build(BuildContext context) {
    final height = ((MediaQuery.of(context).size.width * 16.5) / 24 > 500)
        ? 500.0
        : ((MediaQuery.of(context).size.width * 16.5) / 24 < 275)
        ? 275.0
        : (MediaQuery.of(context).size.width * 16.5) / 24;
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
                    child: Image.network(
                      scale: 1 / (MediaQuery.of(context).size.width / height),
                      pictureUrl,
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
              child: Image.network(pictureUrl, fit: BoxFit.fill),
            ),
          ),
        ],
      ),
    );
  }
}
