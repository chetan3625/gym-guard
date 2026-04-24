import 'dart:math' as math;

import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/member_service.dart';
import 'package:azanto/views/pages/select_plan_page.dart';
import 'package:azanto/views/widgets/corner_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMemberFormPage extends StatefulWidget {
  const AddMemberFormPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<AddMemberFormPage> createState() => _AddMemberFormPageState();
}

class _AddMemberFormPageState extends State<AddMemberFormPage> {
  final _phoneController = TextEditingController();
  late final MemberService _memberService;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _memberService = Get.isRegistered<MemberService>()
        ? Get.find<MemberService>()
        : MemberService();
  }

  @override
  void dispose() {
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
                                Colors.black.withValues(alpha: 0.45),
                                const Color.fromRGBO(0, 0, 0, 0.75),
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
              color: const Color.fromRGBO(255, 255, 255, 0.18),
              borderRadius: BorderRadius.circular(28 * scale),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.35),
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
                  label: 'Mobile Number',
                  controller: _phoneController,
                  hint: 'Enter 10 digit mobile number',
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  scale: scale,
                  onSearchTap: _onSearchTap,
                ),
                const Spacer(),
                SizedBox(height: 20 * scale),
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: _GradientButton(
                    label: _isSearching ? 'Searching...' : 'Search Member',
                    scale: scale,
                    onTap: _isSearching ? null : _onSearchTap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSearchTap() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      Get.snackbar(
        'Invalid mobile number',
        'Mobile number must be exactly 10 digits',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSearching = true);

    try {
      final result = await _memberService.searchMemberByPhone(phone);

      debugPrint('=== ADD MEMBER SEARCH RESULT ===');
      debugPrint('Phone: $phone');
      debugPrint('Raw result: $result');
      debugPrint('User ID: ${result?['user_id'] ?? result?['id'] ?? 'not found'}');
      debugPrint('First Name: ${result?['first_name'] ?? result?['name'] ?? 'not found'}');
      debugPrint('Avatar URL: ${result?['avatar_url'] ?? 'not found'}');
      debugPrint('================================');

      if (!mounted) return;

      if (result != null) {
        final name = _resolveMemberName(result);
        final userId = _resolveUserId(result);
        if (userId == null || userId.isEmpty) {
          Get.snackbar(
            'Member lookup failed',
            'User ID was missing from the search response',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        Get.to(
          () => SelectPlanPage(name: name, phone: phone, userId: userId),
          transition: Transition.downToUp,
        );
      } else {
        Get.snackbar('Not found', 'No member found with this number');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Member search failed',
        e.detailMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  String _resolveMemberName(Map<String, dynamic> result) {
    final candidates = <dynamic>[
      result['first_name'],
      result['name'],
      result['full_name'],
      result['fullName'],
      result['phone'],
    ];

    for (final candidate in candidates) {
      final text = candidate?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return 'Member';
  }

  String? _resolveUserId(Map<String, dynamic> result) {
    final candidates = <dynamic>[
      result['user_id'],
      result['id'],
      result['_id'],
      result['member_id'],
    ];

    for (final candidate in candidates) {
      final text = candidate?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return null;
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.scale,
    this.keyboardType,
    this.inputFormatters,
    this.onSearchTap,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final double scale;
  final VoidCallback? onSearchTap;

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
            color: const Color.fromRGBO(255, 255, 255, 0.85),
          ),
        ),
        SizedBox(height: 6 * scale),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
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
                  fillColor: const Color.fromRGBO(0, 0, 0, 0.45),
                  counterText: '',
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
            ),
            SizedBox(width: 12 * scale),
            GestureDetector(
              onTap: onSearchTap,
              child: Container(
                padding: EdgeInsets.all(12 * scale),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF69E322), Color(0xFF0DA339)],
                  ),
                  borderRadius: BorderRadius.circular(18 * scale),
                ),
                child: Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 20 * scale,
                ),
              ),
            ),
          ],
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
  final VoidCallback? onTap;
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
              color: const Color.fromRGBO(13, 163, 57, 0.35),
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
