import 'dart:math' as math;

import 'package:azanto/routes/app_routes.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shared `Stack`-positioned back button aligned to the top-left (AppBar leading spot).
class ResponsiveCornerBackButton extends StatelessWidget {
  const ResponsiveCornerBackButton({
    super.key,
    this.onTap,
    this.fallbackRoute,
    this.baseWidth = 390,
    this.baseHeight = 844,
    this.x = 24,
    this.y = 64,
    this.baseSize = 36,
    this.alignToAppBar = true,
  });

  final VoidCallback? onTap;
  final String? fallbackRoute;
  final double baseWidth;
  final double baseHeight;
  final double x;
  final double y;
  final double baseSize;
  final bool alignToAppBar;

  @override
  Widget build(BuildContext context) {
    if (alignToAppBar) {
      final padding = MediaQuery.viewPaddingOf(context);
      return Positioned(
        left: math.max(12.0, padding.left + 8),
        top: padding.top + 8,
        child: CornerBackButton(
          size: baseSize,
          onTap: onTap,
          fallbackRoute: fallbackRoute,
        ),
      );
    }

    final size = MediaQuery.sizeOf(context);
    final scaleX = size.width / baseWidth;
    final scaleY = size.height / baseHeight;
    final scale = math.min(scaleX, scaleY);

    return Positioned(
      left: x * scaleX,
      top: y * scaleY,
      child: CornerBackButton(
        size: baseSize * scale,
        onTap: onTap,
        fallbackRoute: fallbackRoute,
      ),
    );
  }
}

/// Preferred alias for new usage: keeps all back buttons consistent without params.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onTap, this.fallbackRoute});

  final VoidCallback? onTap;
  final String? fallbackRoute;

  @override
  Widget build(BuildContext context) {
    return ResponsiveCornerBackButton(
      onTap: onTap,
      fallbackRoute: fallbackRoute,
    );
  }
}

/// Unified back button used across auth screens.
class CornerBackButton extends StatelessWidget {
  const CornerBackButton({
    super.key,
    required this.size,
    this.onTap,
    this.fallbackRoute,
  });

  final double size;
  final VoidCallback? onTap;
  final String? fallbackRoute;

  void _handleTap() {
    if (onTap != null) {
      onTap!();
      return;
    }
    final canPop = Get.key.currentState?.canPop() ?? false;
    if (canPop) {
      Get.back<void>();
    } else if (fallbackRoute != null) {
      Get.offAllNamed(fallbackRoute!);
    } else {
      Get.offAllNamed(AppRoutes.roleSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.loginBackBorder, width: 1),
        color: AppColors.loginBackFill,
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _handleTap,
          child: SizedBox(
            width: size,
            height: size,
            child: const Icon(Icons.chevron_left, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}
