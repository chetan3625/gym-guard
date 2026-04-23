import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/controllers/home_controller.dart' show GymSummaryData;
import 'package:azanto/core/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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
    this.statusBanner,
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
  final Widget? statusBanner;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 118.h + bottomPadding),
      child: MaxWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (statusBanner != null) ...[
              statusBanner!,
              SizedBox(height: 12.h),
            ],
            _GreetingCard(
              greeting: greeting,
              userName: userName,
              userRole: userRole,
              avatarLetter: avatarLetter,
              onTap: onProfileTap,
            ),
            SizedBox(height: 18.h),
            Text(
              'Recent Activity',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10.h),
            const _ActivityCard(
              borderColor: AppColors.brandGreen,
              iconColor: AppColors.brandGreen,
              icon: Icons.currency_rupee_rounded,
              title: 'Payment Collected',
              subtitle: 'Riya Sharma - ₹3000',
              timeText: '2 Hours ago',
            ),
            SizedBox(height: 10.h),
            const _ActivityCard(
              borderColor: Color(0xFFFF3434),
              iconColor: Color(0xFFFF3434),
              icon: Icons.timer_outlined,
              title: 'Member Checked In',
              subtitle: 'Amrita Singh',
              timeText: '2 Hours ago',
            ),
            SizedBox(height: 18.h),
            const _KeyMetricsCard(),
            SizedBox(height: 16.h),
            if (gymSummary != null) ...[
              _GymSummaryCard(data: gymSummary!, onTap: onGymTap),
              SizedBox(height: 12.h),
            ] else if (showAddGym) ...[
              _AddGymCard(onTap: onAddGymTap),
              SizedBox(height: 12.h),
            ],
            _AddMemberCard(onTap: onAddMemberTap),
          ],
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1C1E23),
                border: Border.all(
                  color: AppColors.brandGreen.withOpacity(0.35),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                avatarLetter,
                style: GoogleFonts.montserrat(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
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
                    '$greeting, $userName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    userRole,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.62),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF8E9097),
              size: 32.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.borderColor,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.timeText,
  });

  final Color borderColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: _cardDecoration(borderColor: borderColor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.12),
            ),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    color: Colors.white.withOpacity(0.56),
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

class _KeyMetricsCard extends StatelessWidget {
  const _KeyMetricsCard();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900
        ? 3
        : width >= 520
            ? 2
            : 1;
    final childAspectRatio = crossAxisCount == 3
        ? 2.2
        : crossAxisCount == 2
            ? 1.8
            : 3.0;

    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
      decoration: _cardDecoration(borderColor: Colors.white.withOpacity(0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Metrics',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: childAspectRatio,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              _MetricTile(
                title: 'Active Members',
                value: '154',
                icon: Icons.groups_2_rounded,
                valueColor: AppColors.brandGreen,
              ),
              _MetricTile(
                title: 'Total Members',
                value: '200',
                icon: Icons.group_rounded,
                valueColor: AppColors.brandGreen,
              ),
              _MetricTile(
                title: 'Expiring Soon',
                value: '12',
                icon: Icons.timer_outlined,
                valueColor: Color(0xFFFF3434),
              ),
              _MetricTile(
                title: 'Today Check-in',
                value: '45',
                icon: Icons.check_circle_rounded,
                valueColor: AppColors.brandGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.valueColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3035),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.brandGreen, size: 20.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFD0D2D7),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMemberCard extends StatelessWidget {
  const _AddMemberCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 30.h),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_rounded,
              color: AppColors.brandGreen,
              size: 52.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              'Add Member',
              style: GoogleFonts.montserrat(
                fontSize: 30.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
        decoration: _cardDecoration(
          borderColor: AppColors.brandGreen.withOpacity(0.45),
        ),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandGreen.withOpacity(0.15),
                border: Border.all(
                  color: AppColors.brandGreen.withOpacity(0.6),
                ),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.brandGreen,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
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
                      color: Colors.white.withOpacity(0.72),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA0AA),
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
        decoration: _cardDecoration(
          borderColor: AppColors.brandGreen.withOpacity(0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandGreen.withOpacity(0.15),
                border:
                    Border.all(color: AppColors.brandGreen.withOpacity(0.7)),
              ),
              child: Icon(
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
                      color: Colors.white.withOpacity(0.82),
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
                        color: Colors.white.withOpacity(0.64),
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

BoxDecoration _cardDecoration({Color borderColor = const Color(0xFF3A3C42)}) {
  return BoxDecoration(
    color: const Color(0xFF2B2D32),
    borderRadius: BorderRadius.circular(14.r),
    border: Border.all(color: borderColor),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.35),
        blurRadius: 18.r,
        offset: Offset(0, 10.h),
      ),
    ],
  );
}
