import 'package:azanto/Memberside/View/member_plan_checkout_page.dart';
import 'package:azanto/Memberside/constants/Common_widgets/member_figma_page_shell.dart';
import 'package:azanto/Memberside/constants/member_figma_layout.dart';
import 'package:azanto/Memberside/models/member_selected_plan.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Figma: 2nd `notification page` (356:148) — before settings in the member flow.
class MemberNotificationsPage extends StatefulWidget {
  const MemberNotificationsPage({super.key});

  @override
  State<MemberNotificationsPage> createState() => _MemberNotificationsPageState();
}

class _MemberNotificationsPageState extends State<MemberNotificationsPage> {
  late List<_NotificationItem> _items;

  @override
  void initState() {
    super.initState();
    _items = _seedNotifications();
  }

  void _markAllRead() {
    setState(() {
      _items = _items.map((n) => n.copyWith(unread: false)).toList();
    });
  }

  void _openPayment() {
    Get.to<void>(
      () => const MemberPlanCheckoutPage(
        selectedPlan: MemberSelectedPlan(
          id: 'elite',
          name: 'ELITE',
          displayName: 'Elite Plan',
          monthlyPrice: 49,
          yearly: false,
          perks: ['AI COACH', 'LIVE', 'DIET'],
          total: 49.99,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = MemberFigmaLayout(context);
    final today = _items.where((n) => n.group == _NotificationGroup.today).toList();
    final earlier =
        _items.where((n) => n.group == _NotificationGroup.earlier).toList();

    return MemberFigmaPageShell(
      bottomNavIndex: 0,
      showNotifications: false,
      gradientEnd: const Color(0xFF272727),
      body: SingleChildScrollView(
        padding: layout.padLTRB(18, 8, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NotificationsHeader(layout: layout),
            SizedBox(height: layout.s(20)),
            _NotificationSectionHeader(
              layout: layout,
              title: 'TODAY',
              actionLabel: 'Mark all read',
              onAction: _markAllRead,
            ),
            SizedBox(height: layout.s(16)),
            ...today.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: layout.s(16)),
                child: _NotificationCard(
                  layout: layout,
                  item: item,
                  onPayNow: _openPayment,
                ),
              ),
            ),
            SizedBox(height: layout.s(24)),
            _NotificationSectionHeader(
              layout: layout,
              title: 'EARLIER',
            ),
            SizedBox(height: layout.s(16)),
            ...earlier.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: layout.s(16)),
                child: _NotificationCard(
                  layout: layout,
                  item: item,
                  onPayNow: _openPayment,
                ),
              ),
            ),
            SizedBox(height: layout.s(32)),
            _CaughtUpFooter(layout: layout),
          ],
        ),
      ),
    );
  }
}

List<_NotificationItem> _seedNotifications() {
  return const [
    _NotificationItem(
      id: 'payment',
      group: _NotificationGroup.today,
      type: _NotificationType.payment,
      title: 'Payment Due',
      body:
          'Your monthly premium membership renewal of \$49.99 is due today.',
      timestamp: 'Now',
      unread: true,
      showPayNow: true,
    ),
    _NotificationItem(
      id: 'workout',
      group: _NotificationGroup.today,
      type: _NotificationType.workout,
      title: 'Workout Starting',
      body:
          '"High Intensity Metcon" with Coach Marcus starts in 15 minutes. Gear up!',
      timestamp: '15m',
      unread: true,
    ),
    _NotificationItem(
      id: 'goal',
      group: _NotificationGroup.today,
      type: _NotificationType.achievement,
      title: 'Weekly Goal Met!',
      body:
          "You've completed 4/4 workouts this week. Keep up the momentum!",
      timestamp: '2h',
      unread: true,
    ),
    _NotificationItem(
      id: 'yoga',
      group: _NotificationGroup.earlier,
      type: _NotificationType.classAnnouncement,
      title: 'New Class: Power Yoga',
      body:
          'Coach Sarah just added a new session for tomorrow morning at 7:00 AM.',
      timestamp: 'Yesterday',
      unread: false,
    ),
    _NotificationItem(
      id: 'maintenance',
      group: _NotificationGroup.earlier,
      type: _NotificationType.system,
      title: 'System Maintenance',
      body:
          'The app will be offline for scheduled maintenance on Sunday from 2 AM to 4 AM EST.',
      timestamp: '2d',
      unread: false,
    ),
    _NotificationItem(
      id: 'membership',
      group: _NotificationGroup.earlier,
      type: _NotificationType.membership,
      title: 'Membership Update',
      body:
          "Your membership was successfully updated to 'Premium Annual Plan'.",
      timestamp: '3 days ago',
      unread: false,
    ),
  ];
}

enum _NotificationGroup { today, earlier }

enum _NotificationType {
  payment,
  workout,
  achievement,
  classAnnouncement,
  system,
  membership,
}

class _NotificationItem {
  const _NotificationItem({
    required this.id,
    required this.group,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.unread = false,
    this.showPayNow = false,
  });

  final String id;
  final _NotificationGroup group;
  final _NotificationType type;
  final String title;
  final String body;
  final String timestamp;
  final bool unread;
  final bool showPayNow;

  _NotificationItem copyWith({bool? unread}) {
    return _NotificationItem(
      id: id,
      group: group,
      type: type,
      title: title,
      body: body,
      timestamp: timestamp,
      unread: unread ?? this.unread,
      showPayNow: showPayNow,
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({required this.layout});

  final MemberFigmaLayout layout;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: layout.s(34),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: MemberFigmaBackButton(),
          ),
          Text(
            'Notification',
            style: layout.montserrat(
              size: 16,
              weight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationSectionHeader extends StatelessWidget {
  const _NotificationSectionHeader({
    required this.layout,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final MemberFigmaLayout layout;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: layout.s(4)),
          child: Text(
            title,
            style: layout.montserrat(
              size: 11,
              weight: FontWeight.w700,
              color: MemberFigmaColors.label,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const Spacer(),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: layout.montserrat(
                size: 11,
                weight: FontWeight.w600,
                color: MemberFigmaColors.accent,
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.layout,
    required this.item,
    required this.onPayNow,
  });

  final MemberFigmaLayout layout;
  final _NotificationItem item;
  final VoidCallback onPayNow;

  @override
  Widget build(BuildContext context) {
    final accentBorder = item.unread
        ? Border.all(color: MemberFigmaColors.accent.withValues(alpha: 0.35))
        : Border.all(color: MemberFigmaColors.cardBorder);

    return Container(
      decoration: BoxDecoration(
        color: MemberFigmaColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: accentBorder,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: layout.s(14),
            offset: Offset(0, layout.s(5)),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: layout.padLTRB(17, 17, 17, 17),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NotificationIcon(layout: layout, type: item.type),
                SizedBox(width: layout.s(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (item.unread) ...[
                            Container(
                              width: layout.s(8),
                              height: layout.s(8),
                              margin: EdgeInsets.only(right: layout.s(8)),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: MemberFigmaColors.accent,
                              ),
                            ),
                          ],
                          Expanded(
                            child: Text(
                              item.title,
                              style: layout.montserrat(
                                size: 14,
                                weight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: layout.s(6)),
                      Text(
                        item.body,
                        style: layout.montserrat(
                          size: 12,
                          weight: FontWeight.w500,
                          color: MemberFigmaColors.label,
                          height: 1.45,
                        ),
                      ),
                      if (item.showPayNow) ...[
                        SizedBox(height: layout.s(12)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _PayNowButton(
                            layout: layout,
                            onTap: onPayNow,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: layout.s(17),
            right: layout.s(17),
            child: Text(
              item.timestamp,
              style: layout.montserrat(
                size: 10,
                weight: FontWeight.w500,
                color: MemberFigmaColors.textDim,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.layout, required this.type});

  final MemberFigmaLayout layout;
  final _NotificationType type;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color iconColor;
    final Color bg;

    switch (type) {
      case _NotificationType.payment:
        icon = LucideIcons.creditCard;
        iconColor = MemberFigmaColors.accent;
        bg = MemberFigmaColors.accent.withValues(alpha: 0.12);
      case _NotificationType.workout:
        icon = LucideIcons.dumbbell;
        iconColor = Colors.white;
        bg = const Color(0xFF3D4A38);
      case _NotificationType.achievement:
        icon = LucideIcons.trophy;
        iconColor = MemberFigmaColors.accent;
        bg = MemberFigmaColors.accent.withValues(alpha: 0.1);
      case _NotificationType.classAnnouncement:
        icon = LucideIcons.calendar;
        iconColor = Colors.white70;
        bg = MemberFigmaColors.cardIconCircle;
      case _NotificationType.system:
        icon = LucideIcons.settings;
        iconColor = Colors.white70;
        bg = MemberFigmaColors.cardIconCircle;
      case _NotificationType.membership:
        icon = LucideIcons.badgeCheck;
        iconColor = MemberFigmaColors.accent;
        bg = MemberFigmaColors.accent.withValues(alpha: 0.1);
    }

    return Container(
      width: layout.s(48),
      height: layout.s(48),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: layout.s(20)),
    );
  }
}

class _PayNowButton extends StatelessWidget {
  const _PayNowButton({required this.layout, required this.onTap});

  final MemberFigmaLayout layout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: layout.padLTRB(24, 8, 24, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF43890D), MemberFigmaColors.accent],
            ),
          ),
          child: Text(
            'PAY NOW',
            style: layout.montserrat(
              size: 11,
              weight: FontWeight.w800,
              color: MemberFigmaColors.accentDarkText,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _CaughtUpFooter extends StatelessWidget {
  const _CaughtUpFooter({required this.layout});

  final MemberFigmaLayout layout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          LucideIcons.bellOff,
          size: layout.s(30),
          color: MemberFigmaColors.textDim,
        ),
        SizedBox(height: layout.s(12)),
        Text(
          "You're all caught up",
          style: layout.montserrat(
            size: 13,
            weight: FontWeight.w600,
            color: MemberFigmaColors.textDim,
          ),
        ),
      ],
    );
  }
}
