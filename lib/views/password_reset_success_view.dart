import 'dart:math' as math;

import 'package:azanto/controllers/login_view_controller.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:azanto/views/widgets/corner_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    const baseWidth = 390.0;
    const baseHeight = 844.0;
    final scaleX = size.width / baseWidth;
    final scaleY = size.height / baseHeight;
    final scale = math.min(scaleX, scaleY);

    final double glassLeft = 15 * scaleX;
    final double glassTop = 220 * scaleY;
    final double desiredGlassWidth = 364 * scaleX;
    final double desiredGlassHeight = 520 * scaleY;
    final double availableWidth = size.width - glassLeft;
    final double glassWidth = math.min(desiredGlassWidth, availableWidth - 8);
    final double glassHeight = math.min(
      desiredGlassHeight,
      size.height - glassTop - 64 * scaleY,
    );
    final double glassRadius = 32 * scale;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: AppColors.transparent,
        systemNavigationBarColor: AppColors.black,
      ),
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF16241A),
                      Color(0xFF0F1316),
                      Color(0xFF090B0E),
                    ],
                    stops: [0.0, 0.48, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 86 * scaleY,
              left: -36 * scaleX,
              child: Container(
                width: 170 * scale,
                height: 170 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF79DF67).withValues(alpha: 0.16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF79DF67).withValues(alpha: 0.16),
                      blurRadius: 100,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -40 * scaleX,
              bottom: 160 * scaleY,
              child: Container(
                width: 210 * scale,
                height: 210 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFBFF56D).withValues(alpha: 0.08),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFBFF56D).withValues(alpha: 0.12),
                      blurRadius: 120,
                      spreadRadius: 36,
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: glassLeft,
                  right: math.max(0, size.width - glassLeft - glassWidth),
                  top: glassTop,
                  bottom: 64 * scaleY,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(glassRadius),
                  child: Container(
                    width: glassWidth,
                    constraints: BoxConstraints(minHeight: glassHeight),
                    padding: EdgeInsets.symmetric(
                      horizontal: 18 * scaleX,
                      vertical: 28 * scaleY,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xC6131A18),
                      borderRadius: BorderRadius.circular(glassRadius),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.28),
                          blurRadius: 28,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 180 * scale,
                          child: Lottie.asset(
                            'assets/animations/password_reset_success.json',
                            repeat: true,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 18 * scaleY),
                        Text(
                          'Password\nChanged!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: AppColors.white,
                            fontSize: 28 * scale,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 12 * scaleY),
                        Text(
                          'Your password has been reset successfully. You can now sign in with your new password.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: AppColors.white.withValues(alpha: 0.76),
                            fontSize: 13.5 * scale,
                            fontWeight: FontWeight.w400,
                            height: 1.45,
                          ),
                        ),
                        SizedBox(height: 12 * scaleY),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 14 * scaleX,
                            vertical: 14 * scaleY,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(20 * scale),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Text(
                            'Your account is secure again and everything is ready for your next login.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontSize: 12.5 * scale,
                              height: 1.45,
                            ),
                          ),
                        ),
                        SizedBox(height: 28 * scaleY),
                        _ContinueButton(
                          scale: scale,
                          isLoading: false,
                          onTap: () {
                            if (Get.isRegistered<LoginViewController>()) {
                              Get.delete<LoginViewController>(force: true);
                            }
                            Get.offAllNamed(AppRoutes.login);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const ResponsiveCornerBackButton(fallbackRoute: AppRoutes.login),
          ],
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.onTap,
    required this.isLoading,
    required this.scale,
  });

  final VoidCallback onTap;
  final bool isLoading;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54 * scale,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandGreen,
          foregroundColor: AppColors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 4,
          shadowColor: AppColors.brandGreen.withValues(alpha: 0.4),
        ),
        onPressed: isLoading ? null : onTap,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
                ),
              )
            : Text(
                'Continue to Sign In',
                style: GoogleFonts.poppins(
                  color: AppColors.black,
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
      ),
    );
  }
}
