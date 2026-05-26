import 'package:azanto/Memberside/View/member_personal_info_page.dart';
import 'package:azanto/Memberside/View/member_plan_upgrade_page.dart';
import 'package:azanto/Services/profile_local_prefs_service.dart';
import 'package:azanto/Memberside/constants/Common_widgets/member_figma_page_shell.dart';
import 'package:azanto/Memberside/constants/member_figma_layout.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_manager.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Figma: `settings page` (447:841 / 359:514).
class MemberSettingsPage extends StatefulWidget {
  const MemberSettingsPage({super.key});

  @override
  State<MemberSettingsPage> createState() => _MemberSettingsPageState();
}

class _MemberSettingsPageState extends State<MemberSettingsPage> {
  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _workoutReminders = false;
  bool _biometricLogin = true;
  bool _darkMode = true;
  String _language = 'English';
  String _units = 'Metric';

  Future<void> _logout() async {
    await TokenRefreshManager.clearState();
    await Get.find<SessionService>().clearSession();
    Get.offAllNamed(AppRoutes.roleSelection);
  }

  void _confirmDeleteAccount() {
    Get.dialog<void>(
      AlertDialog(
        backgroundColor: MemberFigmaColors.cardBg,
        title: Text(
          'Delete account?',
          style: MemberFigmaLayout(context).montserrat(
            size: 16,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          'This action cannot be undone. Your membership data will be permanently removed.',
          style: MemberFigmaLayout(context).montserrat(
            size: 13,
            color: MemberFigmaColors.label,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back<void>();
              Get.snackbar(
                'Request received',
                'Our team will contact you to complete account deletion.',
                snackPosition: SnackPosition.TOP,
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFF6B5A)),
            ),
          ),
        ],
      ),
    );
  }

  void _pickLanguage() {
    const options = ['English', 'Spanish', 'French', 'German'];
    Get.bottomSheet<void>(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: MemberFigmaColors.formBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (lang) => ListTile(
                  title: Text(
                    lang,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: _language == lang
                      ? const Icon(
                          Icons.check,
                          color: MemberFigmaColors.accent,
                        )
                      : null,
                  onTap: () {
                    setState(() => _language = lang);
                    Get.back<void>();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = MemberFigmaLayout(context);

    return MemberFigmaPageShell(
      bottomNavIndex: 4,
      showSettings: false,
      showNotifications: true,
      gradientEnd: const Color(0xFF272727),
      body: SingleChildScrollView(
        padding: layout.padLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SettingsHeader(layout: layout),
            SizedBox(height: layout.s(24)),
            _SettingsSection(
              layout: layout,
              title: 'ACCOUNT SETTINGS',
              children: [
                _SettingsNavRow(
                  layout: layout,
                  icon: LucideIcons.user,
                  label: 'Personal Information',
                  trailingLabel: 'View',
                  onTap: () async {
                    final prefs = Get.find<ProfileLocalPrefsService>();
                    final seed = await prefs.getProfileSeed();
                    final name = [
                      seed.firstName,
                      seed.lastName,
                    ].where((p) => p.isNotEmpty).join(' ');
                    final initial = name.isNotEmpty
                        ? name.substring(0, 1).toUpperCase()
                        : 'M';
                    await Get.to<void>(
                      () => MemberPersonalInfoPage(avatarLetter: initial),
                    );
                  },
                ),
                _SettingsNavRow(
                  layout: layout,
                  icon: LucideIcons.creditCard,
                  label: 'Membership Plan',
                  trailingLabel: 'Elite Plan',
                  onTap: () => Get.to<void>(() => const MemberPlanUpgradePage()),
                ),
                _SettingsNavRow(
                  layout: layout,
                  icon: LucideIcons.wallet,
                  label: 'Payment Methods',
                  showDivider: false,
                  onTap: () => Get.snackbar(
                    'Payment Methods',
                    'Manage cards from the Payment tab.',
                    snackPosition: SnackPosition.TOP,
                  ),
                ),
              ],
            ),
            SizedBox(height: layout.s(28)),
            _SettingsSection(
              layout: layout,
              title: 'NOTIFICATIONS',
              children: [
                _SettingsToggleRow(
                  layout: layout,
                  icon: LucideIcons.bell,
                  label: 'Push Notifications',
                  value: _pushNotifications,
                  onChanged: (v) => setState(() => _pushNotifications = v),
                ),
                _SettingsToggleRow(
                  layout: layout,
                  icon: LucideIcons.mail,
                  label: 'Email Alerts',
                  value: _emailAlerts,
                  onChanged: (v) => setState(() => _emailAlerts = v),
                ),
                _SettingsToggleRow(
                  layout: layout,
                  icon: LucideIcons.dumbbell,
                  label: 'Workout Reminders',
                  value: _workoutReminders,
                  showDivider: false,
                  onChanged: (v) => setState(() => _workoutReminders = v),
                ),
              ],
            ),
            SizedBox(height: layout.s(28)),
            _SettingsSection(
              layout: layout,
              title: 'SECURITY & PRIVACY',
              children: [
                _SettingsNavRow(
                  layout: layout,
                  icon: LucideIcons.lock,
                  label: 'Change Password',
                  onTap: () => Get.snackbar(
                    'Security',
                    'Password reset link sent to your email.',
                    snackPosition: SnackPosition.TOP,
                  ),
                ),
                _SettingsToggleRow(
                  layout: layout,
                  icon: LucideIcons.fingerprint,
                  label: 'Biometric Login',
                  value: _biometricLogin,
                  onChanged: (v) => setState(() => _biometricLogin = v),
                ),
                _SettingsNavRow(
                  layout: layout,
                  icon: LucideIcons.shield,
                  label: 'Privacy Policy',
                  trailing: const _ExternalLinkIcon(),
                  onTap: () {},
                ),
                _SettingsNavRow(
                  layout: layout,
                  icon: LucideIcons.fileText,
                  label: 'Terms of Service',
                  showDivider: false,
                  trailing: const _ExternalLinkIcon(),
                  onTap: () {},
                ),
              ],
            ),
            SizedBox(height: layout.s(28)),
            _SettingsSection(
              layout: layout,
              title: 'APP SETTINGS',
              children: [
                _SettingsToggleRow(
                  layout: layout,
                  icon: LucideIcons.moon,
                  label: 'Dark Mode',
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
                _SettingsNavRow(
                  layout: layout,
                  icon: LucideIcons.languages,
                  label: 'Language',
                  trailingLabel: _language,
                  showChevronDown: true,
                  onTap: _pickLanguage,
                ),
                _SettingsNavRow(
                  layout: layout,
                  icon: LucideIcons.ruler,
                  label: 'Units',
                  trailingLabel: _units,
                  showDivider: false,
                  onTap: () {
                    setState(
                      () => _units = _units == 'Metric' ? 'Imperial' : 'Metric',
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: layout.s(28)),
            _DangerZoneSection(
              layout: layout,
              onLogout: _logout,
              onDeleteAccount: _confirmDeleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.layout});

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
            'Settings',
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.layout,
    required this.title,
    required this.children,
  });

  final MemberFigmaLayout layout;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        SizedBox(height: layout.s(12)),
        Container(
          decoration: BoxDecoration(
            color: MemberFigmaColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MemberFigmaColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: layout.s(16),
                offset: Offset(0, layout.s(6)),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsNavRow extends StatelessWidget {
  const _SettingsNavRow({
    required this.layout,
    required this.icon,
    required this.label,
    this.trailingLabel,
    this.trailing,
    this.showChevronDown = false,
    this.showDivider = true,
    this.onTap,
  });

  final MemberFigmaLayout layout;
  final IconData icon;
  final String label;
  final String? trailingLabel;
  final Widget? trailing;
  final bool showChevronDown;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: layout.s(53),
          padding: layout.padLTRB(16, 0, 16, 0),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: layout.s(18), color: MemberFigmaColors.label),
              SizedBox(width: layout.s(12)),
              Expanded(
                child: Text(
                  label,
                  style: layout.montserrat(
                    size: 13,
                    weight: FontWeight.w600,
                    color: MemberFigmaColors.textPrimary,
                  ),
                ),
              ),
              if (trailingLabel != null) ...[
                Text(
                  trailingLabel!,
                  style: layout.montserrat(
                    size: 12,
                    weight: FontWeight.w500,
                    color: MemberFigmaColors.textDim,
                  ),
                ),
                SizedBox(width: layout.s(8)),
              ],
              trailing ??
                  Icon(
                    showChevronDown
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.chevron_right_rounded,
                    color: MemberFigmaColors.label,
                    size: layout.s(18),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.layout,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  final MemberFigmaLayout layout;
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: layout.s(53),
      padding: layout.padLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: layout.s(18), color: MemberFigmaColors.label),
          SizedBox(width: layout.s(12)),
          Expanded(
            child: Text(
              label,
              style: layout.montserrat(
                size: 13,
                weight: FontWeight.w600,
                color: MemberFigmaColors.textPrimary,
              ),
            ),
          ),
          _FigmaToggle(
            value: value,
            onChanged: onChanged,
            scale: layout.scale,
          ),
        ],
      ),
    );
  }
}

class _FigmaToggle extends StatelessWidget {
  const _FigmaToggle({
    required this.value,
    required this.onChanged,
    required this.scale,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final width = 40.0 * scale;
    final height = 20.0 * scale;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        height: height,
        padding: EdgeInsets.all(2 * scale),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height),
          color: value
              ? MemberFigmaColors.accent
              : MemberFigmaColors.cardIconCircle,
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: height - 4 * scale,
          height: height - 4 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value ? MemberFigmaColors.accentDarkText : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _ExternalLinkIcon extends StatelessWidget {
  const _ExternalLinkIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.open_in_new_rounded,
      size: MemberFigmaLayout(context).s(14),
      color: MemberFigmaColors.label,
    );
  }
}

class _DangerZoneSection extends StatelessWidget {
  const _DangerZoneSection({
    required this.layout,
    required this.onLogout,
    required this.onDeleteAccount,
  });

  final MemberFigmaLayout layout;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    const dangerColor = Color(0xFFFF6B5A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: layout.s(4)),
          child: Text(
            'DANGER ZONE',
            style: layout.montserrat(
              size: 11,
              weight: FontWeight.w700,
              color: dangerColor.withValues(alpha: 0.85),
              letterSpacing: 1.1,
            ),
          ),
        ),
        SizedBox(height: layout.s(12)),
        Container(
          decoration: BoxDecoration(
            color: MemberFigmaColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: dangerColor.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: dangerColor.withValues(alpha: 0.08),
                blurRadius: layout.s(12),
                offset: Offset(0, layout.s(4)),
              ),
            ],
          ),
          child: Column(
            children: [
              _DangerRow(
                layout: layout,
                icon: LucideIcons.logOut,
                label: 'Log Out',
                onTap: onLogout,
              ),
              _DangerRow(
                layout: layout,
                icon: LucideIcons.trash2,
                label: 'Delete Account',
                showDivider: false,
                onTap: onDeleteAccount,
              ),
            ],
          ),
        ),
        SizedBox(height: layout.s(20)),
        Text(
          'Azanto Member App\nVersion 1.0.0 (Build 204)',
          textAlign: TextAlign.center,
          style: layout.montserrat(
            size: 10,
            weight: FontWeight.w500,
            color: MemberFigmaColors.textLegal,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _DangerRow extends StatelessWidget {
  const _DangerRow({
    required this.layout,
    required this.icon,
    required this.label,
    this.showDivider = true,
    required this.onTap,
  });

  final MemberFigmaLayout layout;
  final IconData icon;
  final String label;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const dangerColor = Color(0xFFFF6B5A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: layout.s(52),
          padding: layout.padLTRB(16, 0, 16, 0),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    bottom: BorderSide(
                      color: dangerColor.withValues(alpha: 0.2),
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: layout.s(17), color: dangerColor),
              SizedBox(width: layout.s(12)),
              Text(
                label,
                style: layout.montserrat(
                  size: 13,
                  weight: FontWeight.w600,
                  color: dangerColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
