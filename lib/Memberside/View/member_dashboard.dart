import 'package:azanto/Services/profile_local_prefs_service.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_manager.dart';
import 'package:azanto/Memberside/View/member_payment_page.dart';
import 'package:azanto/Memberside/View/member_progress_page.dart';
import 'package:azanto/Memberside/View/member_profile_page.dart';
import 'package:azanto/Memberside/View/member_notifications_page.dart';
import 'package:azanto/Memberside/View/member_settings_page.dart';
import 'package:azanto/Memberside/View/member_workout_page.dart';
import 'package:azanto/Memberside/constants/Common_widgets/member_bottom_nav_bar.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:azanto/core/responsive/responsive.dart';
import 'package:azanto/views/widgets/azanto_mobile_shell.dart';
import 'package:azanto/views/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MemberDashboardScreen extends StatefulWidget {
  const MemberDashboardScreen({super.key});

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  final SessionService _session = Get.find<SessionService>();
  final ProfileLocalPrefsService _profilePrefs =
      Get.find<ProfileLocalPrefsService>();

  int _currentIndex = 0;
  String _memberName = 'Member';
  String _memberInitial = 'M';

  @override
  void initState() {
    super.initState();
    _loadMemberIdentity();
  }

  Future<void> _loadMemberIdentity() async {
    final seed = await _profilePrefs.getProfileSeed();
    final resolvedName = [
      seed.firstName.trim(),
      seed.lastName.trim(),
    ].where((part) => part.isNotEmpty).join(' ');

    if (!mounted) return;
    setState(() {
      _memberName = resolvedName.isEmpty ? 'Dear' : resolvedName;
      _memberInitial = _memberName.substring(0, 1).toUpperCase();
    });
  }

  Future<void> _logout() async {
    await TokenRefreshManager.clearState();
    await _session.clearSession();
    if (!mounted) return;
    Get.offAllNamed(AppRoutes.roleSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mobileScaffold,
      appBar: AzantoAppBar(
        onSettingsTap: () => Get.to<void>(() => const MemberSettingsPage()),
        onNotificationsTap: () =>
            Get.to<void>(() => const MemberNotificationsPage()),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AzantoPageBackground(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _DashboardTab(
                memberName: _memberName,
                memberInitial: _memberInitial,
                onOpenProfile: () => setState(() => _currentIndex = 4),
              ),
              const MemberWorkoutPage(),
              const MemberProgressPage(),
              const MemberPaymentPage(),
              MemberProfilePage(
                memberName: _memberName,
                memberInitial: _memberInitial,
                onLogout: _logout,
                onProfileUpdated: _loadMemberIdentity,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MemberBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.memberName,
    required this.memberInitial,
    required this.onOpenProfile,
  });

  final String memberName;
  final String memberInitial;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return LayoutBuilder(
      builder: (context, constraints) {
        final pad = azantoContentPadding(context);
        final isWide =
            MediaQuery.sizeOf(context).width >= ResponsiveBreakpoints.phone;
        final quickActionGap = constraints.maxWidth < 360 ? 6.0 : 10.0;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: pad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GreetingCard(
                      memberInitial: memberInitial,
                      memberName: memberName,
                      onTap: onOpenProfile,
                    ),
                    const SizedBox(height: 16),
                    const _BiDirectionalSlider(),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Expanded(child: _MembershipCard()),
                        SizedBox(width: isWide ? 14 : 10),
                        const Expanded(child: _StreakCard()),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const _PaymentCard(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          "Today's Workout",
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Monday, June 12',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const _WorkoutCard(),
                    const SizedBox(height: 18),
                    Text(
                      'Quick Action',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Expanded(
                          child: _QuickActionCard(
                            icon: LucideIcons.fileText,
                            label: 'View Plan',
                          ),
                        ),
                        SizedBox(width: quickActionGap),
                        const Expanded(
                          child: _QuickActionCard(
                            icon: LucideIcons.calendarDays,
                            label: 'Attendance',
                          ),
                        ),
                        SizedBox(width: quickActionGap),
                        const Expanded(
                          child: _QuickActionCard(
                            icon: LucideIcons.qrCode,
                            label: 'Gym ID',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _QuoteCard(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({
    required this.memberInitial,
    required this.memberName,
    required this.onTap,
  });

  final String memberInitial;
  final String memberName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              height: 75,
              width: 75,
              decoration: const BoxDecoration(
                color: AppColors.cardSurfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  memberInitial,
                  style: GoogleFonts.poppins(
                    color: AppColors.brandGreen,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning , $memberName',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Push Your limits Today!',
                    style: GoogleFonts.poppins(
                      color: AppColors.textMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 131,
      padding: const EdgeInsets.all(14),
      decoration: azantoMetricCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _MetricIcon(icon: LucideIcons.shieldCheck),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.activeBadgeGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'ACTIVE',
                  style: GoogleFonts.poppins(
                    color: AppColors.activeBadgeGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            'Membership',
            style: GoogleFonts.poppins(
              color: AppColors.textMuted,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Basic Plan',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 131,
      padding: const EdgeInsets.all(14),
      decoration: azantoMetricCardDecoration(highlight: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 35,
                decoration: BoxDecoration(
                  color: AppColors.streakIconBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: const Icon(
                  LucideIcons.flame,
                  color: AppColors.brandGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Streak',
                style: GoogleFonts.poppins(
                  color: AppColors.textMuted,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '12',
                  style: GoogleFonts.poppins(
                    color: AppColors.brandGreen,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: ' days',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 79,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: azantoMetricCardDecoration(borderColor: Colors.transparent),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next Payment due',
                  style: GoogleFonts.poppins(
                    color: AppColors.textMuted,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'July 12,2026',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.payButtonStart, AppColors.payButtonEnd],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandGreen.withValues(alpha: 0.24),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {},
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  child: Text(
                    'Pay Now',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
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

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 79,
      padding: const EdgeInsets.all(11),
      decoration: azantoMetricCardDecoration(borderColor: Colors.transparent),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF25D392),
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF35E4B6), Color(0xFF1BAA78)],
              ),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: Colors.black87,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chest & Triceps',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '6 Exercise . 40 mins',
                  style: GoogleFonts.poppins(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: AppColors.brandGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandGreen.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.black,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: azantoMetricCardDecoration(borderColor: Colors.transparent),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 37,
            width: 37,
            decoration: const BoxDecoration(
              color: AppColors.cardIconCircle,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.brandGreen, size: 18),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
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

class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardIconCircle),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: AppColors.brandGreen,
            size: 27,
          ),
          const SizedBox(height: 10),
          Text(
            '"Success usually comes to those who are too busy to be looking for it."',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFFACABAA),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricIcon extends StatelessWidget {
  const _MetricIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: AppColors.brandGreen.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: AppColors.brandGreen, size: 16),
    );
  }
}

class _BiDirectionalSlider extends StatefulWidget {
  const _BiDirectionalSlider();

  @override
  State<_BiDirectionalSlider> createState() => _BiDirectionalSliderState();
}

class _BiDirectionalSliderState extends State<_BiDirectionalSlider> {
  double _dragPosition = 0.0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sliderWidth = constraints.maxWidth;
        const thumbWidth = 64.0;
        final maxDrag = (sliderWidth - thumbWidth) / 2 - 4; // 4 for padding

        // Determine colors based on drag position
        Color trackColor = const Color(0xFF1C1C1C);
        Color activeColor = Colors.white;

        if (_dragPosition > 0) {
          activeColor = Color.lerp(Colors.white, AppColors.brandGreen,
                  _dragPosition / maxDrag) ??
              AppColors.brandGreen;
        } else if (_dragPosition < 0) {
          activeColor = Color.lerp(Colors.white, const Color(0xFFFF4D4D),
                  -_dragPosition / maxDrag) ??
              const Color(0xFFFF4D4D);
        }

        return Container(
          height: 64,
          width: sliderWidth,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: activeColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: activeColor.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Check-Out Text (Left)
              Positioned(
                left: 24,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _dragPosition > 20 ? 0.0 : 1.0,
                  child: Row(
                    children: [
                      Icon(Icons.keyboard_double_arrow_left_rounded,
                          color: const Color(0xFFFF4D4D).withValues(alpha: 0.8),
                          size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Check-Out',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFF4D4D).withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Check-In Text (Right)
              Positioned(
                right: 24,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _dragPosition < -20 ? 0.0 : 1.0,
                  child: Row(
                    children: [
                      Text(
                        'Check-In',
                        style: GoogleFonts.poppins(
                          color: AppColors.brandGreen.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_double_arrow_right_rounded,
                          color: AppColors.brandGreen.withValues(alpha: 0.8),
                          size: 20),
                    ],
                  ),
                ),
              ),

              // The draggable Thumb
              AnimatedPositioned(
                duration: _isDragging
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                left: (sliderWidth / 2) - (thumbWidth / 2) + _dragPosition,
                child: GestureDetector(
                  onHorizontalDragStart: (_) {
                    setState(() => _isDragging = true);
                  },
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragPosition += details.delta.dx;
                      if (_dragPosition > maxDrag) _dragPosition = maxDrag;
                      if (_dragPosition < -maxDrag) _dragPosition = -maxDrag;
                    });
                  },
                  onHorizontalDragEnd: (details) async {
                    setState(() => _isDragging = false);

                    if (_dragPosition > maxDrag * 0.75) {
                      // Trigger Check-In
                      setState(() => _dragPosition = maxDrag);

                      Get.snackbar(
                        'Checked In',
                        'You have successfully checked in.',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor:
                            AppColors.brandGreen.withValues(alpha: 0.9),
                        colorText: Colors.black,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                        icon: const Icon(Icons.check_circle_outline,
                            color: Colors.black),
                      );

                      await Future.delayed(const Duration(milliseconds: 800));
                    } else if (_dragPosition < -maxDrag * 0.75) {
                      // Trigger Check-Out
                      setState(() => _dragPosition = -maxDrag);

                      Get.snackbar(
                        'Checked Out',
                        'You have successfully checked out.',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor:
                            const Color(0xFFFF4D4D).withValues(alpha: 0.9),
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                        icon: const Icon(Icons.logout_rounded,
                            color: Colors.white),
                      );

                      await Future.delayed(const Duration(milliseconds: 800));
                    }

                    // Snap back to center
                    if (mounted) {
                      setState(() => _dragPosition = 0.0);
                    }
                  },
                  child: Container(
                    width: thumbWidth,
                    height: 56,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        color:
                            _dragPosition == 0 ? Colors.black87 : Colors.black,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
