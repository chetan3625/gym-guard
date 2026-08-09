import 'dart:math' as math;
import 'dart:ui';

import 'package:azanto/controllers/forgot_password_controller.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/views/widgets/corner_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    const baseWidth = 390.0;
    const baseHeight = 844.0;
    final scaleX = size.width / baseWidth;
    final scaleY = size.height / baseHeight;
    final scale = math.min(scaleX, scaleY);
    // Desired glass dimensions based on reference: x=15, y=187, w=364, h=656 on a 390x844-ish base.
    final double glassLeft = 15 * scaleX;
    final double glassTop = 187 * scaleY;
    final double desiredGlassWidth = 364 * scaleX;
    final double desiredGlassHeight = 656 * scaleY;
    final double availableWidth = size.width - glassLeft;
    final double glassWidth = math.min(
      desiredGlassWidth,
      availableWidth - 8,
    ); // keep slight margin if tight
    // Keep the card from hitting the screen bottom so the radius stays visible.
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
                'assets/images/Forget_password_BG.png',
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
                        vertical: 22 * scaleY,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.loginGlass,
                        borderRadius: BorderRadius.circular(glassRadius),
                        border: Border.all(color: AppColors.loginGlassBorder),
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
    final controller = Get.find<ForgotPasswordController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 18 * scaleY),
        Text(
          'Forgot Password?',
          style: GoogleFonts.montserrat(
            color: AppColors.white,
            fontSize: 28 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 10 * scaleY),
        Text(
          "Don't worry! It occurs. Please enter the phone number linked with your account.",
          style: GoogleFonts.inter(
            color: AppColors.white,
            fontSize: 13 * scale,
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
        SizedBox(height: 18 * scaleY),
        _Label('Phone Number', scale),
        SizedBox(height: 8 * scaleY),
        _InputField(
          controller: controller.phoneController,
          hintText: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          maxLength: 10,
        ),
        SizedBox(height: 20 * scaleY),
        Obx(
          () => _SendButton(
            onTap: controller.onSendCodeTap,
            isLoading: controller.isLoading.value,
            scale: scale,
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
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
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

class _SendButton extends StatelessWidget {
  const _SendButton({
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
                'Send Code',
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
