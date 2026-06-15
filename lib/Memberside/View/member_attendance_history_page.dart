import 'package:azanto/Memberside/View/member_notifications_page.dart';
import 'package:azanto/Memberside/View/member_settings_page.dart';
import 'package:azanto/Memberside/constants/member_figma_layout.dart';
import 'package:azanto/Services/attendance_service.dart';
import 'package:azanto/Services/login_services.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/models/attendance_model.dart';
import 'package:azanto/views/widgets/azanto_mobile_shell.dart';
import 'package:azanto/views/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Figma: `attendance History` (447:124) — gym attendance overview.
class MemberAttendanceHistoryPage extends StatefulWidget {
  const MemberAttendanceHistoryPage({super.key});

  @override
  State<MemberAttendanceHistoryPage> createState() =>
      _MemberAttendanceHistoryPageState();
}

class _MemberAttendanceHistoryPageState
    extends State<MemberAttendanceHistoryPage> {
  late final AttendanceService _attendanceService;
  late Future<List<AttendanceModel>> _attendanceFuture;

  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _attendanceService = Get.isRegistered<AttendanceService>()
        ? Get.find<AttendanceService>()
        : AttendanceService();
    _attendanceFuture = _loadAttendance();
  }

  Future<List<AttendanceModel>> _loadAttendance() async {
    try {
      return await _attendanceService.myAttendance();
    } on ApiException catch (e) {
      Get.snackbar(
        'Attendance failed',
        e.detailMessage,
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    } catch (e) {
      Get.snackbar(
        'Attendance failed',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  void _retry() {
    setState(() {
      _attendanceFuture = _loadAttendance();
    });
  }

  void _shiftMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final layout = MemberFigmaLayout(context);

    return Scaffold(
      backgroundColor: AppColors.mobileScaffold,
      appBar: AzantoAppBar(
        onSettingsTap: () => Get.to<void>(() => const MemberSettingsPage()),
        onNotificationsTap: () =>
            Get.to<void>(() => const MemberNotificationsPage()),
      ),
      body: AzantoPageBackground(
        child: SafeArea(
          top: false,
          child: FutureBuilder<List<AttendanceModel>>(
            future: _attendanceFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.brandGreen),
                );
              }

              if (snapshot.hasError) {
                return _AttendanceStateMessage(
                  icon: LucideIcons.calendarX,
                  title: 'Could not load attendance',
                  actionLabel: 'Retry',
                  onAction: _retry,
                );
              }

              final attendance = snapshot.data ?? const <AttendanceModel>[];
              final attendedDays = _attendedDayKeys(attendance);
              final totalVisits = attendance.length;
              final streak = _calculateStreak(attendance);
              final goalPercent = _goalPercent(attendance, _visibleMonth);

              return SingleChildScrollView(
                padding: layout.padLTRB(17, 8, 17, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AttendanceHeader(layout: layout),
                    SizedBox(height: layout.s(14)),
                    _StatsCard(
                      layout: layout,
                      totalVisits: totalVisits,
                      streak: streak,
                      goalPercent: goalPercent,
                    ),
                    SizedBox(height: layout.s(18)),
                    _CalendarSection(
                      layout: layout,
                      visibleMonth: _visibleMonth,
                      selectedDay: _selectedDay,
                      attendedDays: attendedDays,
                      onPreviousMonth: () => _shiftMonth(-1),
                      onNextMonth: () => _shiftMonth(1),
                      onDaySelected: (day) =>
                          setState(() => _selectedDay = day),
                    ),
                    SizedBox(height: layout.s(22)),
                    Text(
                      'RECENT ACTIVITY',
                      style: layout.montserrat(
                        size: 14,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: layout.s(12)),
                    if (attendance.isEmpty)
                      const _AttendanceStateMessage(
                        icon: LucideIcons.calendarDays,
                        title: 'No attendance found',
                      )
                    else
                      ..._sortedAttendance(attendance).map(
                        (record) => Padding(
                          padding: EdgeInsets.only(bottom: layout.s(12)),
                          child: _ActivityCard(
                            layout: layout,
                            attendance: record,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AttendanceHeader extends StatelessWidget {
  const _AttendanceHeader({required this.layout});

  final MemberFigmaLayout layout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BackButton(layout: layout),
        Expanded(
          child: Text(
            'Gym Attendance',
            textAlign: TextAlign.center,
            style: layout.montserrat(
              size: 20,
              weight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: layout.s(36)),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.layout});

  final MemberFigmaLayout layout;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: Get.back<void>,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          width: layout.s(36),
          height: layout.s(34),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            LucideIcons.chevronLeft,
            color: Colors.white,
            size: layout.s(20),
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.layout,
    required this.totalVisits,
    required this.streak,
    required this.goalPercent,
  });

  final MemberFigmaLayout layout;
  final int totalVisits;
  final int streak;
  final int goalPercent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: layout.s(160),
      padding: layout.padLTRB(24, 18, 24, 18),
      decoration: azantoMetricCardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Visits',
                  style: layout.montserrat(
                    size: 15,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: layout.s(4)),
                Text(
                  '$totalVisits',
                  style: layout.montserrat(
                    size: 32,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  'Current Streak',
                  style: layout.montserrat(
                    size: 15,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: layout.s(4)),
                Row(
                  children: [
                    Container(
                      width: layout.s(35),
                      height: layout.s(32),
                      decoration: BoxDecoration(
                        color: AppColors.streakIconBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF333333)),
                      ),
                      child: Icon(
                        LucideIcons.flame,
                        color: AppColors.brandGreen,
                        size: layout.s(20),
                      ),
                    ),
                    SizedBox(width: layout.s(8)),
                    Text(
                      '$streak',
                      style: layout.montserrat(
                        size: 32,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: layout.s(4)),
                    Text(
                      'days',
                      style: layout.montserrat(
                        size: 20,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _GoalRing(layout: layout, percent: goalPercent),
        ],
      ),
    );
  }
}

class _GoalRing extends StatelessWidget {
  const _GoalRing({required this.layout, required this.percent});

  final MemberFigmaLayout layout;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final size = layout.s(96);
    final progress = (percent.clamp(0, 100)) / 100;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: layout.s(8),
              backgroundColor: AppColors.cardIconCircle.withValues(alpha: 0.35),
              color: AppColors.brandGreen,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: layout.montserrat(
                  size: 18,
                  weight: FontWeight.w700,
                  color: MemberFigmaColors.textPrimary,
                ),
              ),
              Text(
                'GOAL',
                style: layout.montserrat(
                  size: 8,
                  color: MemberFigmaColors.label,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarSection extends StatelessWidget {
  const _CalendarSection({
    required this.layout,
    required this.visibleMonth,
    required this.selectedDay,
    required this.attendedDays,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDaySelected,
  });

  final MemberFigmaLayout layout;
  final DateTime visibleMonth;
  final DateTime selectedDay;
  final Set<String> attendedDays;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDaySelected;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat', 'Sun'];
  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final monthLabel =
        '${_monthNames[visibleMonth.month - 1]} ${visibleMonth.year}';
    final days = _buildMonthDays(visibleMonth);
    final today = _dayKey(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                monthLabel,
                style: layout.montserrat(
                  size: 20,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            _MonthNavButton(
              icon: LucideIcons.chevronLeft,
              onTap: onPreviousMonth,
            ),
            SizedBox(width: layout.s(8)),
            _MonthNavButton(
              icon: LucideIcons.chevronRight,
              onTap: onNextMonth,
            ),
          ],
        ),
        SizedBox(height: layout.s(18)),
        Row(
          children: _weekdays
              .map(
                (label) => Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: layout.montserrat(
                      size: 16,
                      weight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        SizedBox(height: layout.s(12)),
        LayoutBuilder(
          builder: (context, constraints) {
            final cellWidth = (constraints.maxWidth - layout.s(8) * 6) / 7;
            return Wrap(
              spacing: layout.s(8),
              runSpacing: layout.s(10),
              children: days.map((day) {
                if (day == null) {
                  return SizedBox(width: cellWidth, height: layout.s(29));
                }

                final key = _dayKey(day);
                final isAttended = attendedDays.contains(key);
                final isSelected = _dayKey(selectedDay) == key;
                final isToday = key == today;

                return _CalendarDayCell(
                  layout: layout,
                  width: cellWidth,
                  day: day.day,
                  isAttended: isAttended,
                  isSelected: isSelected,
                  isToday: isToday,
                  onTap: () => onDaySelected(day),
                );
              }).toList(growable: false),
            );
          },
        ),
      ],
    );
  }

  List<DateTime?> _buildMonthDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = (firstDay.weekday - DateTime.monday) % 7;

    final cells = <DateTime?>[
      ...List<DateTime?>.filled(leading, null),
      ...List<DateTime?>.generate(
        daysInMonth,
        (index) => DateTime(month.year, month.month, index + 1),
      ),
    ];

    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }
}

class _MonthNavButton extends StatelessWidget {
  const _MonthNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: Colors.white70, size: 16),
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.layout,
    required this.width,
    required this.day,
    required this.isAttended,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final MemberFigmaLayout layout;
  final double width;
  final int day;
  final bool isAttended;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final height = layout.s(29);

    Color background = Colors.transparent;
    Color borderColor = Colors.transparent;
    Color textColor = AppColors.textMuted;
    double borderWidth = 1;

    if (isSelected) {
      background = AppColors.brandGreen;
      borderColor = AppColors.brandGreen;
      textColor = Colors.black;
    } else if (isAttended) {
      background = const Color(0xFF272727);
      borderColor = AppColors.brandGreen;
      textColor = Colors.white;
      borderWidth = isToday ? 1.5 : 1;
    } else if (isToday) {
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: borderColor == Colors.transparent
              ? null
              : Border.all(color: borderColor, width: borderWidth),
        ),
        child: Text(
          '$day',
          style: layout.montserrat(
            size: 16,
            weight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.layout,
    required this.attendance,
  });

  final MemberFigmaLayout layout;
  final AttendanceModel attendance;

  @override
  Widget build(BuildContext context) {
    final date = _resolveDate(attendance);
    final dayLabel = date == null ? '--' : _weekdayShort(date.weekday);
    final dayNumber = date == null ? '--' : '${date.day}';
    final workoutTitle = _workoutTitle(attendance);
    final checkInLabel = _formatCheckInTime(attendance.checkIn);
    final duration = _formatDuration(attendance);
    final isCompleted = attendance.checkOut != null ||
        (attendance.workoutSummary?.completedExercises ?? 0) > 0;

    return Container(
      padding: layout.padLTRB(17, 17, 17, 17),
      decoration: BoxDecoration(
        color: const Color(0xFF252626),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cardIconCircle.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: layout.s(52),
            padding: EdgeInsets.only(right: layout.s(12)),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: AppColors.cardIconCircle.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Column(
              children: [
                Text(
                  dayLabel.toUpperCase(),
                  style: layout.montserrat(
                    size: 10,
                    weight: FontWeight.w700,
                    color: MemberFigmaColors.label,
                  ),
                ),
                SizedBox(height: layout.s(2)),
                Text(
                  dayNumber,
                  style: layout.montserrat(
                    size: 20,
                    weight: FontWeight.w700,
                    color: MemberFigmaColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: layout.s(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        workoutTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: layout.montserrat(
                          size: 16,
                          weight: FontWeight.w700,
                          color: MemberFigmaColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isCompleted) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.brandGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'COMPLETED',
                        style: layout.montserrat(
                          size: 10,
                          weight: FontWeight.w500,
                          color: AppColors.brandGreen,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: layout.s(4)),
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock3,
                      size: layout.s(12),
                      color: MemberFigmaColors.label,
                    ),
                    SizedBox(width: layout.s(4)),
                    Text(
                      checkInLabel,
                      style: layout.montserrat(
                        size: 12,
                        color: MemberFigmaColors.label,
                      ),
                    ),
                    SizedBox(width: layout.s(16)),
                    Icon(
                      LucideIcons.timer,
                      size: layout.s(12),
                      color: MemberFigmaColors.label,
                    ),
                    SizedBox(width: layout.s(4)),
                    Text(
                      duration,
                      style: layout.montserrat(
                        size: 12,
                        color: MemberFigmaColors.label,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceStateMessage extends StatelessWidget {
  const _AttendanceStateMessage({
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white38, size: 36),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.brandGreen),
                  foregroundColor: AppColors.brandGreen,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

List<AttendanceModel> _sortedAttendance(List<AttendanceModel> attendance) {
  final sorted = List<AttendanceModel>.from(attendance);
  sorted.sort((a, b) {
    final aDate = _resolveDate(a);
    final bDate = _resolveDate(b);
    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return bDate.compareTo(aDate);
  });
  return sorted;
}

Set<String> _attendedDayKeys(List<AttendanceModel> attendance) {
  return attendance.map((record) {
    final date = _resolveDate(record);
    return date == null ? '' : _dayKey(date);
  }).where((key) => key.isNotEmpty).toSet();
}

int _calculateStreak(List<AttendanceModel> attendance) {
  if (attendance.isEmpty) return 0;

  final attended = _attendedDayKeys(attendance);
  var cursor = DateTime.now();
  var streak = 0;

  while (attended.contains(_dayKey(cursor))) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  if (streak == 0) {
    cursor = DateTime.now().subtract(const Duration(days: 1));
    while (attended.contains(_dayKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
  }

  return streak;
}

int _goalPercent(List<AttendanceModel> attendance, DateTime month) {
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final attendedInMonth = attendance.where((record) {
    final date = _resolveDate(record);
    return date != null &&
        date.year == month.year &&
        date.month == month.month;
  }).length;

  if (daysInMonth == 0) return 0;
  return ((attendedInMonth / daysInMonth) * 100).round().clamp(0, 100);
}

DateTime? _resolveDate(AttendanceModel attendance) {
  if (attendance.checkIn != null) return attendance.checkIn!.toLocal();
  final raw = attendance.date.trim();
  if (raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toLocal();
}

String _dayKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String _weekdayShort(int weekday) {
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[(weekday - DateTime.monday) % 7];
}

String _formatCheckInTime(DateTime? value) {
  if (value == null) return '--';
  final local = value.toLocal();
  final hour24 = local.hour;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  return '${hour12.toString().padLeft(2, '0')}:$minute $period';
}

String _formatDuration(AttendanceModel attendance) {
  final total = attendance.totalTime.trim();
  if (total.isNotEmpty) return total;

  final checkIn = attendance.checkIn;
  final checkOut = attendance.checkOut;
  if (checkIn == null || checkOut == null) return '--';

  final minutes = checkOut.difference(checkIn).inMinutes;
  if (minutes >= 60) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    return remainder == 0 ? '${hours}h' : '${hours}h ${remainder}m';
  }
  return '$minutes mins';
}

String _workoutTitle(AttendanceModel attendance) {
  final summary = attendance.workoutSummary;
  if (summary == null || summary.exercises.isEmpty) {
    return 'Gym Session';
  }

  final bodyParts = summary.exercises
      .map((exercise) => exercise.bodyPartName.trim())
      .where((name) => name.isNotEmpty)
      .toSet()
      .toList(growable: false);

  if (bodyParts.isNotEmpty) {
    return bodyParts.take(2).join(' & ');
  }

  final firstName = summary.exercises.first.exerciseName.trim();
  return firstName.isEmpty ? 'Gym Session' : firstName;
}
