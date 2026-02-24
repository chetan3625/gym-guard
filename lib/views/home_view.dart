import 'dart:convert';
import 'dart:ui';

import 'package:azanto/controllers/home_controller.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/utils/appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// Utility to keep clamp results as double (clamp returns num).
double _clampDouble(double value, double min, double max) =>
    value.clamp(min, max).toDouble();

class HomeShell extends GetView<HomeController> {
  const HomeShell({super.key});

  static const List<_NavItemData> _navItems = <_NavItemData>[
    _NavItemData(icon: Icons.home_rounded, label: 'Dashboard'),
    _NavItemData(icon: Icons.group_rounded, label: 'Members'),
    _NavItemData(icon: Icons.receipt_long_rounded, label: 'Invoices'),
    _NavItemData(icon: Icons.fitness_center_rounded, label: 'Plans'),
    _NavItemData(icon: Icons.bar_chart_rounded, label: 'Reports'),
  ];

  static final List<_ScreenData> _screens = <_ScreenData>[
    _ScreenData(
      title: 'Add Member',
      subtitle: 'Quick actions to add a new member.',
      accent: AppColors.brandGreen,
      highlights: const [
        'Create a profile with essentials',
        'Assign plan and start date',
        'Send welcome email & app invite',
      ],
    ),
    _ScreenData(
      title: 'Members',
      subtitle: 'Manage the people in your club.',
      accent: const Color(0xFF9FA4B5),
      highlights: const [
        'Search, filter and bulk actions',
        'Attendance snapshots',
        'Upcoming renewals',
      ],
    ),
    _ScreenData(
      title: 'Invoices',
      subtitle: 'Keep billing tidy with drafts & reminders.',
      accent: const Color(0xFFE0E0E6),
      highlights: const [
        'Draft → send → paid pipeline',
        'Auto-reminders every 3 days',
        'Export to CSV/PDF',
      ],
    ),
    _ScreenData(
      title: 'Plans',
      subtitle: 'Curate training & membership products.',
      accent: const Color(0xFFF1B55A),
      highlights: const [
        'Template workouts by level',
        'Bundle PT sessions + classes',
        'Seasonal discounts',
      ],
    ),
    _ScreenData(
      title: 'Reports',
      subtitle: 'Progress and revenue at a glance.',
      accent: const Color(0xFF8BC0FF),
      highlights: const [
        'Month-over-month revenue',
        'Churn & retention curves',
        'Coach performance',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AzantoAppBar(showLogout: true, onLogout: controller.onLogout),
      extendBody: false,
      backgroundColor: AppColors.scaffoldDark,
      body: Obx(() {
        final currentIndex = controller.currentIndex.value;
        final screen = _screens[currentIndex];
        final payload = Map<String, dynamic>.from(controller.tokenPayload);
        final payloadError = controller.tokenPayloadError.value;

        final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

        return Stack(
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
                      Color(0xFF0F1014),
                    ],
                    stops: [0.0, 0.62, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                top: true,
                bottom: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 120 + bottomInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        screen.title,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                          shadows: [
                            Shadow(
                              blurRadius: 16,
                              color: Colors.black45,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        screen.subtitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _TokenPayloadCard(payload: payload, error: payloadError),
                      const SizedBox(height: 22),
                      _HighlightCard(screen: screen),
                      const SizedBox(height: 18),
                      _AddMemberButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth.toDouble();
              final scale = _clampDouble(barWidth / 400, 0.8, 1.05);

              return SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final currentIndex = controller.currentIndex.value;
                  return IntrinsicHeight(
                    child: _GlassBottomBar(
                      items: _navItems,
                      currentIndex: currentIndex,
                      onTap: controller.changeTab,
                      scale: scale,
                    ),
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
      horizontal: _clampDouble(9 * scale, 6, 12),
      vertical: _clampDouble(8 * scale, 6, 11),
    );
    final radius = _clampDouble(26 * scale, 20, 28);
    final shadowOffset = Offset(0, 12 * scale);
    final shadowBlur = 18 * scale;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: barPadding,
          decoration: BoxDecoration(
            color: const Color(0xF01A1C20),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: shadowBlur,
                offset: shadowOffset,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 24 * scale,
                offset: Offset(0, -6 * scale),
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
    final circlePadding = _clampDouble(9 * scale, 5.5, 11);
    final iconSize = _clampDouble(22 * scale, 16, 25);
    final margin = EdgeInsets.symmetric(
      horizontal: _clampDouble(4 * scale, 2, 6),
    );
    final padding = EdgeInsets.symmetric(
      vertical: _clampDouble(8 * scale, 6, 11),
      horizontal: _clampDouble(3.5 * scale, 2, 6),
    );
    final radius = _clampDouble(18 * scale, 15, 22);
    final shadowOffset = Offset(0, 8 * scale);
    final shadowBlur = 12 * scale;
    final gap = _clampDouble(7 * scale, 4, 9);
    final fontSize = _clampDouble(10 * scale, 8.5, 11);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.brandGreen.withOpacity(0.1)
              : const Color(0xFF111216),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: isActive
                ? AppColors.brandGreen.withOpacity(0.6)
                : Colors.white.withOpacity(0.03),
            width: isActive ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: shadowBlur,
              offset: shadowOffset,
            ),
            if (isActive)
              BoxShadow(
                color: AppColors.brandGreen.withOpacity(0.32),
                blurRadius: 20 * scale,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(circlePadding),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? AppColors.brandGreen.withOpacity(0.15)
                    : Colors.white.withOpacity(0.04),
              ),
              child: Icon(
                data.icon,
                color: isActive
                    ? AppColors.brandGreen
                    : const Color(0xFFA8A9AF),
                size: iconSize,
              ),
            ),
            SizedBox(height: gap),
            Text(
              data.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: GoogleFonts.montserrat().fontFamily,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
                color: isActive
                    ? AppColors.brandGreen
                    : const Color(0xFFC4C6CC),
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.screen});

  final _ScreenData screen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0x1A000000),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: screen.accent.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: screen.accent),
          ),
          const SizedBox(height: 12),
          Text(
            '${screen.title} Overview',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          ...screen.highlights.map(
            (item) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(top: 6, right: 10),
                    decoration: BoxDecoration(
                      color: screen.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        height: 1.4,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenPayloadCard extends StatelessWidget {
  const _TokenPayloadCard({required this.payload, required this.error});

  final Map<String, dynamic> payload;
  final String error;

  @override
  Widget build(BuildContext context) {
    final payloadText = payload.isEmpty
        ? ''
        : const JsonEncoder.withIndent('  ').convert(payload);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0x1A000000),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Token Data',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            error.isNotEmpty ? error : payloadText,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMemberButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0x1A000000),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.add, color: AppColors.brandGreen, size: 38),
          SizedBox(height: 10),
          Text(
            'Add Member',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _ScreenData {
  const _ScreenData({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.highlights,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final List<String> highlights;
}
