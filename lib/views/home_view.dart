import 'dart:ui';

import 'package:azanto/controllers/home_controller.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:azanto/utils/appbar.dart';
import 'package:azanto/views/pages/dashboard_page.dart';
import 'package:azanto/views/pages/invoices_page.dart';
import 'package:azanto/views/pages/members_page.dart';
import 'package:azanto/views/pages/plans_page.dart';
import 'package:azanto/views/pages/profile_page.dart';
import 'package:azanto/views/pages/reports_page.dart';
import 'package:azanto/views/pages/add_member_form_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Keep clamp results as double because clamp returns num.
double _clampDouble(double value, double min, double max) {
  return value.clamp(min, max).toDouble();
}

class HomeShell extends GetView<HomeController> {
  const HomeShell({super.key});

  static const List<_NavItemData> _navItems = <_NavItemData>[
    _NavItemData(icon: Icons.home_rounded, label: 'Dashboard'),
    _NavItemData(icon: Icons.group_rounded, label: 'Members'),
    _NavItemData(icon: Icons.receipt_long_rounded, label: 'Invoices'),
    _NavItemData(icon: Icons.fitness_center_rounded, label: 'Plans'),
    _NavItemData(icon: Icons.bar_chart_rounded, label: 'Reports'),
  ];

  @override
  Widget build(BuildContext context) {
    final subscriptionActive =
        (controller.session.gymId?.isNotEmpty ?? false) ? true : false;

    return Scaffold(
      appBar: AzantoAppBar(
        showLogout: true,
        onLogout: () => controller.onLogout(),
        extraActions: [
          IconButton(
            tooltip: 'Scan QR',
            onPressed: () => Get.toNamed(AppRoutes.qrScanner),
            icon: const Icon(Icons.qr_code_scanner_rounded),
            color: Colors.white70,
          ),
        ],
      ),
      backgroundColor: AppColors.scaffoldDark,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2F3136),
                    Color(0xFF1E1F23),
                    Color(0xFF101116),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Obx(() {
              final currentIndex = controller.currentIndex.value;

              if (controller.shouldLaunchGymPrompt) {
                controller.markGymPromptLaunched();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Get.offAllNamed(AppRoutes.gymOnboarding);
                });
              }

              void openAddMemberScreen() {
                Get.to(
                  () => AddMemberFormPage(onBack: () => Get.back()),
                  transition: Transition.downToUp,
                );
              }

              return IndexedStack(
                index: currentIndex,
                children: [
                  controller.isProfileOpen.value
                      ? ProfilePage(onBack: controller.closeProfile)
                      : DashboardPage(
                          greeting: controller.greetingMessage,
                          userName: controller.displayName.value,
                          userRole: controller.roleTitle.value,
                          avatarLetter: controller.avatarLetter,
                          onProfileTap: controller.openProfile,
                          onAddMemberTap: openAddMemberScreen,
                          onAddGymTap: controller.isOwner
                              ? () => Get.toNamed(AppRoutes.gymOnboarding)
                              : null,
                          showAddGym: controller.shouldShowAddGymCard,
                          gymSummary: controller.gymSummary.value,
                          statusBanner: _StatusIsland(
                            isActive: subscriptionActive,
                            onTap: () => Get.toNamed(
                              AppRoutes.gymPayment,
                              arguments: {'isActive': subscriptionActive},
                            ),
                          ),
                        ),
                  MembersPage(onAddMemberTap: openAddMemberScreen),
                  const InvoicesPage(),
                  const PlansPage(),
                  const ReportsPage(),
                ],
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth.toDouble();
              final scale = _clampDouble(barWidth / 400, 0.82, 1.04);

              return SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final currentIndex = controller.currentIndex.value;
                  return _GlassBottomBar(
                    items: _navItems,
                    currentIndex: currentIndex,
                    onTap: controller.changeTab,
                    scale: scale,
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GlassBottomBar extends StatelessWidget {
  const _GlassBottomBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.scale,
  });

  final List<_NavItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final barPadding = EdgeInsets.symmetric(
      horizontal: _clampDouble(8 * scale, 6, 12),
      vertical: _clampDouble(8 * scale, 6, 11),
    );
    final radius = _clampDouble(22 * scale, 18, 26);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: barPadding,
          decoration: BoxDecoration(
            color: const Color(0xEF17191F),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _BottomItem(
                    data: items[i],
                    isActive: i == currentIndex,
                    scale: scale,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.data,
    required this.isActive,
    required this.onTap,
    required this.scale,
  });

  final _NavItemData data;
  final bool isActive;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final radius = _clampDouble(16 * scale, 14, 18);
    final padding = EdgeInsets.symmetric(
      horizontal: _clampDouble(4 * scale, 2, 6),
      vertical: _clampDouble(10 * scale, 8, 11),
    );
    final iconSize = _clampDouble(22 * scale, 17, 24);
    final fontSize = _clampDouble(12 * scale, 9, 12);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: padding,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.brandGreen.withOpacity(0.12)
              : const Color(0xFF191B22),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: isActive
                ? AppColors.brandGreen.withOpacity(0.75)
                : Colors.white.withOpacity(0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
            if (isActive)
              BoxShadow(
                color: AppColors.brandGreen.withOpacity(0.28),
                blurRadius: 18,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              data.icon,
              color: isActive ? AppColors.brandGreen : const Color(0xFFA8ABB4),
              size: iconSize,
            ),
            const SizedBox(height: 4),
            Text(
              data.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? AppColors.brandGreen
                    : const Color(0xFFC3C5CC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _StatusIsland extends StatelessWidget {
  const _StatusIsland({required this.isActive, required this.onTap});

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = isActive ? AppColors.brandGreen : const Color(0xFFFFC542);
    final label = isActive ? 'Active' : 'Pending';

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: accent.withOpacity(0.55)),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.7),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Status • $label',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.25,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accent.withOpacity(0.7)),
                    ),
                    child: Text(
                      'Manage',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
