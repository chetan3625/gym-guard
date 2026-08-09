import 'dart:math' as math;
import 'dart:ui';

import 'package:azanto/controllers/role_selection_controller.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/views/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class RoleSelectionScreen extends GetView<RoleSelectionController> {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final shortestSide = size.shortestSide;

    final cardWidth = math.min(size.width * 0.92, 420.0);
    final cardRadius = (shortestSide * 0.06).clamp(22.0, 34.0);
    final logoSize = (shortestSide * 0.20).clamp(78.0, 102.0);
    final titleSize = (shortestSide * 0.11).clamp(40.0, 52.0);
    final buttonHeight = (shortestSide * 0.16).clamp(56.0, 64.0);
    final buttonTextSize = (shortestSide * 0.052).clamp(16.0, 22.0);
    final overlayFactor = shortestSide < 370 ? 0.95 : 0.82;
    final topOverlay = AppColors.black.withValues(
      alpha: (140 * overlayFactor) / 255,
    );
    final midOverlay = AppColors.black.withValues(
      alpha: (46 * overlayFactor) / 255,
    );
    final bottomOverlay = AppColors.black.withValues(
      alpha: (168 * overlayFactor) / 255,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: AppColors.transparent,
        systemNavigationBarColor: AppColors.black,
      ),
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/Splash2BG.png',
                fit: BoxFit.cover,
                alignment: size.width < 390
                    ? Alignment.centerLeft
                    : Alignment.center,
                errorBuilder: (_, error, stackTrace) {
                  return const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.roleFallbackTop,
                          AppColors.roleFallbackMid,
                          AppColors.roleFallbackBottom,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [topOverlay, midOverlay, bottomOverlay],
                  stops: const [0.0, 0.44, 1.0],
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.08),
                  radius: 0.95,
                  colors: [
                    AppColors.roleRadialLight,
                    AppColors.transparentWhite,
                  ],
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.0, -0.06),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(cardRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    width: cardWidth,
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                    decoration: BoxDecoration(
                      color: AppColors.roleCardGlass,
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(color: AppColors.roleCardBorder),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: logoSize,
                          height: logoSize,
                          child: AppLogo(size: logoSize),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Azanto',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 26),
                        _RoleButton(
                          label: 'Gym Owner',
                          icon: Icons.person,
                          height: buttonHeight,
                          fontSize: buttonTextSize,
                          onTap: controller.onGymOwnerTap,
                          textColor: AppColors.black,
                          iconColor: AppColors.black,
                          decoration: BoxDecoration(
                            color: AppColors.brandGreen,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brandGreen.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _RoleButton(
                          label: 'Gym Member',
                          icon: Icons.group,
                          height: buttonHeight,
                          fontSize: buttonTextSize,
                          onTap: controller.onGymMemberTap,
                          textColor: AppColors.brandGreen,
                          iconColor: AppColors.brandGreen,
                          decoration: BoxDecoration(
                            color: AppColors.roleMemberFill,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.brandGreen,
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.roleButtonShadowLight,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.label,
    required this.icon,
    required this.height,
    required this.fontSize,
    required this.onTap,
    required this.textColor,
    required this.iconColor,
    required this.decoration,
    this.topHighlight = false,
    this.textShadowColor,
  });

  final String label;
  final IconData icon;
  final double height;
  final double fontSize;
  final VoidCallback onTap;
  final Color textColor;
  final Color iconColor;
  final BoxDecoration decoration;
  final bool topHighlight;
  final Color? textShadowColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: decoration,
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onTap,
              child: SizedBox(
                height: height,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 27, color: iconColor),
                    const SizedBox(width: 14),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        height: 1.0,
                        shadows: textShadowColor == null
                            ? null
                            : [
                                Shadow(
                                  color: textShadowColor!,
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (topHighlight)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [
                        AppColors.roleOwnerTopHighlight,
                        AppColors.transparentWhite,
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
