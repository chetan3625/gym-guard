import 'dart:ui';

import 'package:azanto/Services/branch_service.dart';
import 'package:azanto/Services/gym_service.dart';
import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_manager.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:azanto/utils/backend_error_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GymOnboardingScreen extends StatefulWidget {
  const GymOnboardingScreen({super.key});

  @override
  State<GymOnboardingScreen> createState() => _GymOnboardingScreenState();
}

class _GymOnboardingScreenState extends State<GymOnboardingScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  final SessionService _session = Get.find<SessionService>();
  final GymService _gymService = Get.find<GymService>();
  final BranchService _branchService = Get.find<BranchService>();

  final TextEditingController _gymNameCtrl = TextEditingController();
  final TextEditingController _gymEmailCtrl = TextEditingController();
  final TextEditingController _branchNameCtrl = TextEditingController();
  final TextEditingController _branchAddressCtrl = TextEditingController();
  final TextEditingController _branchCityCtrl = TextEditingController();
  final TextEditingController _branchStateCtrl = TextEditingController();
  final TextEditingController _branchCountryCtrl = TextEditingController();
  final TextEditingController _branchPincodeCtrl = TextEditingController();

  int _step = 0;
  bool _isActive = true;
  bool _submitting = false;

  TimeOfDay _openingTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _closingTime = const TimeOfDay(hour: 22, minute: 0);

  @override
  void dispose() {
    _pageController.dispose();
    _gymNameCtrl.dispose();
    _gymEmailCtrl.dispose();
    _branchNameCtrl.dispose();
    _branchAddressCtrl.dispose();
    _branchCityCtrl.dispose();
    _branchStateCtrl.dispose();
    _branchCountryCtrl.dispose();
    _branchPincodeCtrl.dispose();
    super.dispose();
  }

  void _goToStep(int index) {
    setState(() => _step = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    const emailPattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
    if (!RegExp(emailPattern).hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  Future<void> _pickTime({required bool isOpening}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpening ? _openingTime : _closingTime,
    );
    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openingTime = picked;
        } else {
          _closingTime = picked;
        }
      });
    }
  }

  Future<void> _submitGymDetails() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    final name = _gymNameCtrl.text.trim();
    if (!formValid || name.isEmpty) {
      return;
    }
    _goToStep(1);
  }

  Future<void> _submitBranchDetails() async {
    final branchName = _branchNameCtrl.text.trim();
    final address = _branchAddressCtrl.text.trim();
    final city = _branchCityCtrl.text.trim();
    final state = _branchStateCtrl.text.trim();
    final country = _branchCountryCtrl.text.trim();
    final pincode = _branchPincodeCtrl.text.trim();

    if ([
      branchName,
      address,
      city,
      state,
      country,
      pincode,
    ].any((f) => f.isEmpty)) {
      Get.snackbar('Missing info', 'Please fill all branch fields.');
      return;
    }

    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final gymResult = await _gymService.createGym(
        name: _gymNameCtrl.text.trim(),
        email: _gymEmailCtrl.text.trim(),
        isActive: _isActive,
      );
      final gymId = (gymResult['id'] ?? gymResult['gym_id'] ?? _session.gymId)
          ?.toString();
      if (gymId == null || gymId.isEmpty) {
        throw ApiException('Gym created but id missing. Please try again.');
      }

      final branchResult = await _branchService.createBranch(
        gymId: gymId,
        name: branchName,
        address: address,
        city: city,
        state: state,
        country: country,
        pincode: pincode,
        openingTime: _openingTime,
        closingTime: _closingTime,
      );

      final branchDisplayName = branchResult['name']?.toString() ?? branchName;
      final branchId = (branchResult['branch_id'] ?? branchResult['id'])?.toString();
      
      if (branchId != null && branchId.isNotEmpty) {
        await _session.setBranchId(branchId);
      }

      await _session.setGymPromptDismissed(true);
      Get.snackbar(
        'Setup complete',
        '${_gymNameCtrl.text.trim()} • $branchDisplayName',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(AppRoutes.home);
    } on ApiException catch (e) {
      if (await BackendErrorWidgets.handleApiException(e)) {
        return;
      }
      Get.snackbar('Could not save', e.detailMessage);
    } catch (e) {
      Get.snackbar('Could not save', e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F121A), Color(0xFF0B0C12)],
                ),
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _GlowPainter())),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Let’s set up your gym',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: _submitting
                            ? null
                            : () async {
                                await TokenRefreshManager.clearState();
                                await _session.clearSession();
                                Get.offAllNamed(AppRoutes.roleSelection);
                              },
                        child: Text(
                          'Log out',
                          style: GoogleFonts.inter(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _step == 0
                        ? 'Step 1 of 2 • Gym details'
                        : 'Step 2 of 2 • First branch',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _StepDots(active: _step),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 255, 255, 0.03),
                            border: Border.all(
                              color: const Color.fromRGBO(255, 255, 255, 0.06),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Form(
                            key: _formKey,
                            child: PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _GymDetailsStep(
                                  gymNameCtrl: _gymNameCtrl,
                                  gymEmailCtrl: _gymEmailCtrl,
                                  isActive: _isActive,
                                  onToggleActive: (v) =>
                                      setState(() => _isActive = v),
                                  validateEmail: _validateEmail,
                                ),
                                _BranchDetailsStep(
                                  gymName: _gymNameCtrl.text.trim(),
                                  gymEmail: _gymEmailCtrl.text.trim(),
                                  branchNameCtrl: _branchNameCtrl,
                                  branchAddressCtrl: _branchAddressCtrl,
                                  branchCityCtrl: _branchCityCtrl,
                                  branchStateCtrl: _branchStateCtrl,
                                  branchCountryCtrl: _branchCountryCtrl,
                                  branchPincodeCtrl: _branchPincodeCtrl,
                                  openingTime: _openingTime,
                                  closingTime: _closingTime,
                                  onPickOpening: () =>
                                      _pickTime(isOpening: true),
                                  onPickClosing: () =>
                                      _pickTime(isOpening: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (_step > 0)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color.fromRGBO(
                                  255,
                                  255,
                                  255,
                                  0.18,
                                ),
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _submitting ? null : () => _goToStep(0),
                            child: const Text('Back'),
                          ),
                        ),
                      if (_step > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: _step == 0 ? 1 : 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandGreen,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: _submitting
                              ? null
                              : (_step == 0
                                    ? _submitGymDetails
                                    : _submitBranchDetails),
                          child: _submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : Text(_step == 0 ? 'Continue' : 'Finish setup'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GymDetailsStep extends StatelessWidget {
  const _GymDetailsStep({
    required this.gymNameCtrl,
    required this.gymEmailCtrl,
    required this.isActive,
    required this.onToggleActive,
    required this.validateEmail,
  });

  final TextEditingController gymNameCtrl;
  final TextEditingController gymEmailCtrl;
  final bool isActive;
  final ValueChanged<bool> onToggleActive;
  final String? Function(String?) validateEmail;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(
            label: 'Gym name',
            controller: gymNameCtrl,
            hintText: 'Pulse Fitness',
            validator: (value) =>
                (value?.trim().isEmpty ?? true) ? 'Gym name is required' : null,
          ),
          const SizedBox(height: 14),
          _Field(
            label: 'Contact email',
            controller: gymEmailCtrl,
            hintText: 'owner@gym.com',
            keyboardType: TextInputType.emailAddress,
            validator: validateEmail,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1D24),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.08),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Allow members to see your gym',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: isActive,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.brandGreen,
                  onChanged: onToggleActive,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _BranchDetailsStep extends StatelessWidget {
  const _BranchDetailsStep({
    required this.gymName,
    required this.gymEmail,
    required this.branchNameCtrl,
    required this.branchAddressCtrl,
    required this.branchCityCtrl,
    required this.branchStateCtrl,
    required this.branchCountryCtrl,
    required this.branchPincodeCtrl,
    required this.openingTime,
    required this.closingTime,
    required this.onPickOpening,
    required this.onPickClosing,
  });

  final String gymName;
  final String gymEmail;
  final TextEditingController branchNameCtrl;
  final TextEditingController branchAddressCtrl;
  final TextEditingController branchCityCtrl;
  final TextEditingController branchStateCtrl;
  final TextEditingController branchCountryCtrl;
  final TextEditingController branchPincodeCtrl;
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;
  final VoidCallback onPickOpening;
  final VoidCallback onPickClosing;

  @override
  Widget build(BuildContext context) {
    final hasGymData = gymName.trim().isNotEmpty || gymEmail.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          if (hasGymData)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D24),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color.fromRGBO(255, 255, 255, 0.08),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gym details',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (gymName.trim().isNotEmpty)
                    Text(
                      gymName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (gymEmail.trim().isNotEmpty)
                    Text(
                      gymEmail,
                      style: GoogleFonts.inter(color: Colors.white70),
                    ),
                ],
              ),
            ),
          _Field(
            label: 'Branch name',
            controller: branchNameCtrl,
            hintText: 'Main Branch',
            validator: (value) => (value?.trim().isEmpty ?? true)
                ? 'Branch name is required'
                : null,
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'Address',
            controller: branchAddressCtrl,
            hintText: '221B Baker Street',
            validator: (value) =>
                (value?.trim().isEmpty ?? true) ? 'Address is required' : null,
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'City',
            controller: branchCityCtrl,
            hintText: 'Mumbai',
            validator: (value) =>
                (value?.trim().isEmpty ?? true) ? 'City is required' : null,
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'State',
            controller: branchStateCtrl,
            hintText: 'Maharashtra',
            validator: (value) =>
                (value?.trim().isEmpty ?? true) ? 'State is required' : null,
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'Country',
            controller: branchCountryCtrl,
            hintText: 'India',
            validator: (value) =>
                (value?.trim().isEmpty ?? true) ? 'Country is required' : null,
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'Pincode',
            controller: branchPincodeCtrl,
            keyboardType: TextInputType.number,
            hintText: '400001',
            validator: (value) =>
                (value?.trim().isEmpty ?? true) ? 'Pincode is required' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TimeTile(
                  label: 'Opening time',
                  time: openingTime,
                  onTap: onPickOpening,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeTile(
                  label: 'Closing time',
                  time: closingTime,
                  onTap: onPickClosing,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color.fromRGBO(255, 255, 255, 0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              color: const Color.fromRGBO(255, 255, 255, 0.45),
            ),
            filled: true,
            fillColor: const Color(0xFF1B1D24),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromRGBO(255, 255, 255, 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.brandGreen),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = TimeOfDay(
      hour: time.hour,
      minute: time.minute,
    ).format(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1D24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatted,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Icon(Icons.schedule, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        2,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(right: 8),
          height: 8,
          width: index == active ? 32 : 8,
          decoration: BoxDecoration(
            color: index == active
                ? AppColors.brandGreen
                : const Color.fromRGBO(255, 255, 255, 0.24),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    paint.color = const Color.fromRGBO(99, 215, 0, 0.25);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.25), 140, paint);
    paint.color = const Color.fromRGBO(91, 95, 255, 0.18);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.4), 180, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
