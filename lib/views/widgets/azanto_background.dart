import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AzantoBackground extends StatelessWidget {
  const AzantoBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.splashGradientTop,
                AppColors.splashGradientMid,
                AppColors.splashGradientBottom,
              ],
              stops: [0.0, 0.52, 1.0],
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.splashSideOverlayDark,
                AppColors.splashSideOverlayLight,
                AppColors.splashSideOverlayDark,
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
