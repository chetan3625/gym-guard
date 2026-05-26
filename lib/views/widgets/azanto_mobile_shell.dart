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
          stops: [0.054, 0.516, 0.927],
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
    final barHeight = width >= ResponsiveBreakpoints.tablet ? 86.0 : 78.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPad, 8, horizontalPad, 10),
      child: Container(
        height: barHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          gradient: const LinearGradient(
            begin: Alignment(-0.9, -0.2),
            end: Alignment(0.95, 0.4),
            colors: [
              AppColors.headerBarStart,
              AppColors.headerBarMid,
              AppColors.headerBarEnd,
            ],
            stops: [0.19, 0.42, 0.96],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.51),
              blurRadius: 38,
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
                fontSize: width >= ResponsiveBreakpoints.tablet ? 26 : 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            const Spacer(),
            ...extraActions,
            if (onSettingsTap != null)
              _HeaderIconButton(
                icon: Icons.settings_outlined,
                onTap: onSettingsTap!,
              ),
            const SizedBox(width: 8),
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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: Colors.white70, size: 22),
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

/// Figma bottom navigation (72px, #303030, green active state).
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
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.navBarSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 33,
              offset: const Offset(10, -3),
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
    final color =
        isActive ? AppColors.brandGreen : AppColors.textMuted;
    final labelSize = isActive ? 10.0 : 12.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: isActive
                ? BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandGreen.withValues(alpha: 0.85),
                        blurRadius: 3,
                      ),
                    ],
                  )
                : const BoxDecoration(),
            child: Icon(item.icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: labelSize,
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
  Color borderColor = const Color(0xFF999999),
  bool highlight = false,
}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(7),
    gradient: const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xC42D2D2D),
        Color(0xFF2F2F2F),
        Color(0xC4252525),
      ],
      stops: [0.0, 0.47, 1.0],
    ),
    border: Border.all(
      color: highlight ? const Color(0xFF333333) : borderColor,
      width: highlight ? 1 : 0.6,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.22),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

BoxDecoration azantoPanelCardDecoration({Color? borderColor}) {
  return BoxDecoration(
    color: AppColors.cardSurface,
    borderRadius: BorderRadius.circular(7),
    border: Border.all(
      color: borderColor ?? Colors.white.withValues(alpha: 0.06),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 12,
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
