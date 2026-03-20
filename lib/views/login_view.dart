import 'dart:math' as math;
import 'dart:ui';

import 'package:azanto/controllers/login_view_controller.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/views/widgets/corner_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends GetView<LoginViewController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final baseWidth = 390.0;
    final baseHeight = 844.0;
    final scaleX = size.width / baseWidth;
    final scaleY = size.height / baseHeight;
    final scale = math.min(scaleX, scaleY);
    final mediaPadding = MediaQuery.paddingOf(context);

    var glassTop = 211.0 * scaleY;
    final glassLeft = 13.0 * scaleX;
    final glassWidth = 364.0 * scaleX;
    final glassHeight = 623.0 * scaleY;

    var welcomeTop = 239.0 * scaleY;
    final welcomeLeft = 42.0 * scaleX;

    var usernameTop = 303.0 * scaleY;
    final fieldLeft = 42.0 * scaleX;
    final fieldWidth = 311.0 * scaleX;
    final fieldHeight = 53.0 * scaleY;
    var passwordTop = 386.0 * scaleY;
    var forgotTop = 461.0 * scaleY;
    var loginButtonTop = 519.0 * scaleY;
    var captionTop = 595.0 * scaleY;
    final loginButtonLeft = 38.0 * scaleX;
    final loginButtonWidth = 311.0 * scaleX;
    final loginButtonHeight = 59.0 * scaleY;

    final contentBottom = captionTop + (20.0 * scaleY);
    final availableBottom = size.height - mediaPadding.bottom - (10.0 * scaleY);
    final overflow = contentBottom - availableBottom;
    if (overflow > 0) {
      glassTop -= overflow;
      welcomeTop -= overflow;
      usernameTop -= overflow;
      passwordTop -= overflow;
      forgotTop -= overflow;
      loginButtonTop -= overflow;
      captionTop -= overflow;
    }

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
                'assets/images/login_background.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0.0, -0.48),
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
                  stops: [0.0, 0.38, 1.0],
                ),
              ),
            ),
            Positioned(
              left: glassLeft,
              top: glassTop,
              width: glassWidth,
              height: glassHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22 * scale),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.loginGlass,
                      borderRadius: BorderRadius.circular(22 * scale),
                      border: Border.all(color: AppColors.loginGlassBorder),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: welcomeLeft,
              top: welcomeTop,
              child: Text(
                'Welcome!',
                style: GoogleFonts.montserrat(
                  color: AppColors.white,
                  fontSize: 36.0 * scale,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ),
            Positioned(
              left: fieldLeft,
              top: usernameTop,
              width: fieldWidth,
              height: fieldHeight,
              child: _LoginField(
                controller: controller.usernameController,
                hintText: 'Phone No',
                icon: Icons.person,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                maxLength: 10,
              ),
            ),
            Positioned(
              left: fieldLeft,
              top: passwordTop,
              width: fieldWidth,
              height: fieldHeight,
              child: Obx(
                () => _LoginField(
                  controller: controller.passwordController,
                  hintText: 'Password',
                  icon: Icons.lock,
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
            ),
            Positioned(
              left: fieldLeft,
              top: forgotTop,
              child: GestureDetector(
                onTap: controller.onForgotPasswordTap,
                child: SizedBox(
                  width: 118.0 * scaleX,
                  child: Text(
                    'Forgot password?',
                    style: GoogleFonts.inter(
                      color: AppColors.white,
                      fontSize: 13.0 * scale,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                      shadows: const [
                        Shadow(
                          color: AppColors.authButtonTextShadow,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: loginButtonLeft,
              top: loginButtonTop,
              width: loginButtonWidth,
              height: loginButtonHeight,
              child: Obx(
                () => _LoginButton(
                  onTap: () => controller.onLoginTap(),
                  textScale: scale,
                  isBusy: controller.isLoading.value,
                ),
              ),
            ),
            Positioned(
              left: 95.0 * scaleX,
              top: captionTop,
              child: GestureDetector(
                onTap: controller.onSignUpTap,
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.montserrat(
                      fontSize: 12.0 * scale,
                      fontWeight: FontWeight.w400,
                      color: AppColors.loginCaption,
                    ),
                    children: const [
                      TextSpan(text: 'Don\'t have an account? '),
                      TextSpan(
                        text: 'Sign up',
                        style: TextStyle(
                          color: AppColors.loginSignUp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

class _LoginField extends StatelessWidget {
  const _LoginField({
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
        color: AppColors.loginFieldFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        style: GoogleFonts.montserrat(
          color: AppColors.white,
          fontSize: 28 * MediaQuery.textScalerOf(context).scale(0.5),
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: GoogleFonts.montserrat(
            color: AppColors.inputHint,
            fontSize: 28 * MediaQuery.textScalerOf(context).scale(0.5),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: AppColors.inputIcon, size: 23),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          counterText: '',
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.onTap,
    required this.textScale,
    this.isBusy = false,
  });

  final VoidCallback onTap;
  final double textScale;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.loginButtonBorderStart,
            AppColors.loginButtonBorderEnd,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.loginButtonFill,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: isBusy ? null : onTap,
              child: Center(
                child: SizedBox(
                  width: 63 * textScale,
                  height: 27 * textScale,
                  child: FittedBox(
                    child: isBusy
                        ? SizedBox(
                            width: 18 * textScale,
                            height: 18 * textScale,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Login',
                            style: GoogleFonts.montserrat(
                              color: AppColors.white,
                              fontSize: 20 * textScale,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
