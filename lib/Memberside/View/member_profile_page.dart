import 'package:azanto/Memberside/View/member_personal_info_page.dart';
import 'package:azanto/Memberside/View/member_settings_page.dart';
import 'package:azanto/Memberside/constants/member_figma_layout.dart';
import 'package:azanto/Services/profile_local_prefs_service.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/views/widgets/azanto_mobile_shell.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Figma: `profile page-1` (447:450) — member profile tab.
class MemberProfilePage extends StatefulWidget {
  const MemberProfilePage({
    super.key,
    required this.memberName,
    required this.memberInitial,
    required this.onLogout,
    this.onProfileUpdated,
  });

  final String memberName;
  final String memberInitial;
  final Future<void> Function() onLogout;
  final VoidCallback? onProfileUpdated;

  @override
  State<MemberProfilePage> createState() => _MemberProfilePageState();
}

class _MemberProfilePageState extends State<MemberProfilePage> {
  final _profilePrefs = Get.find<ProfileLocalPrefsService>();

  String _email = 'alexadams@gmail.com';
  String _phone = '+91 9500999999';
  String _branch = 'Cape Town , New York';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final seed = await _profilePrefs.getProfileSeed();
    if (!mounted) return;
    setState(() {
      _email = seed.email.isNotEmpty ? seed.email : 'alexadams@gmail.com';
      _phone = seed.phone.isNotEmpty ? seed.phone : '+91 9500999999';
      _branch = seed.gymName.isNotEmpty ? seed.gymName : 'Cape Town , New York';
    });
  }

  Future<void> _openPersonalInfo() async {
    final saved = await Get.to<bool>(
      () => MemberPersonalInfoPage(avatarLetter: widget.memberInitial),
    );
    if (saved == true) {
      widget.onProfileUpdated?.call();
      await _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final layout = MemberFigmaLayout(context);
    final padding = azantoContentPadding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        padding.left,
        layout.s(8),
        padding.right,
        layout.s(120),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileAvatarSection(
            layout: layout,
            memberInitial: widget.memberInitial,
            onEditTap: _openPersonalInfo,
          ),
          SizedBox(height: layout.s(10)),
          Text(
            widget.memberName,
            textAlign: TextAlign.center,
            style: layout.montserrat(
              size: 22,
              weight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: layout.s(10)),
          const _MembershipIdBar(membershipId: '19248'),
          SizedBox(height: layout.s(12)),
          const _ProfileMetricsRow(),
          SizedBox(height: layout.s(18)),
          _SectionLabel(layout: layout, title: 'Personal Details'),
          SizedBox(height: layout.s(10)),
          _PersonalDetailsCard(
            layout: layout,
            email: _email,
            phone: _phone,
            branch: _branch,
          ),
          SizedBox(height: layout.s(22)),
          _SectionLabel(layout: layout, title: 'Preference & Support'),
          SizedBox(height: layout.s(10)),
          _PreferenceRow(
            layout: layout,
            icon: LucideIcons.calendarDays,
            label: 'Attendance History',
            onTap: () => Get.snackbar(
              'Attendance',
              'Your attendance history will appear here.',
              snackPosition: SnackPosition.TOP,
            ),
          ),
          SizedBox(height: layout.s(7)),
          _PreferenceRow(
            layout: layout,
            icon: LucideIcons.bell,
            label: 'Notification Settings',
            onTap: () => Get.to<void>(() => const MemberSettingsPage()),
          ),
          SizedBox(height: layout.s(7)),
          _PreferenceRow(
            layout: layout,
            icon: LucideIcons.circleHelp,
            label: 'Help & support',
            onTap: () => Get.snackbar(
              'Support',
              'Contact support@azanto.com for help.',
              snackPosition: SnackPosition.TOP,
            ),
          ),
          SizedBox(height: layout.s(7)),
          _LogoutRow(
            layout: layout,
            onTap: () async => widget.onLogout(),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatarSection extends StatelessWidget {
  const _ProfileAvatarSection({
    required this.layout,
    required this.memberInitial,
    required this.onEditTap,
  });

  final MemberFigmaLayout layout;
  final String memberInitial;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final avatarSize = layout.s(98);
    final editSize = layout.s(22);

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: MemberFigmaColors.accent, width: 3),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF6F6F6), Color(0xFFDBDBDB)],
              ),
            ),
            child: Center(
              child: Text(
                memberInitial,
                style: layout.montserrat(
                  size: 36,
                  weight: FontWeight.w700,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
            ),
          ),
          Positioned(
            right: layout.s(2),
            bottom: layout.s(2),
            child: Material(
              color: MemberFigmaColors.accent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onEditTap,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: editSize,
                  height: editSize,
                  child: Icon(
                    LucideIcons.pencil,
                    size: layout.s(12),
                    color: MemberFigmaColors.accentDarkText,
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

class _MembershipIdBar extends StatelessWidget {
  const _MembershipIdBar({required this.membershipId});

  final String membershipId;

  @override
  Widget build(BuildContext context) {
    final layout = MemberFigmaLayout(context);

    return Center(
      child: Container(
        width: layout.s(236),
        height: layout.s(35),
        padding: layout.padLTRB(12, 0, 12, 0),
        decoration: BoxDecoration(
          color: const Color(0xFF353535),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Text(
              'MEMBERSHIP ID :',
              style: layout.montserrat(
                size: 11,
                weight: FontWeight.w600,
                color: MemberFigmaColors.label,
                letterSpacing: 0.4,
              ),
            ),
            const Spacer(),
            Text(
              membershipId,
              style: layout.montserrat(
                size: 11,
                weight: FontWeight.w700,
                color: MemberFigmaColors.accent,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMetricsRow extends StatelessWidget {
  const _ProfileMetricsRow();

  @override
  Widget build(BuildContext context) {
    final layout = MemberFigmaLayout(context);

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            layout: layout,
            label: 'WEIGHT',
            value: '75',
            unit: 'Kg',
          ),
        ),
        SizedBox(width: layout.s(8)),
        Expanded(
          child: _MetricCard(
            layout: layout,
            label: 'HEIGHT',
            value: '189',
            unit: 'cm',
          ),
        ),
        SizedBox(width: layout.s(8)),
        Expanded(
          child: _MetricCard(
            layout: layout,
            label: 'BMI',
            value: '24',
            subtitle: 'Normal',
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.layout,
    required this.label,
    required this.value,
    this.unit,
    this.subtitle,
  });

  final MemberFigmaLayout layout;
  final String label;
  final String value;
  final String? unit;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: layout.s(66),
      padding: layout.padLTRB(8, 10, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: layout.montserrat(
              size: 10,
              weight: FontWeight.w700,
              color: MemberFigmaColors.label,
              letterSpacing: 0.6,
            ),
          ),
          SizedBox(height: layout.s(4)),
          if (subtitle != null) ...[
            Text(
              value,
              style: layout.montserrat(
                size: 16,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              subtitle!,
              style: layout.montserrat(
                size: 8,
                weight: FontWeight.w500,
                color: AppColors.brandGreen,
              ),
            ),
          ] else
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: layout.montserrat(
                      size: 16,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (unit != null)
                    TextSpan(
                      text: ' $unit',
                      style: layout.montserrat(
                        size: 11,
                        weight: FontWeight.w500,
                        color: MemberFigmaColors.label,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.layout, required this.title});

  final MemberFigmaLayout layout;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: layout.s(4)),
      child: Text(
        title,
        style: layout.montserrat(
          size: 11,
          weight: FontWeight.w700,
          color: MemberFigmaColors.label,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _PersonalDetailsCard extends StatelessWidget {
  const _PersonalDetailsCard({
    required this.layout,
    required this.email,
    required this.phone,
    required this.branch,
  });

  final MemberFigmaLayout layout;
  final String email;
  final String phone;
  final String branch;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MemberFigmaColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MemberFigmaColors.cardBorder),
      ),
      child: Column(
        children: [
          _PersonalDetailRow(
            layout: layout,
            icon: LucideIcons.mail,
            label: 'Email',
            value: email,
            showDivider: true,
          ),
          _PersonalDetailRow(
            layout: layout,
            icon: LucideIcons.phone,
            label: 'Phone',
            value: phone,
            showDivider: true,
          ),
          _PersonalDetailRow(
            layout: layout,
            icon: LucideIcons.mapPin,
            label: 'Branch',
            value: branch,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _PersonalDetailRow extends StatelessWidget {
  const _PersonalDetailRow({
    required this.layout,
    required this.icon,
    required this.label,
    required this.value,
    required this.showDivider,
  });

  final MemberFigmaLayout layout;
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: layout.padLTRB(10, 12, 12, 12),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(layout: layout, icon: icon),
          SizedBox(width: layout.s(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: layout.montserrat(
                    size: 11,
                    weight: FontWeight.w600,
                    color: MemberFigmaColors.labelMuted,
                  ),
                ),
                SizedBox(height: layout.s(2)),
                Text(
                  value,
                  style: layout.montserrat(
                    size: 14,
                    weight: FontWeight.w600,
                    color: MemberFigmaColors.textPrimary,
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

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.layout,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final MemberFigmaLayout layout;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MemberFigmaColors.cardBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: layout.s(64),
          padding: layout.padLTRB(10, 0, 14, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: MemberFigmaColors.cardBorder),
          ),
          child: Row(
            children: [
              _IconBadge(layout: layout, icon: icon),
              SizedBox(width: layout.s(12)),
              Expanded(
                child: Text(
                  label,
                  style: layout.montserrat(
                    size: 14,
                    weight: FontWeight.w600,
                    color: MemberFigmaColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: MemberFigmaColors.label,
                size: layout.s(20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutRow extends StatelessWidget {
  const _LogoutRow({required this.layout, required this.onTap});

  final MemberFigmaLayout layout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MemberFigmaColors.cardBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: layout.s(64),
          padding: layout.padLTRB(10, 0, 14, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: MemberFigmaColors.cardBorder),
          ),
          child: Row(
            children: [
              _IconBadge(
                layout: layout,
                icon: LucideIcons.logOut,
                iconColor: const Color(0xFFFF6B5A),
              ),
              SizedBox(width: layout.s(12)),
              Expanded(
                child: Text(
                  'Logout',
                  style: layout.montserrat(
                    size: 14,
                    weight: FontWeight.w600,
                    color: const Color(0xFFFF6B5A),
                  ),
                ),
              ),
              Icon(
                Icons.logout_rounded,
                color: const Color(0xFFFF6B5A).withValues(alpha: 0.85),
                size: layout.s(16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.layout,
    required this.icon,
    this.iconColor,
  });

  final MemberFigmaLayout layout;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: layout.s(40),
      height: layout.s(40),
      decoration: BoxDecoration(
        color: MemberFigmaColors.cardIconCircle,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: layout.s(18),
        color: iconColor ?? Colors.white,
      ),
    );
  }
}
