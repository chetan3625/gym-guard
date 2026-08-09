import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:azanto/Memberside/View/member_notifications_page.dart';

class AzantoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AzantoAppBar({
    super.key,
    this.showLogout = false,
    this.onLogout,
    this.onSettingsTap,
    this.onNotificationsTap,
    this.extraActions,
    this.subscriptionActive,
    this.onStatusTap,
  });

  final bool showLogout;
  final VoidCallback? onLogout;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationsTap;
  final List<Widget>? extraActions;
  final bool? subscriptionActive;
  final VoidCallback? onStatusTap;

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: AppColors.headerBarStart,
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          ),
        ),
      ),
      title: Text(
        'Azanto',
        style: GoogleFonts.poppins(
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
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
        if (onSettingsTap != null)
          IconButton(
            onPressed: onSettingsTap,
            icon: Icon(
              Icons.settings_outlined,
              color: Colors.white70,
              size: 20.sp,
            ),
            tooltip: 'Settings',
          ),
        IconButton(
          onPressed: () {
            if (onNotificationsTap != null) {
              onNotificationsTap!();
            } else {
              try {
                Get.to<void>(() => const MemberNotificationsPage());
              } catch (_) {}
            }
          },
          icon: Icon(
            Icons.notifications_none_rounded,
            color: Colors.white70,
            size: 20.sp,
          ),
          tooltip: 'Notifications',
        ),
        if (showLogout)
          IconButton(
            onPressed: onLogout,
            icon: Icon(Icons.logout_rounded, color: Colors.white70, size: 20.sp),
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
          color: accent.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: accent.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.2),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
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
              size: 14.w,
              color: accent,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 11.sp,
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

