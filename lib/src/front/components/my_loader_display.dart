import 'package:flutter/material.dart';

class MyLoaderDisplay extends StatelessWidget {
  final double percentage;
  final double? height;
  final double? width;
  final double? paddingWidth;

  const MyLoaderDisplay({
    required this.percentage,
    this.height,
    this.width,
    this.paddingWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final barHeight = height ?? 20;
    final containerWidth = width ?? MediaQuery.of(context).size.width;
    final leftPadding = paddingWidth ?? 0.0;
    final filledWidth = (containerWidth - leftPadding) * percentage;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: barHeight,
        width: containerWidth,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: barHeight,
                width: filledWidth,
                color: Theme.of(context).colorScheme.tertiaryFixed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
