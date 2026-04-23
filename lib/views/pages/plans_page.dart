import 'dart:math' as math;
import 'dart:ui';
import 'dart:convert';

import 'package:azanto/Services/plan_service.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/login_services.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/models/plan_model.dart';
import 'package:azanto/utils/backend_error_widgets.dart';
import 'package:azanto/views/pages/plan_details_page.dart';
import 'package:azanto/views/models/plan_option.dart';
import 'package:azanto/views/widgets/plan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final PlanService _planService = PlanService();
  final List<PlanOption> _plans = [];
  int _paletteIndex = 0;
  bool _creating = false;
  bool _loading = false;
  String? _loadError;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final widthScale = MediaQuery.sizeOf(context).width / 393.0;
    final heightScale = MediaQuery.sizeOf(context).height / 852.0;
    final scale =
        math.min(math.min(widthScale, heightScale), 1.0).clamp(0.9, 1.0);
    final double availableWidth =
        MediaQuery.sizeOf(context).width - 32; // 16px padding both sides
    final double cardWidth = math.min(340 * scale, availableWidth).toDouble();
    final double cardHeight = math.min(190 * scale, 260).toDouble();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 118.h + bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plans',
                      style: GoogleFonts.poppins(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Create and manage membership plans for your gym.',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        color: Colors.white.withOpacity(0.68),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              if (_plans.isNotEmpty)
                Flexible(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: _CreatePlanButton(
                      onTap: _openCreatePlanSheet,
                      isBusy: _creating,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 18.h),
          if (_loading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.h),
                child: const CircularProgressIndicator(),
              ),
            )
          else if (_plans.isEmpty && _loadError != null)
            _PlansLoadErrorState(error: _loadError!, onRetryTap: _loadPlans)
          else if (_plans.isEmpty)
            _EmptyState(onCreateTap: _openCreatePlanSheet)
          else
            Column(
              children: [
                for (final plan in _plans) ...[
                  GestureDetector(
                    onTap: () => _openPlanDetails(plan),
                    child: PlanCard(
                      option: plan,
                      scale: scale,
                      showButton: false,
                      forcedWidth: cardWidth,
                      forcedHeight: cardHeight,
                      customContentPadding: EdgeInsets.fromLTRB(
                        16 * scale,
                        20 * scale,
                        16 * scale,
                        16 * scale,
                      ),
                      titleFontSize: 28 * scale,
                      titleFontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 18.h),
                ],
              ],
            ),
        ],
      ),
    );
  }

  void _openCreatePlanSheet() {
    if (_creating) return;
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    bool isActive = true;
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final media = MediaQuery.of(context);
        final bottom = media.viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return Container(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 26.h),
                    color: const Color(0xFF15171D).withOpacity(0.92),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Create Plan',
                                style: GoogleFonts.poppins(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white70,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          _PlanField(
                            label: 'Name',
                            controller: nameCtrl,
                            hint: 'Annual Elite',
                          ),
                          SizedBox(height: 12.h),
                          _PlanField(
                            label: 'Description',
                            controller: descCtrl,
                            hint: 'Unlimited access, PT sessions, sauna',
                            maxLines: 3,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: _PlanField(
                                  label: 'Duration (days)',
                                  controller: durationCtrl,
                                  hint: '30',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _PlanField(
                                  label: 'Base price (Rs)',
                                  controller: priceCtrl,
                                  hint: '1800',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Active',
                                style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Switch(
                                value: isActive,
                                activeColor: Colors.white,
                                activeTrackColor: Colors.greenAccent,
                                onChanged: (v) =>
                                    setModalState(() => isActive = v),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF63D700),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: submitting
                                  ? null
                                  : () async {
                                      final name = nameCtrl.text.trim();
                                      final desc = descCtrl.text.trim();
                                      final duration = int.tryParse(
                                        durationCtrl.text.trim(),
                                      );
                                      final price = num.tryParse(
                                        priceCtrl.text.trim(),
                                      );

                                      if (name.isEmpty ||
                                          desc.isEmpty ||
                                          duration == null ||
                                          price == null) {
                                        Get.snackbar(
                                          'Missing info',
                                          'Fill all fields with valid values',
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                        return;
                                      }

                                      final gymId = _resolveGymId();
                                      if (gymId == null || gymId.isEmpty) {
                                        Get.snackbar('Error', 'No gym id found in token.', snackPosition: SnackPosition.BOTTOM);
                                        return;
                                      }
                                      final branchId = SessionService().branchId ?? gymId;

                                      setModalState(() => submitting = true);
                                      setState(() => _creating = true);
                                      try {
                                        final response =
                                            await _planService.createPlan(
                                          gymId: gymId,
                                          branchId: branchId,
                                          name: name,
                                          description: desc,
                                          durationDays: duration,
                                          basePrice: price,
                                          isActive: isActive,
                                        );

                                        _addPlanToList(
                                          id: (response['id'] ??
                                                  response['plan_id'] ??
                                                  DateTime.now()
                                                      .millisecondsSinceEpoch
                                                      .toString())
                                              .toString(),
                                          name: name,
                                          desc: desc,
                                          duration: duration,
                                          price: price,
                                        );

                                        Get.snackbar(
                                          'Plan created',
                                          response.toString(),
                                          snackPosition: SnackPosition.BOTTOM,
                                          duration: const Duration(seconds: 4),
                                        );
                                        if (!context.mounted) return;
                                        Navigator.of(context).pop();
                                      } on ApiException catch (e) {
                                        if (await BackendErrorWidgets
                                            .handleApiException(
                                          e,
                                        )) {
                                          return;
                                        }
                                        Get.snackbar(
                                          'Create failed',
                                          e.detailMessage,
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                      } catch (e) {
                                        Get.snackbar(
                                          'Error',
                                          e.toString(),
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                      } finally {
                                        setModalState(() => submitting = false);
                                        setState(() => _creating = false);
                                      }
                                    },
                              child: submitting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.black,
                                        ),
                                      ),
                                    )
                                  : const Text('Save plan'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _addPlanToList({
    required String id,
    required String name,
    required String desc,
    required int duration,
    required num price,
  }) {
    final palette = _palettes[_paletteIndex % _palettes.length];
    _paletteIndex++;

    setState(() {
      _plans.insert(
        0,
        PlanOption(
          id: id,
          title: name,
          subtitle: '$duration days • $desc',
          price: 'Rs ${price.toStringAsFixed(price is int ? 0 : 2)}',
          titleColor: palette.titleColor,
          borderColor: palette.borderColor,
          buttonGradient: palette.buttonGradient,
          buttonTextColor: palette.buttonTextColor,
          priceColor: palette.priceColor,
        ),
      );
    });
  }

  Future<void> _openPlanDetails(PlanOption plan) async {
    final updatedPlan = await Get.to<Plan>(
      () => PlanDetailsPage(
        planId: plan.id,
        initialTitle: plan.title,
      ),
    );
    
    // Always fetch updated plans from backend when returning
    await _loadPlans();
  }

  void _replacePlanInList(Plan updatedPlan) {
    final index = _plans.indexWhere((plan) => plan.id == updatedPlan.id);
    if (index < 0) return;

    final current = _plans[index];
    setState(() {
      _plans[index] = PlanOption(
        id: updatedPlan.id,
        title: updatedPlan.name,
        subtitle:
            '${updatedPlan.durationDays} days • ${updatedPlan.description}',
        price:
            'Rs ${updatedPlan.price.toStringAsFixed(updatedPlan.price is int ? 0 : 2)}',
        titleColor: current.titleColor,
        borderColor: current.borderColor,
        buttonGradient: current.buttonGradient,
        buttonTextColor: current.buttonTextColor,
        priceColor: current.priceColor,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _loadError = null;
    });

    final gymId = _resolveGymId();
    if (gymId == null || gymId.isEmpty) {
      setState(() {
        _loading = false;
        _loadError = 'No gym id found in token.';
      });
      return;
    }

    final branchId = SessionService().branchId ?? gymId;

    try {
      final plans = await _planService.getAllPlans(gymId: gymId, branchId: branchId);
      _plans.clear();
      for (final plan in plans) {
        _addPlanToList(
          id: plan.id,
          name: plan.name,
          desc: plan.description,
          duration: plan.durationDays,
          price: plan.price,
        );
      }
    } on ApiException catch (e) {
      final handled = await BackendErrorWidgets.handleApiException(e);
      setState(() {
        _loadError = e.detailMessage;
      });
      if (handled) {
        return;
      }
    } catch (e) {
      setState(() {
        _loadError = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String? _resolveGymId() {
    final session = SessionService();
    final stored = session.gymId;
    if (stored != null && stored.trim().isNotEmpty) return stored.trim();

    final token = session.token;
    if (token == null || token.trim().isEmpty) return null;
    final claims = _decodeJwtPayload(token);
    final gymId = claims['gym_id'] ?? claims['gymId'] ?? claims['gid'];
    if (gymId is String && gymId.trim().isNotEmpty) return gymId.trim();
    return null;
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return {};
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return {};
    } catch (_) {
      return {};
    }
  }
}

class _Palette {
  const _Palette({
    required this.titleColor,
    required this.borderColor,
    required this.buttonGradient,
    required this.buttonTextColor,
    required this.priceColor,
  });

  final Color titleColor;
  final Color borderColor;
  final Gradient buttonGradient;
  final Color buttonTextColor;
  final Color priceColor;
}

const _palettes = <_Palette>[
  _Palette(
    titleColor: Color(0xFFE2C067),
    borderColor: Color(0xFFF7DA58),
    buttonGradient: LinearGradient(
      colors: [Color(0xFFECC55D), Color(0xFFC38A1F)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    buttonTextColor: Color(0xFF0E3215),
    priceColor: Colors.white,
  ),
  _Palette(
    titleColor: Color(0xFFF2B980),
    borderColor: Color(0xFFF0C287),
    buttonGradient: LinearGradient(
      colors: [Color(0xFFD47C48), Color(0xFFF2A65B)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    buttonTextColor: Color(0xFF21130D),
    priceColor: Colors.white,
  ),
  _Palette(
    titleColor: Color(0xFFE2E2E8),
    borderColor: Color(0xFFC6C8CF),
    buttonGradient: LinearGradient(
      colors: [Color(0xFF8A8A90), Color(0xFFC7C9CF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    buttonTextColor: Color(0xFF11121A),
    priceColor: Colors.white,
  ),
  _Palette(
    titleColor: Color(0xFFE2E4EB),
    borderColor: Color(0xFFB4B9CE),
    buttonGradient: LinearGradient(
      colors: [Color(0xFF8C94B5), Color(0xFFC3C9DA)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    buttonTextColor: Color(0xFF0F1A2D),
    priceColor: Colors.white,
  ),
];

class _PlanField extends StatelessWidget {
  const _PlanField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.16)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.16)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: Colors.white),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateTap});

  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 24.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF191C24), Color(0xFF11131A)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.24),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200.h,
            child: Lottie.asset(
              'assets/animations/empty.json',
              repeat: true,
              fit: BoxFit.contain,
            ),
          ),
          Text(
            'No plans yet',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Your fetched plans are empty right now. Create your first membership plan and it will appear here instantly.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.68),
              height: 1.45,
            ),
          ),
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.black,
                backgroundColor: const Color(0xFF7CE05B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              onPressed: onCreateTap,
              child: Text(
                'Create Your First Plan',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlansLoadErrorState extends StatelessWidget {
  const _PlansLoadErrorState({required this.error, required this.onRetryTap});

  final String error;
  final VoidCallback onRetryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: Colors.white.withOpacity(0.82),
            size: 38.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            'Unable to load plans',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.white.withOpacity(0.70),
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 46.h,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF63D700)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                foregroundColor: Colors.white,
              ),
              onPressed: onRetryTap,
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatePlanButton extends StatelessWidget {
  const _CreatePlanButton({required this.onTap, required this.isBusy});

  final VoidCallback onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42.h,
      child: ElevatedButton.icon(
        onPressed: isBusy ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF63D700),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 6,
        ),
        icon: isBusy
            ? SizedBox(
                height: 16.h,
                width: 16.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : Icon(Icons.add, size: 18.sp),
        label: Text(
          isBusy ? 'Creating...' : 'New Plan',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
