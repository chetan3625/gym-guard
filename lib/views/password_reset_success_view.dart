import 'dart:math' as math;
import 'dart:ui';

import 'package:azanto/controllers/login_view_controller.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:azanto/views/widgets/corner_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final baseWidth = 390.0;
    final baseHeight = 844.0;
    final scaleX = size.width / baseWidth;
    final scaleY = size.height / baseHeight;
    final scale = math.min(scaleX, scaleY);

    final double glassLeft = 15 * scaleX;
    final double glassTop = 220 * scaleY;
    final double desiredGlassWidth = 364 * scaleX;
    final double desiredGlassHeight = 480 * scaleY;
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
            Positioned.fill(
              child: Image.asset(
                'assets/images/success_password_reset_bg.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.2),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.loginOverlayTop,
                    AppColors.loginOverlayMid,
                    AppColors.loginOverlayBottom,
                  ],
                  stops: [0.0, 0.35, 1.0],
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
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      width: glassWidth,
                      constraints: BoxConstraints(minHeight: glassHeight),
                      padding: EdgeInsets.symmetric(
                        horizontal: 18 * scaleX,
                        vertical: 28 * scaleY,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.loginGlass,
                        borderRadius: BorderRadius.circular(glassRadius),
                        border: Border.all(color: AppColors.loginGlassBorder),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icons/password_reset_icon.png',
                            width: 88 * scale,
                            height: 88 * scale,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 22 * scaleY),
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
                            'Your password has been changed successfully.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: AppColors.white,
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
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
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7DC13C), Color(0xFF3E7E0F)],
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.authButtonShadow,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        height: 56 * scale,
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: isLoading ? null : onTap,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    )
                  : Text(
                      'Continue',
                      style: GoogleFonts.montserrat(
                        color: AppColors.white,
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
