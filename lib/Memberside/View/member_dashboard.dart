import 'package:azanto/Services/profile_local_prefs_service.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_manager.dart';
import 'package:azanto/Memberside/View/member_payment_page.dart';
import 'package:azanto/Memberside/View/member_progress_page.dart';
import 'package:azanto/Memberside/View/member_profile_page.dart';
import 'package:azanto/Memberside/View/member_workout_page.dart';
import 'package:azanto/Memberside/constants/Common_widgets/member_bottom_nav_bar.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:azanto/views/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
      appBar: const AzantoAppBar(),
      backgroundColor: const Color(0xFF262626),
      body: SafeArea(
        bottom: false,
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
            ),
          ],
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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3A3A3A),
            Color(0xFF343434),
            Color(0xFF2B2B2B),
          ],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GreetingCard(
                    memberInitial: memberInitial,
                    memberName: memberName,
                    onTap: onOpenProfile,
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    children: [
                      Expanded(child: _MembershipCard()),
                      SizedBox(width: 10),
                      Expanded(child: _StreakCard()),
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
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Monday, June 12',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                          fontSize: 14,
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
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: LucideIcons.fileText,
                          label: 'View Plan',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionCard(
                          icon: LucideIcons.calendarDays,
                          label: 'Attendance',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
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
      ),
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
              height: 58,
              width: 58,
              decoration: const BoxDecoration(
                color: Color(0xFF313131),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  memberInitial,
                  style: GoogleFonts.poppins(
                    color: AppColors.brandGreen,
                    fontSize: 29,
                    fontWeight: FontWeight.w700,
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
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Push Your limits Today!',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 17,
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
      padding: const EdgeInsets.all(13),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _MetricIcon(icon: LucideIcons.shieldCheck),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brandGreen.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'ACTIVE',
                  style: GoogleFonts.poppins(
                    color: AppColors.brandGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Membership',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Basic Plan',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.all(13),
      decoration: _cardDecoration(highlight: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _MetricIcon(icon: LucideIcons.flame),
              const SizedBox(width: 10),
              Text(
                'Streak',
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '12',
                  style: GoogleFonts.poppins(
                    color: AppColors.brandGreen,
                    fontSize: 29,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' days',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Payment due',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'July 12,2026',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Color(0xFF86FF24), Color(0xFF63D615)],
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
      padding: const EdgeInsets.all(11),
      decoration: _cardDecoration(),
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
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '6 Exercise . 40 mins',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: const BoxDecoration(
              color: Color(0xFF3A3A3A),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.brandGreen, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: AppColors.brandGreen,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            '"Success usually comes to those who are too busy to be looking for it."',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 17,
              fontWeight: FontWeight.w500,
              height: 1.5,
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

BoxDecoration _cardDecoration({bool highlight = false}) {
  return BoxDecoration(
    color: const Color(0xFF353535),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: highlight ? Colors.white38 : Colors.white.withValues(alpha: 0.035),
      width: highlight ? 1.1 : 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 12,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
