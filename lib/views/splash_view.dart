import 'package:azanto/controllers/splash_controller.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/views/widgets/app_logo.dart';
import 'package:azanto/views/widgets/azanto_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final logoSize = (shortestSide * 0.32).clamp(108.0, 156.0).toDouble();

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
          child: Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: controller.showOfflineState.value
                  ? _OfflineSplashState(
                      key: const ValueKey<String>('offline-state'),
                      isRetrying: controller.isCheckingConnection.value,
                      onRetryTap: controller.retryConnection,
                    )
                  : _SplashLogoState(
                      key: const ValueKey<String>('logo-state'),
                      logoSize: logoSize,
                      isCheckingConnection:
                          controller.isCheckingConnection.value,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashLogoState extends StatelessWidget {
  const _SplashLogoState({
    super.key,
    required this.logoSize,
    required this.isCheckingConnection,
  });

  final double logoSize;
  final bool isCheckingConnection;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLogo(size: logoSize),
          const SizedBox(height: 18),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isCheckingConnection ? 1 : 0,
            child: Text(
              'Checking connection...',
              style: GoogleFonts.inter(
                color: AppColors.white.withValues(alpha: 0.78),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineSplashState extends StatelessWidget {
  const _OfflineSplashState({
    super.key,
    required this.isRetrying,
    required this.onRetryTap,
  });

  final bool isRetrying;
  final Future<void> Function() onRetryTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height < 760;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          isCompact ? 20 : 28,
          24,
          isCompact ? 16 : 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xCC0F1826), Color(0xE6141419)],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF46B8FF).withValues(alpha: 0.12),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 26,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  22,
                  isCompact ? 20 : 26,
                  22,
                  isCompact ? 20 : 26,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Text(
                          'Offline Mode',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF89D5FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isCompact ? 8 : 12),
                    SizedBox(
                      height: isCompact ? 200 : 240,
                      child: Lottie.asset(
                        'assets/animations/connectivity_issue.json',
                        repeat: true,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text(
                      'Please connect to the internet',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: AppColors.white,
                        fontSize: isCompact ? 24 : 28,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Azanto needs a live connection to load your gym, plans, and latest session safely.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: isCompact ? 13.5 : 14.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Text(
                        'Turn on Wi-Fi or mobile data, then tap retry. We will also continue automatically as soon as your connection is back.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isRetrying ? null : () => onRetryTap(),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.black,
                          backgroundColor: const Color(0xFF7BE255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: isRetrying
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.black,
                                  ),
                                ),
                              )
                            : Text(
                                'Retry Connection',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
