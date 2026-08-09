import 'dart:math' as math;
import 'dart:ui';

import 'package:azanto/controllers/signup_view_controller.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:azanto/views/widgets/corner_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends GetView<SignupViewController> {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    const baseWidth = 390.0;
    const baseHeight = 844.0;
    final scaleX = size.width / baseWidth;
    final scaleY = size.height / baseHeight;
    final scale = math.min(scaleX, scaleY);

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
                'assets/images/create_account.png',
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
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0 * scaleX,
                    vertical: 12 * scaleY,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22 * scale),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18 * scaleX,
                            vertical: 22 * scaleY,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.loginGlass,
                            borderRadius: BorderRadius.circular(22 * scale),
                            border: Border.all(
                              color: AppColors.loginGlassBorder,
                            ),
                          ),
                          child: _FormContent(
                            scale: scale,
                            scaleX: scaleX,
                            scaleY: scaleY,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveCornerBackButton(onTap: controller.onBackTap),
          ],
        ),
      ),
    );
  }
}

class _FormContent extends StatelessWidget {
  const _FormContent({
    required this.scale,
    required this.scaleX,
    required this.scaleY,
  });

  final double scale;
  final double scaleX;
  final double scaleY;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupViewController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 34 * scale),
        SizedBox(height: 16 * scaleY),
        Text(
          "Let's Start",
          style: GoogleFonts.montserrat(
            color: AppColors.white,
            fontSize: 32 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 18 * scaleY),
        _Label('Enter First Name and Last Name', scale),
        SizedBox(height: 8 * scaleY),
        _InputField(
          controller: controller.fullNameController,
          hintText: 'Enter First Name and Last Name',
          icon: Icons.person_outline,
        ),
        SizedBox(height: 14 * scaleY),
        _Label('Phone Number', scale),
        SizedBox(height: 8 * scaleY),
        _InputField(
          controller: controller.contactController,
          hintText: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          maxLength: 10,
        ),
        SizedBox(height: 14 * scaleY),
        _Label('Password', scale),
        SizedBox(height: 8 * scaleY),
        Obx(
          () => _InputField(
            controller: controller.passwordController,
            hintText: 'Password',
            icon: Icons.lock_outline,
            obscureText: controller.obscurePassword.value,
            suffix: IconButton(
              splashRadius: 18,
              onPressed: controller.togglePasswordVisibility,
              icon: Icon(
                controller.obscurePassword.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.inputIcon,
                size: 21 * scale,
              ),
            ),
          ),
        ),
        SizedBox(height: 14 * scaleY),
        _Label('Confirm Password', scale),
        SizedBox(height: 8 * scaleY),
        Obx(
          () => _InputField(
            controller: controller.confirmPasswordController,
            hintText: 'Confirm Password',
            icon: Icons.lock_outline,
            obscureText: controller.obscureConfirmPassword.value,
            suffix: IconButton(
              splashRadius: 18,
              onPressed: controller.toggleConfirmPasswordVisibility,
              icon: Icon(
                controller.obscureConfirmPassword.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.inputIcon,
                size: 21 * scale,
              ),
            ),
          ),
        ),
        SizedBox(height: 18 * scaleY),
        Center(
          child: Text.rich(
            TextSpan(
              text: 'By continuing, you agree to\n',
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontSize: 12 * scale,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: 'Terms of Use',
                  style: GoogleFonts.inter(
                    color: AppColors.brandGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: GoogleFonts.inter(
                    color: AppColors.brandGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 18 * scaleY),
        Obx(
          () => _SignUpButton(
            onTap: controller.onSignupTap,
            isLoading: controller.isLoading.value,
            scale: scale,
          ),
        ),
        SizedBox(height: 14 * scaleY),
        Center(
          child: Text(
            'or sign up with',
            style: GoogleFonts.inter(
              color: AppColors.white,
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 10 * scaleY),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialChip(
              icon: Icons.g_mobiledata,
              background: Colors.black.withValues(alpha: 0.6),
            ),
            SizedBox(width: 12 * scaleX),
            _SocialChip(
              icon: Icons.facebook_rounded,
              background: Colors.black.withValues(alpha: 0.6),
            ),
          ],
        ),
        SizedBox(height: 12 * scaleY),
        Center(
          child: GestureDetector(
            onTap: () => Get.offAllNamed(AppRoutes.login),
            child: Text.rich(
              TextSpan(
                text: "Don't have an account? ",
                style: GoogleFonts.montserrat(
                  color: AppColors.white,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: 'Register Now',
                    style: GoogleFonts.montserrat(
                      color: AppColors.brandGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, this.scale);
  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        color: AppColors.white,
        fontSize: 14 * scale,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.inputFieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        style: GoogleFonts.poppins(
          color: AppColors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: AppColors.inputHint,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: AppColors.brandGreen, size: 20),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 14,
          ),
          counterText: '',
        ),
      ),
    );
  }
}

class _SignUpButton extends StatelessWidget {
  const _SignUpButton({
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
                'Sign Up',
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

class _SocialChip extends StatelessWidget {
  const _SocialChip({required this.icon, required this.background});

  final IconData icon;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.loginGlassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Icon(icon, color: AppColors.white, size: 22),
      ),
    );
  }
}

// Needed for math.min
