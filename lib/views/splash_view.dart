import 'package:azanto/controllers/splash_controller.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:azanto/views/widgets/app_logo.dart';
import 'package:azanto/views/widgets/azanto_background.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final logoSize = (shortestSide * 0.32).clamp(108.0, 156.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: AppColors.transparent,
        systemNavigationBarColor: AppColors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.black,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: AzantoBackground(
          child: Center(child: AppLogo(size: logoSize)),
        ),
      ),
    );
  }
}
