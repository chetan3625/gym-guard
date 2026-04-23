import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/utils/backend_error_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class BackendErrorScreen extends StatelessWidget {
  const BackendErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final payload = Get.arguments;
    final errorPayload = payload is BackendErrorPayload
        ? payload
        : const BackendErrorPayload();
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height < 760;

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF08111F),
                    Color(0xFF0D1118),
                    Color(0xFF111216),
                  ],
                  stops: [0.0, 0.48, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: -20,
            top: 120,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromRGBO(60, 165, 255, 0.16),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(60, 165, 255, 0.18),
                    blurRadius: 90,
                    spreadRadius: 32,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: -26,
            bottom: 110,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromRGBO(143, 224, 255, 0.08),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(143, 224, 255, 0.12),
                    blurRadius: 110,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                isCompact ? 20 : 28,
                24,
                isCompact ? 18 : 28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      22,
                      isCompact ? 20 : 28,
                      22,
                      isCompact ? 20 : 26,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.05),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.10)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.32),
                          blurRadius: 28,
                          offset: const Offset(0, 16),
                        ),
                      ],
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
                              color: const Color.fromRGBO(255, 255, 255, 0.06),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: const Color.fromRGBO(255, 255, 255, 0.08),
                              ),
                            ),
                            child: Text(
                              'Backend Issue',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF8FD8FF),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isCompact ? 8 : 12),
                        SizedBox(
                          height: isCompact ? 220 : 260,
                          child: Lottie.asset(
                            'assets/animations/404 blue.json',
                            fit: BoxFit.contain,
                            repeat: true,
                          ),
                        ),
                        Text(
                          errorPayload.title ??
                              'Server is having trouble right now',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: isCompact ? 24 : 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          errorPayload.message?.trim().isNotEmpty == true
                              ? errorPayload.message!.trim()
                              : 'We could not complete this request because the backend is temporarily unavailable. Please try again in a moment.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            color: const Color.fromRGBO(255, 255, 255, 0.74),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  BackendErrorWidgets.hideBackendError(
                                    retry: true,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: AppColors.black,
                                  backgroundColor: const Color(0xFF83E3FF),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Try Again',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    BackendErrorWidgets.hideBackendError(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.white,
                                  side: BorderSide(
                                    color: const Color.fromRGBO(255, 255, 255, 0.18),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'Go Back',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
