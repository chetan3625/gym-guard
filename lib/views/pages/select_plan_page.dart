import 'dart:math' as math;
import 'dart:ui';

import 'package:azanto/views/pages/cash_entry_page.dart';
import 'package:azanto/views/models/plan_option.dart';
import 'package:azanto/views/widgets/corner_back_button.dart';
import 'package:azanto/views/widgets/plan_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectPlanPage extends StatefulWidget {
  const SelectPlanPage({super.key, required this.name, required this.phone});

  final String name;
  final String phone;

  @override
  State<SelectPlanPage> createState() => _SelectPlanPageState();
}

class _SelectPlanPageState extends State<SelectPlanPage> {
  String? _selectedPlan;

  static const _options = <PlanOption>[
    PlanOption(
      id: 'basic',
      title: 'Basic',
      subtitle: 'Monthly',
      price: '₹ 1000',
      titleColor: Color(0xFFF2B980),
      borderColor: Color(0xFFF0C287),
      buttonGradient: const LinearGradient(
        colors: [Color(0xFFD47C48), Color(0xFFF2A65B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      buttonTextColor: Color(0xFF21130D),
    ),
    PlanOption(
      id: 'pro',
      title: 'Pro',
      subtitle: 'Quarterly',
      price: '₹ 1000',
      titleColor: Color(0xFFE2E2E8),
      borderColor: Color(0xFFC6C8CF),
      buttonGradient: const LinearGradient(
        colors: [Color(0xFF8A8A90), Color(0xFFC7C9CF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      buttonTextColor: Color(0xFF11121A),
    ),
    PlanOption(
      id: 'gold',
      title: 'Gold',
      subtitle: 'Half-yearly',
      price: '₹ 1000',
      titleColor: Color(0xFFE2C067),
      borderColor: Color(0xFFF7DA58),
      buttonGradient: const LinearGradient(
        colors: [Color(0xFFECC55D), Color(0xFFC38A1F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      buttonTextColor: Color(0xFF0E3215),
    ),
    PlanOption(
      id: 'platinum',
      title: 'Platinum',
      subtitle: 'Yearly',
      price: '₹ 1000',
      titleColor: Color(0xFFE2E4EB),
      borderColor: Color(0xFFB4B9CE),
      buttonGradient: const LinearGradient(
        colors: [Color(0xFF8C94B5), Color(0xFFC3C9DA)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      buttonTextColor: Color(0xFF0F1A2D),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final widthScale = size.width / 393.0;
    final heightScale = size.height / 852.0;
    final scale = math
        .min(math.min(widthScale, heightScale), 1.0)
        .clamp(0.9, 1.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/select_plan.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.45),
                    Colors.black.withOpacity(0.75),
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                14 * scale,
                104 * scale,
                14 * scale,
                24 * scale,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32 * scale),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 14 * scale,
                      sigmaY: 14 * scale,
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(32 * scale),
                        border: null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            offset: Offset(0, 10 * scale),
                            blurRadius: 24 * scale,
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                          top: 32 * scale,
                          left: 26 * scale,
                          right: 26 * scale,
                          bottom: 48 * scale,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Select Plan',
                                style: GoogleFonts.montserrat(
                                  fontSize: 32 * scale,
                                  fontWeight: FontWeight.w700,
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: const [
                                        Color(0xFF93E0C2),
                                        Color(0xFFDFF455),
                                      ],
                                    ).createShader(
                                      const Rect.fromLTWH(0, 0, 220, 0),
                                    ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30 * scale),
                            for (final option in _options) ...[
                              PlanCard(
                                option: option,
                                scale: scale,
                                forcedWidth: 315 * scale,
                                forcedHeight: 210 * scale,
                                customContentPadding: EdgeInsets.fromLTRB(
                                  16 * scale,
                                  22 * scale,
                                  16 * scale,
                                  18 * scale,
                                ),
                                titleFontSize: 31 * scale,
                                titleFontWeight: FontWeight.w600,
                                isSelected: option.id == _selectedPlan,
                                onButtonTap: () =>
                                    setState(() => _selectedPlan = option.id),
                              ),
                              SizedBox(height: 30 * scale),
                            ],
                            SizedBox(
                              width: 311 * scale,
                              child: _ProceedButton(
                                scale: scale,
                                onTap: _onProceedTap,
                              ),
                            ),
                            SizedBox(height: 24 * scale),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: ResponsiveCornerBackButton(
              onTap: () => Get.back(),
              baseWidth: 393,
              baseHeight: 852,
              x: 24,
              y: 64,
              baseSize: 36,
            ),
          ),
        ],
      ),
    );
  }

  void _onProceedTap() {
    if (_selectedPlan == null) {
      Get.snackbar(
        'Select Plan',
        'Please select a plan before proceeding',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final option = _options.firstWhere(
      (plan) => plan.id == _selectedPlan,
      orElse: () => _options.first,
    );
    Get.to(
      () => CashEntryPage(
        planOption: option,
        name: widget.name,
        phone: widget.phone,
      ),
      transition: Transition.downToUp,
    );
  }
}

class _ProceedButton extends StatelessWidget {
  const _ProceedButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 59 * scale,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF63D700), Color(0xFF3EA400)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 18 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24 * scale),
          onTap: onTap,
          child: Center(
            child: Text(
              'Proceed',
              style: GoogleFonts.montserrat(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
