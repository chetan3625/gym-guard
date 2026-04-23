import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/plan_service.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/models/plan_model.dart';
import 'package:azanto/utils/backend_error_widgets.dart';
import 'package:azanto/views/pages/cash_entry_page.dart';
import 'package:azanto/views/models/plan_option.dart';
import 'package:azanto/views/widgets/corner_back_button.dart';
import 'package:azanto/views/widgets/plan_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectPlanPage extends StatefulWidget {
  const SelectPlanPage({
    super.key,
    required this.name,
    required this.phone,
    required this.userId,
  });

  final String name;
  final String phone;
  final String userId;

  @override
  State<SelectPlanPage> createState() => _SelectPlanPageState();
}

class _SelectPlanPageState extends State<SelectPlanPage> {
  final PlanService _planService = PlanService();
  final SessionService _sessionService = SessionService();
  final List<PlanOption> _plans = <PlanOption>[];

  String? _selectedPlan;
  bool _loading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final widthScale = size.width / 393.0;
    final heightScale = size.height / 852.0;
    final scale = math
        .min(math.min(widthScale, heightScale), 1.0)
        .clamp(0.75, 1.0);

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
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.75),
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
                78 * scale,
                14 * scale,
                18 * scale,
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
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(32 * scale),
                        border: null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
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
                                    ..shader =
                                        LinearGradient(
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
                            _buildPlanContent(scale),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const ResponsiveCornerBackButton(),
        ],
      ),
    );
  }

  Widget _buildPlanContent(double scale) {
    if (_loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 48 * scale),
        child: Column(
          children: [
            SizedBox(
              height: 28 * scale,
              width: 28 * scale,
              child: const CircularProgressIndicator(strokeWidth: 2.8),
            ),
            SizedBox(height: 18 * scale),
            Text(
              'Fetching plans...',
              style: GoogleFonts.montserrat(
                fontSize: 15 * scale,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      );
    }

    if (_plans.isEmpty) {
      return _PlanStateCard(
        scale: scale,
        title: 'No plans available',
        message:
            _loadError ??
            'Create a plan first from the Plans tab, then it will appear here.',
        buttonLabel: 'Retry',
        onTap: _loadPlans,
      );
    }

    return Column(
      children: [
        for (final option in _plans) ...[
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
            onButtonTap: () => setState(() => _selectedPlan = option.id),
          ),
          SizedBox(height: 30 * scale),
        ],
        SizedBox(
          width: 311 * scale,
          child: _ProceedButton(scale: scale, onTap: _onProceedTap),
        ),
        SizedBox(height: 24 * scale),
      ],
    );
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
        _loadError = 'No gym id found in session.';
      });
      return;
    }

    final branchId = _sessionService.branchId ?? gymId;

    try {
      final fetchedPlans = await _planService.getAllPlans(gymId: gymId, branchId: branchId);
      final mappedPlans = fetchedPlans
          .asMap()
          .entries
          .map((entry) => _mapPlan(entry.value, entry.key))
          .toList();

      if (!mounted) return;

      setState(() {
        _plans
          ..clear()
          ..addAll(mappedPlans);

        final hasCurrentSelection = _plans.any(
          (plan) => plan.id == _selectedPlan,
        );
        if (!hasCurrentSelection) {
          _selectedPlan = null;
        }
      });
    } on ApiException catch (e) {
      final handled = await BackendErrorWidgets.handleApiException(e);
      if (!mounted) return;
      setState(() {
        _loadError = e.detailMessage;
      });
      if (handled) {
        return;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  PlanOption _mapPlan(Plan plan, int index) {
    final palette = _palettes[index % _palettes.length];
    final name = plan.name.trim();
    final description = plan.description.trim();
    final duration = plan.durationDays;
    final price = plan.price;

    final subtitleParts = <String>[
      if (duration > 0) '$duration days',
      if (description.isNotEmpty) description,
    ];

    return PlanOption(
      id: plan.id,
      title: name.isEmpty ? 'Plan ${index + 1}' : name,
      subtitle: subtitleParts.isEmpty
          ? 'Custom membership plan'
          : subtitleParts.join(' • '),
      price: _formatPrice(price),
      titleColor: palette.titleColor,
      borderColor: palette.borderColor,
      buttonGradient: palette.buttonGradient,
      buttonTextColor: palette.buttonTextColor,
      priceColor: palette.priceColor,
    );
  }

  String _formatPrice(num? amount) {
    if (amount == null) return '₹ 0';
    final isWhole = amount == amount.round();
    return '₹ ${isWhole ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2)}';
  }

  String? _resolveGymId() {
    final stored = _sessionService.gymId;
    if (stored != null && stored.trim().isNotEmpty) {
      return stored.trim();
    }

    final token = _sessionService.token;
    if (token == null || token.trim().isEmpty) {
      return null;
    }

    final claims = _decodeJwtPayload(token);
    final gymId = claims['gym_id'] ?? claims['gymId'] ?? claims['gid'];
    final gymIdText = gymId?.toString().trim();
    if (gymIdText != null && gymIdText.isNotEmpty) {
      return gymIdText;
    }

    return null;
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return <String, dynamic>{};
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return <String, dynamic>{};
    }
    return <String, dynamic>{};
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

    final gymId = _resolveGymId();
    if (gymId == null || gymId.isEmpty) {
      Get.snackbar(
        'Gym not found',
        'Please log in again and retry membership activation',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final option = _plans.firstWhere(
      (plan) => plan.id == _selectedPlan,
      orElse: () => _plans.first,
    );
    Get.to(
      () => CashEntryPage(
        planOption: option,
        name: widget.name,
        phone: widget.phone,
        userId: widget.userId,
        gymId: gymId,
      ),
      transition: Transition.downToUp,
    );
  }
}

class _PlanStateCard extends StatelessWidget {
  const _PlanStateCard({
    required this.scale,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onTap,
  });

  final double scale;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        20 * scale,
        18 * scale,
        20 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(22 * scale),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.45,
            ),
          ),
          SizedBox(height: 18 * scale),
          SizedBox(
            width: 180 * scale,
            child: _ProceedButton(
              scale: scale,
              label: buttonLabel,
              onTap: onTap,
            ),
          ),
          SizedBox(height: 8 * scale),
        ],
      ),
    );
  }
}

class _ProceedButton extends StatelessWidget {
  const _ProceedButton({
    required this.scale,
    required this.onTap,
    this.label = 'Proceed',
  });

  final double scale;
  final VoidCallback onTap;
  final String label;

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
            color: Colors.black.withValues(alpha: 0.4),
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
              label,
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

const List<_Palette> _palettes = <_Palette>[
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
