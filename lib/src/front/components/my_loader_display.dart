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
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final requestedWidth = width ?? availableWidth;
        final containerWidth = requestedWidth < availableWidth
            ? requestedWidth
            : availableWidth;
        final leftPadding = (paddingWidth ?? 0.0).clamp(0.0, containerWidth);
        final normalizedPercentage = percentage.clamp(0.0, 1.0);
        final filledWidth =
            (containerWidth - leftPadding) * normalizedPercentage;

        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: barHeight,
            width: containerWidth,
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.7),
            alignment: Alignment.centerLeft,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: barHeight,
                width: filledWidth,
                color: Theme.of(context).colorScheme.tertiaryFixed,
              ),
            ),
          ),
        );
      },
    );
  }
}
