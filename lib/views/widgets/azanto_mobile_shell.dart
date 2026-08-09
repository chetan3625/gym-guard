import 'package:azanto/core/responsive/responsive.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Figma mobile page background gradient (member + owner dashboards).
class AzantoPageBackground extends StatelessWidget {
  const AzantoPageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.mobileScaffold,
            AppColors.mobileGradientMid,
            AppColors.mobileGradientEnd,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// Top bar from Figma: wordmark + optional actions (settings, notifications, etc.).
class AzantoMobileHeader extends StatelessWidget {
  const AzantoMobileHeader({
    super.key,
    this.extraActions = const [],
    this.onSettingsTap,
    this.onNotificationsTap,
  });

  final List<Widget> extraActions;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPad = width >= ResponsiveBreakpoints.tablet ? 20.0 : 16.0;
    final barHeight = width >= ResponsiveBreakpoints.tablet ? 76.0 : 68.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPad, 6, horizontalPad, 8),
      child: Container(
        height: barHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.headerBarStart,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              'Azanto',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: width >= ResponsiveBreakpoints.tablet ? 24 : 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            ...extraActions,
            if (onSettingsTap != null)
              _HeaderIconButton(
                icon: Icons.settings_outlined,
                onTap: onSettingsTap!,
              ),
            const SizedBox(width: 6),
            _HeaderIconButton(
              icon: Icons.notifications_none_rounded,
              onTap: onNotificationsTap ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardIconCircle,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
      ),
    );
  }
}

class AzantoNavItem {
  const AzantoNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Figma bottom navigation (72px, #1C1D22, green active state).
class AzantoBottomNavBar extends StatelessWidget {
  const AzantoBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AzantoNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  static List<AzantoNavItem> get memberItems => const [
        AzantoNavItem(icon: Icons.home_rounded, label: 'Dashboard'),
        AzantoNavItem(icon: Icons.fitness_center_rounded, label: 'Workout'),
        AzantoNavItem(icon: Icons.show_chart_rounded, label: 'Progress'),
        AzantoNavItem(icon: Icons.credit_card_rounded, label: 'Payment'),
        AzantoNavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
      ];

  static List<AzantoNavItem> get ownerItems => const [
        AzantoNavItem(icon: Icons.home_rounded, label: 'Dashboard'),
        AzantoNavItem(icon: Icons.group_rounded, label: 'Members'),
        AzantoNavItem(icon: Icons.receipt_long_rounded, label: 'Invoices'),
        AzantoNavItem(icon: Icons.fitness_center_rounded, label: 'Plans'),
        AzantoNavItem(icon: Icons.bar_chart_rounded, label: 'Reports'),
      ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        decoration: BoxDecoration(
          color: AppColors.navBarSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: List.generate(
            items.length,
            (index) => Expanded(
              child: _NavTile(
                item: items[index],
                isActive: index == currentIndex,
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final AzantoNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.brandGreen : AppColors.textMuted;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: isActive
                ? BoxDecoration(
                    color: AppColors.brandGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  )
                : const BoxDecoration(),
            child: Icon(item.icon, color: color, size: 22),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Figma card gradient used across member/owner dashboards.
BoxDecoration azantoMetricCardDecoration({
  Color borderColor = const Color(0xFF2A2B30),
  bool highlight = false,
}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    color: AppColors.cardSurface,
    border: Border.all(
      color: highlight ? AppColors.brandGreen : borderColor,
      width: highlight ? 1.2 : 0.8,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.28),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

BoxDecoration azantoPanelCardDecoration({Color? borderColor}) {
  return BoxDecoration(
    color: AppColors.cardSurface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: borderColor ?? Colors.white.withValues(alpha: 0.06),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

/// Responsive horizontal padding for tab content (phone / tablet).
EdgeInsets azantoContentPadding(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= ResponsiveBreakpoints.tablet) {
    return const EdgeInsets.fromLTRB(24, 12, 24, 20);
  }
  if (width >= ResponsiveBreakpoints.phone) {
    return const EdgeInsets.fromLTRB(18, 12, 18, 18);
  }
  return const EdgeInsets.fromLTRB(14, 12, 14, 18);
}

