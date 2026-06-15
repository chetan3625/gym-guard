import 'dart:typed_data';

import 'package:azanto/Memberside/View/member_attendance_history_page.dart';
import 'package:azanto/Memberside/View/member_personal_info_page.dart';
import 'package:azanto/Memberside/View/member_settings_page.dart';
import 'package:azanto/Memberside/constants/member_figma_layout.dart';
import 'package:azanto/Services/profile_local_prefs_service.dart';
import 'package:azanto/Services/profile_service.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/views/widgets/azanto_mobile_shell.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    this.refreshTrigger = 0,
  });

  final String memberName;
  final String memberInitial;
  final Future<void> Function() onLogout;
  final VoidCallback? onProfileUpdated;
  final int refreshTrigger;

  @override
  State<MemberProfilePage> createState() => _MemberProfilePageState();
}

class _MemberProfilePageState extends State<MemberProfilePage> {
  final _profilePrefs = Get.find<ProfileLocalPrefsService>();
  final _profileService = Get.isRegistered<ProfileService>()
      ? Get.find<ProfileService>()
      : ProfileService();

  String _email = 'alexadams@gmail.com';
  String _phone = '+91 9500999999';
  String _branch = 'Cape Town , New York';
  Uint8List? _avatarBytes;
  String? _avatarUrl;

  String _profileId = '19248';
  num _weight = 0;
  num _height = 0;
  String _memberName = '';
  String _memberInitial = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadAvatar();
  }

  @override
  void didUpdateWidget(covariant MemberProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTrigger != widget.refreshTrigger) {
      _loadProfile();
      _loadAvatar();
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      await _profilePrefs.saveProfileSeed(
        firstName: profile.firstName,
        lastName: profile.lastName,
        phone: profile.phone,
        email: profile.email,
        dob: profile.dob,
        gender: profile.gender,
      );

      if (!mounted) return;
      setState(() {
        _email = profile.email.isNotEmpty ? profile.email : 'alexadams@gmail.com';
        _phone = profile.phone.isNotEmpty ? profile.phone : '+91 9500999999';
        _profileId = profile.id.isNotEmpty ? profile.id : '19248';
        _weight = profile.weight;
        _height = profile.height;

        final resolvedName = [
          profile.firstName.trim(),
          profile.lastName.trim(),
        ].where((part) => part.isNotEmpty).join(' ');
        _memberName = resolvedName.isEmpty ? widget.memberName : resolvedName;
        _memberInitial = _memberName.isNotEmpty 
            ? _memberName.substring(0, 1).toUpperCase() 
            : widget.memberInitial;
      });
    } catch (e) {
      debugPrint('Error fetching member profile inside MemberProfilePage: $e');
      final seed = await _profilePrefs.getProfileSeed();
      if (!mounted) return;
      setState(() {
        _email = seed.email.isNotEmpty ? seed.email : 'alexadams@gmail.com';
        _phone = seed.phone.isNotEmpty ? seed.phone : '+91 9500999999';

        final resolvedName = [
          seed.firstName.trim(),
          seed.lastName.trim(),
        ].where((part) => part.isNotEmpty).join(' ');
        _memberName = resolvedName.isEmpty ? widget.memberName : resolvedName;
        _memberInitial = _memberName.isNotEmpty 
            ? _memberName.substring(0, 1).toUpperCase() 
            : widget.memberInitial;
      });
    } finally {
      final seed = await _profilePrefs.getProfileSeed();
      if (mounted) {
        setState(() {
          _branch = seed.gymName.isNotEmpty ? seed.gymName : 'Cape Town , New York';
        });
      }
    }
  }

  Future<void> _loadAvatar() async {
    try {
      final avatar = await _profileService.getAvatar();
      if (!mounted || !avatar.hasData) return;
      setState(() {
        _avatarBytes = avatar.bytes;
        _avatarUrl = avatar.url?.trim();
      });
    } catch (_) {
      // Keep showing initials if avatar API is unavailable.
    }
  }

  Future<void> _updateProfileField(String fieldKey, dynamic value) async {
    final profile = await _profileService.getProfile();
    final payload = <String, dynamic>{
      'first_name': profile.firstName,
      'last_name': profile.lastName,
      'quote': profile.quote,
      'gender': profile.gender,
      'dob': profile.dob,
      'height': profile.height,
      'weight': profile.weight,
      'phone': profile.phone,
      'email': profile.email,
    };
    payload[fieldKey] = value;
    final updated = await _profileService.updateProfile(payload);
    await _profilePrefs.saveProfileSeed(
      firstName: updated.firstName,
      lastName: updated.lastName,
      phone: updated.phone,
      email: updated.email,
      dob: updated.dob,
      gender: updated.gender,
    );
    await _loadProfile();
    widget.onProfileUpdated?.call();
  }

  Future<void> _showAddDialog({
    required String title,
    required String labelText,
    required String currentValue,
    required TextInputType keyboardType,
    required Future<void> Function(String newValue) onSave,
  }) async {
    final controller = TextEditingController(text: currentValue);
    final formKey = GlobalKey<FormState>();

    await Get.dialog<void>(
      AlertDialog(
        backgroundColor: MemberFigmaColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: MemberFigmaColors.cardBorder),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: const TextStyle(color: MemberFigmaColors.label),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: MemberFigmaColors.cardIconCircle),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: MemberFigmaColors.accent),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter a value';
              }
              if (keyboardType == TextInputType.number) {
                if (num.tryParse(val.trim()) == null) {
                  return 'Please enter a valid number';
                }
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MemberFigmaColors.accent,
              foregroundColor: MemberFigmaColors.accentDarkText,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                Get.back<void>();
                try {
                  await onSave(controller.text.trim());
                  Get.snackbar(
                    'Success',
                    '$title updated successfully.',
                    backgroundColor: MemberFigmaColors.accent.withValues(alpha: 0.92),
                    colorText: MemberFigmaColors.accentDarkText,
                  );
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to update: $e',
                    snackPosition: SnackPosition.TOP,
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _openPersonalInfo() async {
    final saved = await Get.to<bool>(
      () => MemberPersonalInfoPage(avatarLetter: _memberInitial.isNotEmpty ? _memberInitial : widget.memberInitial),
    );
    if (saved == true) {
      widget.onProfileUpdated?.call();
      await _loadProfile();
    }
    await _loadAvatar();
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
            memberInitial: _memberInitial.isNotEmpty ? _memberInitial : widget.memberInitial,
            avatarBytes: _avatarBytes,
            avatarUrl: _avatarUrl,
            onEditTap: _openPersonalInfo,
          ),
          SizedBox(height: layout.s(10)),
          Text(
            _memberName.isNotEmpty ? _memberName : widget.memberName,
            textAlign: TextAlign.center,
            style: layout.montserrat(
              size: 22,
              weight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: layout.s(10)),
          _MembershipIdBar(membershipId: _profileId),
          SizedBox(height: layout.s(12)),
          _ProfileMetricsRow(
            weight: _weight,
            height: _height,
            onWeightTap: () {
              _showAddDialog(
                title: _weight > 0 ? 'Edit Weight' : 'Add Weight',
                labelText: 'Weight (Kg)',
                currentValue: _weight > 0 ? _weight.toString() : '',
                keyboardType: TextInputType.number,
                onSave: (val) => _updateProfileField('weight', num.parse(val)),
              );
            },
            onHeightTap: () {
              _showAddDialog(
                title: _height > 0 ? 'Edit Height' : 'Add Height',
                labelText: 'Height (cm)',
                currentValue: _height > 0 ? _height.toString() : '',
                keyboardType: TextInputType.number,
                onSave: (val) => _updateProfileField('height', num.parse(val)),
              );
            },
          ),
          SizedBox(height: layout.s(18)),
          _SectionLabel(layout: layout, title: 'Personal Details'),
          SizedBox(height: layout.s(10)),
          _PersonalDetailsCard(
            layout: layout,
            email: _email,
            phone: _phone,
            branch: _branch,
            onEmailTap: () {
              _showAddDialog(
                title: (_email.isNotEmpty && _email != 'alexadams@gmail.com') ? 'Edit Email' : 'Add Email',
                labelText: 'Email Address',
                currentValue: (_email.isNotEmpty && _email != 'alexadams@gmail.com') ? _email : '',
                keyboardType: TextInputType.emailAddress,
                onSave: (val) => _updateProfileField('email', val),
              );
            },
          ),
          SizedBox(height: layout.s(22)),
          _SectionLabel(layout: layout, title: 'Preference & Support'),
          SizedBox(height: layout.s(10)),
          _PreferenceRow(
            layout: layout,
            icon: LucideIcons.calendarDays,
            label: 'Attendance History',
            onTap: () => Get.to<void>(
              () => const MemberAttendanceHistoryPage(),
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
    required this.avatarBytes,
    required this.avatarUrl,
    required this.onEditTap,
  });

  final MemberFigmaLayout layout;
  final String memberInitial;
  final Uint8List? avatarBytes;
  final String? avatarUrl;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final avatarSize = layout.s(98);
    final editSize = layout.s(22);

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: Container(
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
              child: _AvatarImage(
                avatarBytes: avatarBytes,
                avatarUrl: avatarUrl,
                fallback: Center(
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

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({
    required this.avatarBytes,
    required this.avatarUrl,
    required this.fallback,
  });

  final Uint8List? avatarBytes;
  final String? avatarUrl;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final imageUrl = avatarUrl?.trim() ?? '';
    if (avatarBytes != null) {
      return Image.memory(avatarBytes!, fit: BoxFit.cover);
    }
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    return fallback;
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
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  membershipId,
                  style: layout.montserrat(
                    size: 11,
                    weight: FontWeight.w700,
                    color: MemberFigmaColors.accent,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMetricsRow extends StatelessWidget {
  const _ProfileMetricsRow({
    required this.weight,
    required this.height,
    this.onWeightTap,
    this.onHeightTap,
  });

  final num weight;
  final num height;
  final VoidCallback? onWeightTap;
  final VoidCallback? onHeightTap;

  String _calculateBmi() {
    if (weight <= 0 || height <= 0) return '-';
    final heightInMeters = height / 100.0;
    final bmi = weight / (heightInMeters * heightInMeters);
    return bmi.toStringAsFixed(1);
  }

  String _getBmiCategory() {
    if (weight <= 0 || height <= 0) return 'N/A';
    final heightInMeters = height / 100.0;
    final bmi = weight / (heightInMeters * heightInMeters);
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    final layout = MemberFigmaLayout(context);

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            layout: layout,
            label: 'WEIGHT',
            value: weight > 0 ? weight.toString() : 'Add',
            unit: weight > 0 ? 'Kg' : null,
            onTap: onWeightTap,
          ),
        ),
        SizedBox(width: layout.s(8)),
        Expanded(
          child: _MetricCard(
            layout: layout,
            label: 'HEIGHT',
            value: height > 0 ? height.toString() : 'Add',
            unit: height > 0 ? 'cm' : null,
            onTap: onHeightTap,
          ),
        ),
        SizedBox(width: layout.s(8)),
        Expanded(
          child: _MetricCard(
            layout: layout,
            label: 'BMI',
            value: _calculateBmi(),
            subtitle: _getBmiCategory(),
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
    this.onTap,
  });

  final MemberFigmaLayout layout;
  final String label;
  final String value;
  final String? unit;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isAction = value == 'Add';

    final cardContent = Container(
      height: layout.s(66),
      padding: layout.padLTRB(8, 10, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAction ? MemberFigmaColors.accent.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.12),
        ),
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
                      color: isAction ? MemberFigmaColors.accent : Colors.white,
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

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: cardContent,
        ),
      );
    }
    return cardContent;
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
    this.onEmailTap,
  });

  final MemberFigmaLayout layout;
  final String email;
  final String phone;
  final String branch;
  final VoidCallback? onEmailTap;

  @override
  Widget build(BuildContext context) {
    final isDummyEmail = email.isEmpty || email == 'alexadams@gmail.com';

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
            value: isDummyEmail ? 'Add Email' : email,
            showDivider: true,
            onTap: onEmailTap,
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
    this.onTap,
  });

  final MemberFigmaLayout layout;
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isAction = value == 'Add Email';

    final rowContent = Container(
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
                    color: isAction ? MemberFigmaColors.accent : MemberFigmaColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: rowContent,
        ),
      );
    }
    return rowContent;
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
