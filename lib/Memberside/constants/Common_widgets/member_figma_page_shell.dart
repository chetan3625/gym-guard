import 'package:azanto/Memberside/View/member_notifications_page.dart';
import 'package:azanto/Memberside/View/member_settings_page.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/views/widgets/azanto_mobile_shell.dart';
import 'package:azanto/views/widgets/common_app_bar.dart';
import 'package:azanto/Memberside/constants/member_figma_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Full-screen Figma member layout: gradient + header + optional back + bottom nav.
class MemberFigmaPageShell extends StatelessWidget {
  const MemberFigmaPageShell({
    super.key,
    required this.body,
    required this.bottomNavIndex,
    this.onBack,
    this.onSettingsTap,
    this.onNotificationsTap,
    this.showBack = true,
    this.showSettings = true,
    this.showNotifications = true,
    this.gradientEnd = const Color(0xFF3A3A3A),
  });

  final Widget body;
  final int bottomNavIndex;
  final VoidCallback? onBack;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationsTap;
  final bool showBack;
  final bool showSettings;
  final bool showNotifications;
  final Color gradientEnd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mobileScaffold,
      appBar: AzantoAppBar(
        onSettingsTap: showSettings
            ? (onSettingsTap ??
                () => Get.to<void>(() => const MemberSettingsPage()))
            : null,
        onNotificationsTap: showNotifications
            ? (onNotificationsTap ??
                () => Get.to<void>(() => const MemberNotificationsPage()))
            : null,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.mobileScaffold,
              AppColors.mobileGradientMid,
              gradientEnd,
            ],
            stops: const [0.11257, 0.51648, 0.92691],
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              Expanded(child: body),
              AzantoBottomNavBar(
                items: AzantoBottomNavBar.memberItems,
                currentIndex: bottomNavIndex,
                onTap: (_) => Get.back<void>(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma back control (white stroke box, 36×34, radius 5).
class MemberFigmaBackButton extends StatelessWidget {
  const MemberFigmaBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final layout = MemberFigmaLayout(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => Get.back<void>(),
          borderRadius: BorderRadius.circular(5),
          child: Container(
            width: layout.s(36),
            height: layout.s(34),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.white, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 2,
                  offset: Offset(0, layout.s(1)),
                ),
              ],
            ),
            child: Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: layout.s(20),
            ),
          ),
        ),
      ),
    );
  }
}
