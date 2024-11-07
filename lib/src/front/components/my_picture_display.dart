import 'dart:ui';

import 'package:flutter/material.dart';

class MyPictureDisplay extends StatelessWidget {
  final String pictureUrl;

  const MyPictureDisplay({required this.pictureUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 275,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          // Image Background with blur effect
          SizedBox(
            height: 275,
            width: ((275 * 16.5) / 24 * 10),
            child: ClipRRect(
              child: Wrap(
                children: [
                  Transform.translate(
                    offset: const Offset(0, (-275 / 2)),
                    child: Image.network(
                      pictureUrl,
                      fit: BoxFit.fill,
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.grey.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Image
          SizedBox(
            height: 275,
            width: ((275 * 16.5) / 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                pictureUrl,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
