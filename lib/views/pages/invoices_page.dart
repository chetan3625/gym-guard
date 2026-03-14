import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/core/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});

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
              'Invoices',
              style: GoogleFonts.poppins(
                fontSize: 34.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Track collections, pending dues, and recent bill activity.',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Colors.white.withOpacity(0.66),
              ),
            ),
            SizedBox(height: 18.h),
            const _InvoiceTile(
              title: 'Pending Invoices',
              amount: '₹45,000',
              icon: Icons.pending_actions_rounded,
              amountColor: Color(0xFFFFB347),
            ),
            SizedBox(height: 10.h),
            const _InvoiceTile(
              title: 'Collected Today',
              amount: '₹12,500',
              icon: Icons.check_circle_rounded,
              amountColor: AppColors.brandGreen,
            ),
            SizedBox(height: 10.h),
            const _InvoiceTile(
              title: 'Overdue',
              amount: '₹8,000',
              icon: Icons.error_outline_rounded,
              amountColor: Color(0xFFFF5A5A),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({
    required this.title,
    required this.amount,
    required this.icon,
    required this.amountColor,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color amountColor;

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
              color: amountColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: amountColor, size: 22.sp),
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
            amount,
            style: GoogleFonts.poppins(
              fontSize: 22.sp,
              color: amountColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
