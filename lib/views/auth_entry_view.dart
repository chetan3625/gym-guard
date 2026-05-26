import 'dart:math' as math;

import 'package:azanto/controllers/auth_entry_controller.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/views/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthEntryScreen extends GetView<AuthEntryController> {
  const AuthEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    const baseWidth = 393.0;
    const baseHeight = 852.0;
    final scaleX = size.width / baseWidth;
    final scaleY = size.height / baseHeight;
    final scale = math.min(scaleX, scaleY);

    final logoLeft = 156.0 * scaleX;
    var logoTop = 397.0 * scaleY;
    final logoSize = 72.0 * scale;

    final titleFontSize = 38.0 * scale;
    final titleLetterSpacing = titleFontSize * 0.02;
    final titleLeft = 40.0 * scaleX;
    var titleTop = 512.0 * scaleY;
    final titleWidth = 313.0 * scaleX;
    final titleHeight = 92.0 * scaleY;

    final buttonLeft = 41.0 * scaleX;
    final buttonWidth = 311.0 * scaleX;
    final buttonHeight = (59.0 * scaleY).clamp(52.0, 64.0);
    final buttonTextSize = 24.0 * scale;
    final buttonTextWidth = 87.0 * scaleX;
    final buttonTextHeight = 28.0 * scaleY;
    var loginTop = 666.0 * scaleY;
    final buttonGap = 20.0 * scaleY;
    var signUpTop = loginTop + buttonHeight + buttonGap;

    final mediaPadding = MediaQuery.paddingOf(context);
    final bottomLimit = size.height - mediaPadding.bottom - (18.0 * scaleY);
    final overflow = (signUpTop + buttonHeight) - bottomLimit;
    if (overflow > 0) {
      logoTop -= overflow;
      titleTop -= overflow;
      loginTop -= overflow;
      signUpTop -= overflow;
    }

    final minLogoTop = mediaPadding.top + (24.0 * scaleY);
    if (logoTop < minLogoTop) {
      final shiftDown = minLogoTop - logoTop;
      logoTop += shiftDown;
      titleTop += shiftDown;
      loginTop += shiftDown;
      signUpTop += shiftDown;
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
                'assets/images/Splash3BG.png',
                fit: BoxFit.cover,
                alignment: size.width < 390
                    ? const Alignment(0.06, -0.72)
                    : const Alignment(0.0, -0.72),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.authOverlayTop,
                    AppColors.authOverlayMid,
                    AppColors.authOverlayBottom,
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
            Positioned(
              left: logoLeft,
              top: logoTop,
              width: logoSize,
              height: logoSize,
              child: AppLogo(size: logoSize),
            ),
            Positioned(
              left: titleLeft,
              top: titleTop,
              width: titleWidth,
              height: titleHeight,
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.montserrat(
                      color: AppColors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      letterSpacing: titleLetterSpacing,
                    ),
                    children: const [
                      TextSpan(text: 'Lead your\n'),
                      TextSpan(
                        text: 'Fitness',
                        style: TextStyle(color: AppColors.authTitleHighlight),
                      ),
                      TextSpan(text: ' Empire'),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: buttonLeft,
              top: loginTop,
              width: buttonWidth,
              child: _ActionButton(
                label: 'Login',
                height: buttonHeight,
                fontSize: buttonTextSize,
                textBoxWidth: buttonTextWidth,
                textBoxHeight: buttonTextHeight,
                onTap: controller.onLoginTap,
                decoration: BoxDecoration(
                  color: AppColors.authLoginFill,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.authLoginBorder,
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.authButtonShadow,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: buttonLeft,
              top: signUpTop,
              width: buttonWidth,
              child: _ActionButton(
                label: 'Sign Up',
                height: buttonHeight,
                fontSize: buttonTextSize,
                textBoxWidth: buttonTextWidth,
                textBoxHeight: buttonTextHeight,
                onTap: controller.onSignUpTap,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.authSignUpGradientTop,
                      AppColors.authSignUpGradientBottom,
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.authSignUpBorder,
                    width: 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.authButtonShadow,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.height,
    required this.fontSize,
    required this.textBoxWidth,
    required this.textBoxHeight,
    required this.decoration,
    required this.onTap,
  });

  final String label;
  final double height;
  final double fontSize;
  final double textBoxWidth;
  final double textBoxHeight;
  final BoxDecoration decoration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Center(
              child: SizedBox(
                width: textBoxWidth,
                height: textBoxHeight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: GoogleFonts.montserrat(
                      color: AppColors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      shadows: const [
                        Shadow(
                          color: AppColors.authButtonTextShadow,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
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
