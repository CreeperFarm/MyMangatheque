import 'package:flutter/material.dart';

class MyLoaderDisplay extends StatelessWidget {
  final double percentage;
  final double? height;
  final double? width;
  final double? paddingWidth;

  const MyLoaderDisplay({required this.percentage, this.height, this.width, this.paddingWidth, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: (height == null) ? 20 : height,
        width: (width == null) ? MediaQuery.of(context).size.width : width,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: (height == null) ? 20 : height,
                width: (width == null)
                    ? ((MediaQuery.of(context).size.width - ((paddingWidth == null) ? 0.0 : paddingWidth!)) * percentage)
                    : ((width! - ((paddingWidth == null) ? 0.0 : paddingWidth!)) * percentage),
                color: Theme.of(context).colorScheme.tertiaryFixed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
