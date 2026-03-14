import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/core/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

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
              'Reports',
              style: GoogleFonts.poppins(
                fontSize: 34.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Get business insights from attendance and revenue trends.',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Colors.white.withOpacity(0.66),
              ),
            ),
            SizedBox(height: 18.h),
            const _ReportMetric(
              title: 'Monthly Revenue',
              value: '₹2,85,000',
              growth: '+12.5%',
              trendColor: AppColors.brandGreen,
            ),
            SizedBox(height: 10.h),
            const _ReportMetric(
              title: 'Retention Rate',
              value: '89%',
              growth: '+3.0%',
              trendColor: AppColors.brandGreen,
            ),
            SizedBox(height: 10.h),
            const _ReportMetric(
              title: 'Churn Rate',
              value: '11%',
              growth: '-1.2%',
              trendColor: Color(0xFFFF6464),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportMetric extends StatelessWidget {
  const _ReportMetric({
    required this.title,
    required this.value,
    required this.growth,
    required this.trendColor,
  });

  final String title;
  final String value;
  final String growth;
  final Color trendColor;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    color: Colors.white.withOpacity(0.72),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: trendColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              growth,
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                color: trendColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
