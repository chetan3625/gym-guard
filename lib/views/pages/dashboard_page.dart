import 'package:azanto/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:azanto/core/config/api_constant.dart';
import 'package:azanto/core/responsive/responsive.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/views/widgets/azanto_mobile_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Gym owner dashboard — Figma `dashboard demo` (228:89).
class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.greeting,
    required this.userName,
    required this.userRole,
    required this.avatarLetter,
    required this.onProfileTap,
    required this.onAddMemberTap,
    this.onAddGymTap,
    this.onGymTap,
    this.showAddGym = false,
    this.gymSummary,
  });

  final String greeting;
  final String userName;
  final String userRole;
  final String avatarLetter;
  final VoidCallback onProfileTap;
  final VoidCallback onAddMemberTap;
  final VoidCallback? onAddGymTap;
  final VoidCallback? onGymTap;
  final bool showAddGym;
  final GymSummaryData? gymSummary;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final pad = azantoContentPadding(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        pad.left,
        6,
        pad.right,
        20 + bottomPadding,
      ),
      child: MaxWidthContainer(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OwnerGreetingCard(
              greeting: greeting,
              userName: userName,
              userRole: userRole,
              avatarLetter: avatarLetter,
              onTap: onProfileTap,
            ),
            SizedBox(height: 14.h),
            Text(
              'Key Metrics',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                height: 19 / 16,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12.h),
            const _KeyMetricsSection(),
            SizedBox(height: 10.h),
            _AddMemberCard(onTap: onAddMemberTap),
            if (gymSummary != null) ...[
              SizedBox(height: 12.h),
              _GymSummaryCard(data: gymSummary!, onTap: onGymTap),
            ] else if (showAddGym) ...[
              SizedBox(height: 12.h),
              _AddGymCard(onTap: onAddGymTap),
            ],
            SizedBox(height: 22.h),
            Text(
              'Recent Activity',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                height: 19 / 16,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12.h),
            const _ActivityCard(
              height: 60,
              borderColor: Color(0xFF4DB001),
              iconColor: AppColors.brandGreen,
              icon: LucideIcons.indianRupee,
              title: 'Payment Collected',
              subtitle: 'Riya Sharma - ₹3000',
              timeText: '2 Hours ago',
            ),
            SizedBox(height: 10.h),
            const _ActivityCard(
              height: 70,
              borderColor: Color(0xFFFA2323),
              iconColor: AppColors.accentRed,
              icon: LucideIcons.timer,
              title: 'Member Checked In',
              subtitle: 'Amrita Singh',
              timeText: '2 Hours ago',
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma `good morning txt` — 75px avatar, name, role, forward chevron.
class _OwnerGreetingCard extends StatelessWidget {
  const _OwnerGreetingCard({
    required this.greeting,
    required this.userName,
    required this.userRole,
    required this.avatarLetter,
    required this.onTap,
  });

  final String greeting;
  final String userName;
  final String userRole;
  final String avatarLetter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
            children: [
              Container(
                width: 75.w,
                height: 75.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cardSurfaceAlt,
                ),
                alignment: Alignment.center,
                child: Text(
                  avatarLetter,
                  style: GoogleFonts.poppins(
                    fontSize: 27.sp,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: AppColors.brandGreen,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting , $userName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        height: 24 / 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      userRole,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        height: 18 / 15,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyMetricsSection extends StatelessWidget {
  const _KeyMetricsSection();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() => Column(
      children: [
        _OwnerMetricCard(
          title: 'Total Members',
          value: '${controller.totalMembersCount.value}',
          icon: LucideIcons.users,
          valueColor: AppColors.brandGreen,
          showChevron: true,
          fullWidth: true,
        ),
        SizedBox(height: 10.h),
        const _OwnerMetricCard(
          title: 'Active Members',
          value: '154',
          icon: LucideIcons.userCheck,
          valueColor: AppColors.brandGreen,
          fullWidth: true,
        ),
        SizedBox(height: 10.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final gap = 10.w;
            final cardWidth = (constraints.maxWidth - gap) / 2;
            return Row(
              children: [
                SizedBox(
                  width: cardWidth,
                  child: const _OwnerMetricCard(
                    title: 'Today Check-in',
                    value: '45',
                    icon: LucideIcons.circleCheck,
                    valueColor: AppColors.brandGreen,
                    compact: true,
                  ),
                ),
                SizedBox(width: gap),
                SizedBox(
                  width: cardWidth,
                  child: const _OwnerMetricCard(
                    title: 'Expiring Soon',
                    value: '12',
                    icon: LucideIcons.timer,
                    valueColor: AppColors.accentRed,
                    compact: true,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ));
  }
}

/// Figma metric rows — 70px height, gradient fill, bordered.
class _OwnerMetricCard extends StatelessWidget {
  const _OwnerMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.valueColor,
    this.showChevron = false,
    this.compact = false,
    this.fullWidth = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color valueColor;
  final bool showChevron;
  final bool compact;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        compact ? const Color(0xFF333333) : const Color(0xFF999999);

    return Container(
      height: 70.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: azantoMetricCardDecoration(
        borderColor: borderColor,
        highlight: compact,
      ),
      child: Row(
        children: [
          SizedBox(
            width: compact ? 36.w : 40.w,
            height: compact ? 36.w : 40.w,
            child: Icon(
              icon,
              color: AppColors.brandGreen,
              size: compact ? 26.sp : 28.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 17.h,
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        height: 16 / 13,
                        color: compact && valueColor == AppColors.accentRed
                            ? Colors.white.withValues(alpha: 0.64)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    height: 24 / 20,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
          if (showChevron)
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 22.sp,
            ),
        ],
      ),
    );
  }
}

/// Figma `Add Member` — 147px card, plus icon, label.
class _AddMemberCard extends StatelessWidget {
  const _AddMemberCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          height: 120.h,
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.brandGreen.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandGreen.withValues(alpha: 0.15),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.brandGreen,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Text(
                'Add Member',
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma activity `Updates` rows — colored border, icon disc, Inter labels.
class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.height,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.timeText,
  });

  final double height;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceAlt,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 7.r,
            offset: Offset(1.w, 4.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.224,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      timeText,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.07,
                        color: const Color(0xFFB8BAC2),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.56),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddGymCard extends StatelessWidget {
  const _AddGymCard({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 26.h, horizontal: 14.w),
        decoration: _ownerPanelDecoration(
          borderColor: AppColors.brandGreen.withValues(alpha: 0.45),
        ),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandGreen.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.brandGreen.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                color: AppColors.brandGreen,
                size: 30.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add your gym',
                    style: GoogleFonts.montserrat(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Register the gym you manage to start tracking members.',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF9CA0AA),
              size: 30.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _GymSummaryCard extends StatelessWidget {
  const _GymSummaryCard({
    required this.data,
    this.onTap,
  });

  final GymSummaryData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: _ownerPanelDecoration(
          borderColor: AppColors.brandGreen.withValues(alpha: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandGreen.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.brandGreen.withValues(alpha: 0.7),
                ),
              ),
              child: data.logoUrl != null && data.logoUrl!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        data.logoUrl!.startsWith('http://') ||
                                data.logoUrl!.startsWith('https://')
                            ? data.logoUrl!
                            : '${GlobalVariables.apiHost}${data.logoUrl!.startsWith('/') ? '' : '/'}${data.logoUrl!}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.home_work_rounded,
                            color: AppColors.brandGreen,
                            size: 28.sp,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.home_work_rounded,
                      color: AppColors.brandGreen,
                      size: 28.sp,
                    ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.gymName,
                    style: GoogleFonts.montserrat(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    (data.email?.isNotEmpty ?? false)
                        ? data.email!
                        : 'Gym registered',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                  if (data.description?.isNotEmpty ?? false) ...[
                    SizedBox(height: 3.h),
                    Text(
                      data.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.64),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.brandGreen,
                  size: 22.sp,
                ),
                SizedBox(height: 10.h),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white70,
                  size: 24.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _ownerPanelDecoration({required Color borderColor}) {
  return BoxDecoration(
    color: const Color(0xFF2B2D32),
    borderRadius: BorderRadius.circular(14.r),
    border: Border.all(color: borderColor),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 18.r,
        offset: Offset(0, 10.h),
      ),
    ],
  );
}
