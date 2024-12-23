import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OwnIcon extends StatelessWidget {
  Color iconColor;
  final String iconName;
  final double? height;

  OwnIcon({required this.iconColor, required this.iconName, this.height, super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$iconName.svg',
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      height: height?.toDouble(),
    );
  }
}
