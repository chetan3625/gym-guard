import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class AppWidgets {
  static void showLoader() {
    Get.dialog(
      const Center(
        child: SizedBox(
          height: 120,
          width: 120,
          child: LottieAnimation(size: 120),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hideLoader() {
    Get.back();
  }
}

class LottieAnimation extends StatelessWidget {
  const LottieAnimation({
    super.key,
    this.size = 140,
    this.fit = BoxFit.contain,
  });

  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Lottie.asset(
        'assets/animations/loading.json',
        width: size,
        height: size,
        repeat: true,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.hourglass_top_rounded,
          size: size * 0.6,
          color: const Color(0xFF7DC13C),
        ),
      ),
    );
  }
}
