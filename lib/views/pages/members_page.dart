import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/core/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MembersPage extends StatelessWidget {
  const MembersPage({super.key, required this.onAddMemberTap});

  final VoidCallback onAddMemberTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 118.h + bottomPadding),
      child: MaxWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Members',
              style: GoogleFonts.poppins(
                fontSize: 34.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Manage attendance, plans and renewals for your members.',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Colors.white.withOpacity(0.66),
              ),
            ),
            SizedBox(height: 18.h),
            _AddMemberButton(onTap: onAddMemberTap),
            SizedBox(height: 18.h),
            const _MemberSummary(
              icon: Icons.person_add_alt_rounded,
              title: 'New Enquiries',
              value: '24',
            ),
            SizedBox(height: 10.h),
            const _MemberSummary(
              icon: Icons.event_available_rounded,
              title: 'Checked In Today',
              value: '45',
            ),
            SizedBox(height: 10.h),
            const _MemberSummary(
              icon: Icons.schedule_rounded,
              title: 'Renewals This Week',
              value: '18',
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMemberButton extends StatelessWidget {
  const _AddMemberButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7BE625), Color(0xFF26D2F4)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandGreen.withOpacity(0.5),
              blurRadius: 16.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded,
                color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Add Member',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberSummary extends StatelessWidget {
  const _MemberSummary({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2D32),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF3A3C42)),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: AppColors.brandGreen.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.brandGreen, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22.sp,
              color: AppColors.brandGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
