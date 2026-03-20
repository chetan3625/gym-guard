import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AzantoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AzantoAppBar({
    super.key,
    this.showLogout = false,
    this.onLogout,
    this.extraActions,
    this.subscriptionActive,
    this.onStatusTap,
  });

  final bool showLogout;
  final VoidCallback? onLogout;
  final List<Widget>? extraActions;
  final bool? subscriptionActive;
  final VoidCallback? onStatusTap;

  @override
  Size get preferredSize => Size.fromHeight(70.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2F3136), // 0%
              Color(0xFF1E1F23), // 62%
              Color(0xFF0F1014), // 100%
            ],
            stops: [0.0, 0.62, 1.0],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(18.r),
            bottomRight: Radius.circular(18.r),
          ),
        ),
      ),
      title: Text(
        'Azanto',
        style: GoogleFonts.poppins(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.6,
        ),
      ),
      actions: [
        if (subscriptionActive != null)
          Padding(
            padding: EdgeInsets.only(right: 6.w),
            child: _StatusTag(
              isActive: subscriptionActive!,
              onTap: onStatusTap,
            ),
          ),
        ...?extraActions,
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications_none,
            color: Colors.white70,
            size: 22.sp,
          ),
        ),
        if (showLogout)
          IconButton(
            onPressed: onLogout,
            icon: Icon(Icons.logout, color: Colors.white70, size: 22.sp),
            tooltip: 'Logout',
          ),
        SizedBox(width: 8.w),
      ],
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.isActive, this.onTap});

  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent =
        isActive ? AppColors.brandGreen : const Color(0xFFFFC542);
    final String label = isActive ? 'Active' : 'Pending';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.16),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: accent.withOpacity(0.9)),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.22),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive
                  ? Icons.check_circle_rounded
                  : Icons.hourglass_bottom_rounded,
              size: 16.w,
              color: accent,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
