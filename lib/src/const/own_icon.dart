import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OwnIcon extends StatelessWidget {
  Color iconColor;
  final String iconSrc;
  final double? height;

  OwnIcon({required this.iconColor, required this.iconSrc, this.height, super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      iconSrc,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      height: height?.toDouble(),
    );
  }
}
