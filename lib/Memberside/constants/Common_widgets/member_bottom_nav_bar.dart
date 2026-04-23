import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemberBottomNavBar extends StatelessWidget {
  const MemberBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <_MemberNavItem>[
    _MemberNavItem(icon: Icons.home_rounded, label: 'Dashboard'),
    _MemberNavItem(icon: Icons.fitness_center_rounded, label: 'Workout'),
    _MemberNavItem(icon: Icons.bar_chart_rounded, label: 'Progress'),
    _MemberNavItem(icon: Icons.credit_card_rounded, label: 'Payment'),
    _MemberNavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: List.generate(
            _items.length,
            (index) => Expanded(
              child: _BottomNavItem(
                item: _items[index],
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

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _MemberNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const Color activeColor = AppColors.brandGreen;
    const Color inactiveColor = Color(0xFF8E8E8E);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 180),
              scale: isActive ? 1.04 : 1,
              child: Icon(
                item.icon,
                color: isActive ? activeColor : inactiveColor,
                size: 21,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberNavItem {
  const _MemberNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
