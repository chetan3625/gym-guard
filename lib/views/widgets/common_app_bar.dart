import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(68.h);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        child: Container(
          height: 54.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B3C41), Color(0xFF24262A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 18.r,
                offset: Offset(0, 10.h),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.09)),
          ),
          child: Row(
            children: [
              SizedBox(width: 18.w),
              Text(
                'Azanto',
                style: GoogleFonts.montserrat(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.15,
                ),
              ),
              const Spacer(),
              _IconButton(icon: Icons.settings_outlined, onTap: () {}),
              SizedBox(width: 8.w),
              _IconButton(icon: Icons.notifications_none_rounded, onTap: () {}),
              SizedBox(width: 14.w),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 20.sp),
      ),
    );
  }
}
