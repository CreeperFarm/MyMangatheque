import 'package:flutter/material.dart';

class MyScrollColumn extends StatelessWidget {
  final List<Widget> children;
  final Axis? scrollDirection;
  final EdgeInsetsGeometry? scrollPadding;
  final MainAxisAlignment? columnMainAxisAlignment;
  final MainAxisSize? columnMainAxisSize;
  final CrossAxisAlignment? columnCrossAxisAlignment;

  const MyScrollColumn({
    required this.children,
    this.scrollDirection,
    this.scrollPadding,
    this.columnMainAxisAlignment,
    this.columnMainAxisSize,
    this.columnCrossAxisAlignment,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: scrollDirection != null ? scrollDirection! : Axis.vertical,
        padding: scrollPadding,
        child: Column(
          mainAxisSize: columnMainAxisSize != null ? columnMainAxisSize! : MainAxisSize.max,
          mainAxisAlignment: columnMainAxisAlignment != null ? columnMainAxisAlignment! : MainAxisAlignment.start,
          crossAxisAlignment: columnCrossAxisAlignment != null ? columnCrossAxisAlignment! : CrossAxisAlignment.start,
          children: [
            (constraints.maxWidth > 600 ? const SizedBox(height: 15) : const SizedBox(height: 0)),
            for (var child in children) child,
            (constraints.maxWidth < 600 ? const SizedBox(height: 92) : const SizedBox(height: 15)),
          ],
        ),
      ),
    );
  }
}
