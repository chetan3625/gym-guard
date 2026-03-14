import 'dart:math' as math;
import 'dart:ui';

import 'package:azanto/views/pages/select_plan_page.dart';
import 'package:azanto/views/widgets/corner_back_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMemberFormPage extends StatefulWidget {
  const AddMemberFormPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<AddMemberFormPage> createState() => _AddMemberFormPageState();
}

class _AddMemberFormPageState extends State<AddMemberFormPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final media = MediaQuery.of(context);

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewportHeight = constraints.maxHeight;
            final widthScale = constraints.maxWidth / 393.0;
            // Use full screen height to keep scale stable when keyboard opens.
            final heightScale = media.size.height / 852.0;
            final scale = math.min(widthScale, heightScale).clamp(0.82, 1.0);

            final cardLeft = 15 * scale;
            final cardTop = 311 * scale;
            final cardWidth = 364 * scale;
            final cardHeight = 528 * scale;
            final contentHeight = 852 * scale;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportHeight + viewInsets.bottom,
                ),
                child: SizedBox(
                  height: contentHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/add_members_bg.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.45),
                                Colors.black.withOpacity(0.75),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: cardLeft,
                        top: cardTop,
                        width: cardWidth,
                        height: cardHeight,
                        child: _buildCard(scale, fixedHeight: cardHeight),
                      ),
                      ResponsiveCornerBackButton(
                        onTap: widget.onBack,
                        baseWidth: 393,
                        baseHeight: 852,
                        x: 24,
                        y: 64,
                        baseSize: 36,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(double scale, {required double fixedHeight}) {
    final textWidth = 266 * scale;
    final buttonWidth = 311 * scale;
    final buttonHeight = 59 * scale;

    return SizedBox(
      height: fixedHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28 * scale),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12 * scale, sigmaY: 12 * scale),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(28 * scale),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  offset: Offset(0, 16 * scale),
                  blurRadius: 32 * scale,
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(
              24 * scale,
              24 * scale,
              24 * scale,
              24 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter\nMember\'s\nInformation',
                  style: GoogleFonts.montserrat(
                    fontSize: 32 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: 24 * scale),
                _LabeledField(
                  label: 'Name',
                  controller: _nameController,
                  hint: 'Ajay Kumar',
                  scale: scale,
                ),
                SizedBox(height: 18 * scale),
                _LabeledField(
                  label: 'Mobile Number',
                  controller: _phoneController,
                  hint: '00000 00000',
                  keyboardType: TextInputType.phone,
                  scale: scale,
                ),
                const Spacer(),
                SizedBox(height: 20 * scale),
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: _GradientButton(
                    label: 'Continue',
                    scale: scale,
                    onTap: _onContinueTap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onContinueTap() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      Get.snackbar(
        'Info',
        'Please enter both name and phone number',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    Get.to(
      () => SelectPlanPage(name: name, phone: phone),
      transition: Transition.downToUp,
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.scale,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
        SizedBox(height: 6 * scale),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 16 * scale,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.montserrat(
              color: Colors.white70,
              fontSize: 15 * scale,
            ),
            filled: true,
            fillColor: Colors.black.withOpacity(0.45),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 14 * scale,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18 * scale),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onTap,
    required this.scale,
  });

  final String label;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 59 * scale,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF69E322), Color(0xFF0DA339)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24 * scale),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0DA339).withOpacity(0.35),
              blurRadius: 16 * scale,
              offset: Offset(0, 8 * scale),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
