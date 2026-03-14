import 'dart:math' as math;
import 'dart:ui';
import 'dart:convert';

import 'package:azanto/Services/plan_service.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/login_services.dart';
import 'package:azanto/views/models/plan_option.dart';
import 'package:azanto/views/widgets/plan_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final scale = math
        .min(math.min(widthScale, heightScale), 1.0)
        .clamp(0.9, 1.0);
    final double availableWidth =
        MediaQuery.sizeOf(context).width - 32; // 16px padding both sides
    final double cardWidth = math.min(340 * scale, availableWidth).toDouble();
    final double cardHeight = math.min(190 * scale, 260).toDouble();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 18, 16, 118 + bottomPadding),
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
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create and manage membership plans for your gym.',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.68),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 18),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_plans.isEmpty)
            _EmptyState(onCreateTap: _openCreatePlanSheet, error: _loadError)
          else
            Column(
              children: [
                for (final plan in _plans) ...[
                  PlanCard(
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
                  const SizedBox(height: 18),
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
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
                                  fontSize: 20,
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
                          const SizedBox(height: 12),
                          _PlanField(
                            label: 'Name',
                            controller: nameCtrl,
                            hint: 'Annual Elite',
                          ),
                          const SizedBox(height: 12),
                          _PlanField(
                            label: 'Description',
                            controller: descCtrl,
                            hint: 'Unlimited access, PT sessions, sauna',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
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
                              const SizedBox(width: 12),
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
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Active',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
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
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF63D700),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 16,
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

                                      setModalState(() => submitting = true);
                                      setState(() => _creating = true);
                                      try {
                                        final response = await _planService
                                            .createPlan(
                                              name: name,
                                              description: desc,
                                              durationDays: duration,
                                              basePrice: price,
                                              isActive: isActive,
                                            );

                                        _addPlanToList(
                                          id:
                                              (response['id'] ??
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
                                        if (!mounted) return;
                                        Navigator.of(context).pop();
                                      } on ApiException catch (e) {
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

    try {
      final plans = await _planService.getAllPlans(gymId: gymId);
      _plans.clear();
      for (final plan in plans) {
        final name = (plan['name'] ?? '').toString();
        final desc = (plan['description'] ?? '').toString();
        final duration = plan['duration_days'] is int
            ? plan['duration_days'] as int
            : int.tryParse(plan['duration_days']?.toString() ?? '') ?? 0;
        final price = plan['base_price'] is num
            ? plan['base_price'] as num
            : num.tryParse(plan['base_price']?.toString() ?? '') ?? 0;
        _addPlanToList(
          id:
              (plan['id'] ??
                      plan['plan_id'] ??
                      DateTime.now().millisecondsSinceEpoch.toString())
                  .toString(),
          name: name,
          desc: desc,
          duration: duration,
          price: price,
        );
      }
    } on ApiException catch (e) {
      setState(() {
        _loadError = e.detailMessage;
      });
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
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
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
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.16)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.16)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateTap, this.error});

  final VoidCallback onCreateTap;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1E24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No plans yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create customised plans for your members with dynamic styled cards.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.68),
            ),
          ),
          if (error != null && error!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              error!,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.redAccent),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF63D700)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                foregroundColor: Colors.white,
              ),
              onPressed: onCreateTap,
              child: const Text('Create your first plan'),
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
      height: 42,
      child: ElevatedButton.icon(
        onPressed: isBusy ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF63D700),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 6,
        ),
        icon: isBusy
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : const Icon(Icons.add, size: 18),
        label: Text(
          isBusy ? 'Creating...' : 'New Plan',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
