import 'dart:async';

import 'package:azanto/Services/attendance_service.dart';
import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/membership_service.dart';
import 'package:azanto/Services/profile_local_prefs_service.dart';
import 'package:azanto/Services/profile_service.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_manager.dart';
import 'package:azanto/Services/plan_service.dart';
import 'package:azanto/models/profile_model.dart';
import 'package:azanto/Memberside/View/member_attendance_history_page.dart';
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
  final MembershipService _membershipService =
      Get.isRegistered<MembershipService>()
          ? Get.find<MembershipService>()
          : MembershipService();
  final ProfileLocalPrefsService _profilePrefs =
      Get.find<ProfileLocalPrefsService>();

  int _currentIndex = 0;
  String _memberName = 'Member';
  String _memberInitial = 'M';
  String _greetingMessage = _resolveGreetingMessage();
  String _enrolledPlanName = '';
  bool _isLoadingPlan = true;
  int _profileRefreshTrigger = 0;
  Timer? _greetingTimer;
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _loadMemberIdentity();
    _startGreetingTimer();
  }

  @override
  void dispose() {
    _greetingTimer?.cancel();
    super.dispose();
  }

  static String _resolveGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _startGreetingTimer() {
    _greetingTimer?.cancel();
    _greetingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final nextGreeting = _resolveGreetingMessage();
      if (!mounted || nextGreeting == _greetingMessage) return;
      setState(() => _greetingMessage = nextGreeting);
    });
  }

  Future<void> _loadMemberIdentity() async {
    final seed = await _profilePrefs.getProfileSeed();
    _updateIdentityState(seed.firstName, seed.lastName);

    try {
      final profileService = Get.isRegistered<ProfileService>()
          ? Get.find<ProfileService>()
          : ProfileService();
      final profile = await profileService.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
      });

      if (profile.membership != null) {
        await _session.setGymId(profile.membership!.gymId);
        await _session.setBranchId(profile.membership!.branchId);
        await _session.setPlanId(profile.membership!.planId);
      }

      await _profilePrefs.saveProfileSeed(
        firstName: profile.firstName,
        lastName: profile.lastName,
        phone: profile.phone,
        email: profile.email,
        dob: profile.dob,
        gender: profile.gender,
      );
      _updateIdentityState(profile.firstName, profile.lastName);
      await _loadEnrolledPlan();
    } catch (e) {
      debugPrint('Error fetching member profile on dashboard: $e');
      await _loadEnrolledPlan();
    }
  }

  void _updateIdentityState(String firstName, String lastName) {
    final resolvedName = [
      firstName.trim(),
      lastName.trim(),
    ].where((part) => part.isNotEmpty).join(' ');

    if (!mounted) return;
    setState(() {
      _memberName = resolvedName.isEmpty ? 'Dear' : resolvedName;
      _memberInitial = _memberName.isNotEmpty 
          ? _memberName.substring(0, 1).toUpperCase() 
          : 'M';
    });
  }

  Future<void> _loadEnrolledPlan() async {
    setState(() => _isLoadingPlan = true);
    try {
      final membership = _profile?.membership;
      if (membership != null && membership.planId.isNotEmpty) {
        final planService = Get.isRegistered<PlanService>()
            ? Get.find<PlanService>()
            : PlanService();
        final planDetails = await planService.getPlanDetails(
          planId: membership.planId,
        );
        if (!mounted) return;
        setState(() => _enrolledPlanName = planDetails.name);
      } else {
        final planName = await _membershipService.getEnrolledPlanName();
        if (!mounted) return;
        setState(() => _enrolledPlanName = planName);
      }
    } on ApiException catch (_) {
      if (!mounted) return;
      setState(() => _enrolledPlanName = '');
    } catch (_) {
      if (!mounted) return;
      setState(() => _enrolledPlanName = '');
    } finally {
      if (mounted) setState(() => _isLoadingPlan = false);
    }
  }

  Future<void> _logout() async {
    await TokenRefreshManager.clearState();
    await _session.clearSession();
    if (!mounted) return;
    Get.offAllNamed(AppRoutes.roleSelection);
  }

  void _openProfileTab() {
    setState(() {
      _currentIndex = 4;
      _profileRefreshTrigger++;
    });
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 4) {
        _profileRefreshTrigger++;
      }
    });
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
                greetingMessage: _greetingMessage,
                enrolledPlanName: _enrolledPlanName,
                isLoadingPlan: _isLoadingPlan,
                onOpenProfile: _openProfileTab,
              ),
              MemberWorkoutPage(
                isActive: _currentIndex == 1,
              ),
              const MemberProgressPage(),
              const MemberPaymentPage(),
              MemberProfilePage(
                memberName: _memberName,
                memberInitial: _memberInitial,
                onLogout: _logout,
                onProfileUpdated: _loadMemberIdentity,
                refreshTrigger: _profileRefreshTrigger,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MemberBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _handleBottomNavTap,
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.memberName,
    required this.memberInitial,
    required this.greetingMessage,
    required this.enrolledPlanName,
    required this.isLoadingPlan,
    required this.onOpenProfile,
  });

  final String memberName;
  final String memberInitial;
  final String greetingMessage;
  final String enrolledPlanName;
  final bool isLoadingPlan;
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
                      greetingMessage: greetingMessage,
                      onTap: onOpenProfile,
                    ),
                    const SizedBox(height: 16),
                    const _BiDirectionalSlider(),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _MembershipCard(
                            planName: enrolledPlanName,
                            isLoading: isLoadingPlan,
                          ),
                        ),
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
                        Expanded(
                          child: _QuickActionCard(
                            icon: LucideIcons.calendarDays,
                            label: 'Attendance',
                            onTap: () => Get.to<void>(
                              () => const MemberAttendanceHistoryPage(),
                            ),
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
    required this.greetingMessage,
    required this.onTap,
  });

  final String memberInitial;
  final String memberName;
  final String greetingMessage;
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
                    '$greetingMessage , $memberName',
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
  const _MembershipCard({
    required this.planName,
    required this.isLoading,
  });

  final String planName;
  final bool isLoading;

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
          if (isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.brandGreen,
              ),
            )
          else
            Text(
              planName.trim().isEmpty ? 'No Plan Found' : planName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          height: 92,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration:
              azantoMetricCardDecoration(borderColor: Colors.transparent),
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
        ),
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
  late final AttendanceService _attendanceService;
  late final SessionService _sessionService;
  double _dragPosition = 0.0;
  bool _isDragging = false;
  bool _isSubmitting = false;
  bool _isCheckedIn = false;
  bool _isLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    _attendanceService = Get.isRegistered<AttendanceService>()
        ? Get.find<AttendanceService>()
        : AttendanceService();
    _sessionService = Get.isRegistered<SessionService>()
        ? Get.find<SessionService>()
        : SessionService();
    _loadCurrentAttendanceStatus();
  }

  Future<void> _loadCurrentAttendanceStatus() async {
    try {
      final records = await _attendanceService.myAttendance();
      if (!mounted) return;
      setState(() {
        _isCheckedIn = records.any((r) => r.checkIn != null && r.checkOut == null);
        _isLoadingStatus = false;
      });
    } catch (e) {
      debugPrint('Error loading attendance status: $e');
      if (mounted) {
        setState(() => _isLoadingStatus = false);
      }
    }
  }

  Future<void> _submitAttendance({required bool isCheckIn}) async {
    if (_isSubmitting) {
      debugPrint(
          'Dashboard attendance swipe skipped: request already running.');
      return;
    }

    final gymId = _sessionService.gymId?.trim() ?? '';
    final branchId = (_sessionService.branchId ?? gymId).trim();
    debugPrint(
      'Dashboard attendance swipe triggered: ${isCheckIn ? 'check-in' : 'check-out'}, gym_id=$gymId, branch_id=$branchId',
    );

    if (gymId.isEmpty || branchId.isEmpty) {
      debugPrint(
        'Dashboard attendance API not hit because gym_id or branch_id is empty.',
      );
      Get.snackbar(
        'Attendance failed',
        'Gym or branch is missing. Please login again.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = isCheckIn
          ? await _attendanceService.checkIn(gymId: gymId, branchId: branchId)
          : await _attendanceService.checkOut(gymId: gymId, branchId: branchId);

      if (!mounted) return;
      setState(() {
        _isCheckedIn = isCheckIn;
      });

      final totalTime = response.totalTime.trim();
      Get.snackbar(
        isCheckIn ? 'Checked In' : 'Checked Out',
        isCheckIn
            ? 'You have successfully checked in.'
            : totalTime.isNotEmpty
                ? 'You have successfully checked out. Total time: $totalTime'
                : 'You have successfully checked out.',
        snackPosition: SnackPosition.TOP,
        backgroundColor:
            (isCheckIn ? AppColors.brandGreen : const Color(0xFFFF4D4D))
                .withValues(alpha: 0.9),
        colorText: isCheckIn ? Colors.black : Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(
          isCheckIn ? Icons.check_circle_outline : Icons.logout_rounded,
          color: isCheckIn ? Colors.black : Colors.white,
        ),
      );
    } on ApiException catch (e) {
      debugPrint('Dashboard attendance API failed: ${e.detailMessage}');
      Get.snackbar(
        'Attendance failed',
        e.detailMessage,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint('Dashboard attendance API failed unexpectedly: $e');
      Get.snackbar(
        'Attendance failed',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sliderWidth = constraints.maxWidth;
        const thumbWidth = 64.0;
        const padding = 4.0;
        const leftBound = padding;
        final rightBound = sliderWidth - thumbWidth - padding;
        final totalRange = rightBound - leftBound;

        if (_isLoadingStatus) {
          return Container(
            height: 64,
            width: sliderWidth,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brandGreen,
                ),
              ),
            ),
          );
        }

        // Determine colors based on drag position and state
        Color activeColor;
        Color borderActiveColor;
        if (_isCheckedIn) {
          final ratio = (totalRange > 0) ? (_dragPosition / totalRange).clamp(0.0, 1.0) : 0.0;
          activeColor = Color.lerp(AppColors.brandGreen, const Color(0xFFFF4D4D), ratio) ?? AppColors.brandGreen;
          borderActiveColor = activeColor.withValues(alpha: 0.3);
        } else {
          final ratio = (totalRange > 0) ? (-_dragPosition / totalRange).clamp(0.0, 1.0) : 0.0;
          activeColor = Color.lerp(Colors.white, AppColors.brandGreen, ratio) ?? Colors.white;
          borderActiveColor = activeColor.withValues(alpha: ratio > 0.1 ? 0.3 : 0.1);
        }

        final thumbLeft = _isCheckedIn ? (leftBound + _dragPosition) : (rightBound + _dragPosition);

        return Container(
          height: 64,
          width: sliderWidth,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: borderActiveColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: activeColor.withValues(alpha: _isCheckedIn ? 0.15 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Check-In Text (Left side, visible when user is checked out)
              if (!_isCheckedIn)
                Positioned(
                  left: 24,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _dragPosition < -20 ? 0.0 : 1.0,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.keyboard_double_arrow_left_rounded,
                          color: AppColors.brandGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Check-In',
                          style: GoogleFonts.poppins(
                            color: AppColors.brandGreen.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Check-Out Text (Right side, visible when user is checked in)
              if (_isCheckedIn)
                Positioned(
                  right: 24,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _dragPosition > 20 ? 0.0 : 1.0,
                    child: Row(
                      children: [
                        Text(
                          'Check-Out',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFF4D4D).withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.keyboard_double_arrow_right_rounded,
                          color: Color(0xFFFF4D4D),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

              // The draggable Thumb
              AnimatedPositioned(
                duration: _isDragging
                    ? Duration.zero
                    : const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: thumbLeft,
                top: 4,
                child: GestureDetector(
                  onHorizontalDragStart: (_) {
                    if (_isSubmitting) return;
                    setState(() => _isDragging = true);
                  },
                  onHorizontalDragUpdate: (details) {
                    if (_isSubmitting) return;
                    setState(() {
                      _dragPosition += details.delta.dx;
                      if (_isCheckedIn) {
                        if (_dragPosition < 0.0) _dragPosition = 0.0;
                        if (_dragPosition > totalRange) _dragPosition = totalRange;
                      } else {
                        if (_dragPosition > 0.0) _dragPosition = 0.0;
                        if (_dragPosition < -totalRange) _dragPosition = -totalRange;
                      }
                    });
                  },
                  onHorizontalDragEnd: (details) async {
                    if (_isSubmitting) return;
                    setState(() => _isDragging = false);

                    if (_isCheckedIn) {
                      if (_dragPosition > totalRange * 0.75) {
                        setState(() => _dragPosition = totalRange);
                        await _submitAttendance(isCheckIn: false);
                      }
                    } else {
                      if (_dragPosition < -totalRange * 0.75) {
                        setState(() => _dragPosition = -totalRange);
                        await _submitAttendance(isCheckIn: true);
                      }
                    }

                    if (mounted) {
                      setState(() {
                        _dragPosition = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: thumbWidth,
                    height: 52,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black87,
                              ),
                            )
                          : Icon(
                              _isCheckedIn
                                  ? Icons.keyboard_double_arrow_right_rounded
                                  : Icons.keyboard_double_arrow_left_rounded,
                              color: Colors.black87,
                              size: 26,
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
