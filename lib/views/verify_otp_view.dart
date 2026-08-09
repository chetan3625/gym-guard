import 'dart:math' as math;
import 'dart:ui';

import 'package:azanto/controllers/verify_otp_controller.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/views/widgets/corner_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifyOtpScreen extends GetView<VerifyOtpController> {
  const VerifyOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    const baseWidth = 390.0;
    const baseHeight = 844.0;
    final scaleX = size.width / baseWidth;
    final scaleY = size.height / baseHeight;
    final scale = math.min(scaleX, scaleY);

    final double glassLeft = 15 * scaleX;
    final double glassTop = 187 * scaleY;
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
            Positioned.fill(
              child: Image.asset(
                'assets/images/verify_Otp.png',
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
    final controller = Get.find<VerifyOtpController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 6 * scaleY),
        Text(
          'OTP Verification',
          style: GoogleFonts.montserrat(
            color: AppColors.white,
            fontSize: 28 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 10 * scaleY),
        Text(
          'Enter the verification code we just sent to your phone number.',
          style: GoogleFonts.inter(
            color: AppColors.white,
            fontSize: 13 * scale,
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
        SizedBox(height: 22 * scaleY),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            controller.digitControllers.length,
            (index) => _OtpBox(
              controller: controller.digitControllers[index],
              focusNode: controller.digitFocusNodes[index],
              isLast: index == controller.digitControllers.length - 1,
              onChanged: (val) => controller.onDigitChanged(index, val),
            ),
          ),
        ),
        SizedBox(height: 26 * scaleY),
        Obx(
          () => _VerifyButton(
            onTap: controller.onVerifyTap,
            isLoading: controller.isLoading.value,
            scale: scale,
          ),
        ),
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isLast,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLast;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.inputFieldFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: focusNode.hasFocus
                ? AppColors.brandGreen
                : Colors.white.withValues(alpha: 0.12),
            width: focusNode.hasFocus ? 1.5 : 1.0,
          ),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          textAlign: TextAlign.center,
          maxLength: 1,
          keyboardType: TextInputType.number,
          textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}

class _VerifyButton extends StatelessWidget {
  const _VerifyButton({
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
                'Verify',
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
