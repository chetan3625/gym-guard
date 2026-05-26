import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/member_service.dart';
import 'package:azanto/core/responsive/responsive.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/models/branch_member_model.dart';
import 'package:azanto/models/member_profile_details_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberProfileDetailsPage extends StatefulWidget {
  const MemberProfileDetailsPage({
    super.key,
    required this.member,
    required this.onBack,
    this.memberService,
  });

  final BranchMemberModel member;
  final VoidCallback onBack;
  final MemberService? memberService;

  @override
  State<MemberProfileDetailsPage> createState() =>
      _MemberProfileDetailsPageState();
}

class _MemberProfileDetailsPageState extends State<MemberProfileDetailsPage> {
  late final MemberService _memberService;

  MemberProfileDetailsModel? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _memberService = widget.memberService ??
        (Get.isRegistered<MemberService>()
            ? Get.find<MemberService>()
            : MemberService());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void didUpdateWidget(covariant MemberProfileDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.member.userId != widget.member.userId) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile = await _memberService.getMemberProfile(
        userId: widget.member.userId,
      );
      if (!mounted) return;
      setState(() => _profile = profile);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.detailMessage);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Unable to load member profile right now.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 118.h + bottomPadding),
      child: MaxWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BackChip(onTap: widget.onBack),
            SizedBox(height: 18.h),
            if (_loading && _profile == null)
              const _ProfileLoadingState()
            else if (_error != null)
              _ProfileErrorState(
                message: _error!,
                onRetry: _loadProfile,
              )
            else if (_profile != null)
              _ProfileDetailsContent(
                member: widget.member,
                profile: _profile!,
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileFontSize {
  const _ProfileFontSize._();

  static const double back = 12;
  static const double badge = 10;
  static const double label = 13;
  static const double value = 13;
  static const double summaryName = 18;
  static const double avatarInitial = 20;
  static const double sectionTitle = 20;
  static const double errorTitle = 16;
  static const double button = 14;
}

class _ProfileDetailsContent extends StatelessWidget {
  const _ProfileDetailsContent({
    required this.member,
    required this.profile,
  });

  final BranchMemberModel member;
  final MemberProfileDetailsModel profile;

  @override
  Widget build(BuildContext context) {
    final planName = _valueOrFallback(member.planName, 'Not assigned');
    final statusLabel = profile.isActive ? 'Active' : 'Inactive';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileSummaryCard(
          name: profile.fullName == 'Member'
              ? member.effectiveName
              : profile.fullName,
          phone: _valueOrFallback(profile.phone, member.phone ?? 'No phone'),
          avatarUrl: profile.avatarUrl ?? member.avatarUrl,
          initials: profile.fullName == 'Member'
              ? _initialsFor(member.effectiveName)
              : profile.initials,
          statusLabel: statusLabel,
          isActive: profile.isActive,
        ),
        SizedBox(height: 22.h),
        const _SectionTitle('Contact Information'),
        SizedBox(height: 14.h),
        _ReadOnlyField(label: 'Email', value: _valueOrDash(profile.email)),
        SizedBox(height: 16.h),
        _ReadOnlyField(
          label: 'Phone Number',
          value: _valueOrDash(profile.phone),
        ),
        SizedBox(height: 16.h),
        _ReadOnlyField(
          label: 'Quote',
          value: _valueOrDash(profile.quote),
          minHeight: 68.h,
          maxLines: 3,
        ),
        SizedBox(height: 28.h),
        const _SectionTitle('Personal Information'),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(
              child: _ReadOnlyField(
                label: 'Date of Birth',
                value: _formatDate(profile.dob),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _ReadOnlyField(
                label: 'Gender',
                value: _valueOrDash(_titleCase(profile.gender)),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _ReadOnlyField(
                label: 'Height',
                value: _formatMeasure(profile.height, 'cm'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _ReadOnlyField(
                label: 'Weight',
                value: _formatMeasure(profile.weight, 'kg'),
              ),
            ),
          ],
        ),
        SizedBox(height: 28.h),
        const _SectionTitle('Payment Information'),
        SizedBox(height: 14.h),
        _InlineInfo(label: 'Current Plan', value: planName),
        SizedBox(height: 12.h),
        _ReadOnlyField(
          label: 'Member Since',
          value: _formatDate(profile.createdAt),
          trailingIcon: Icons.calendar_month_rounded,
        ),
        SizedBox(height: 16.h),
        _ReadOnlyField(
          label: 'Last Updated',
          value: _formatDate(profile.updatedAt),
          trailingIcon: Icons.calendar_month_rounded,
        ),
        SizedBox(height: 28.h),
        const _SectionTitle('Payment Status'),
        SizedBox(height: 12.h),
        _StatusPanel(
          statusLabel: statusLabel,
          description:
              profile.isActive ? 'Payment up to date' : 'Membership inactive',
          isActive: profile.isActive,
        ),
        SizedBox(height: 22.h),
        const _SectionTitle('Quick Actions'),
        SizedBox(height: 14.h),
        _QuickActionsPanel(
          phone: profile.phone,
          email: profile.email,
        ),
      ],
    );
  }

  static String _initialsFor(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'M';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  static String _valueOrDash(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? '-' : text;
  }

  static String _valueOrFallback(String? value, String fallback) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String _titleCase(String value) {
    final text = value.trim();
    if (text.isEmpty) return '';
    return text.substring(0, 1).toUpperCase() + text.substring(1).toLowerCase();
  }

  static String _formatMeasure(num? value, String unit) {
    if (value == null || value == 0) return '-';
    final text = value % 1 == 0 ? value.toInt().toString() : value.toString();
    return '$text $unit';
  }

  static String _formatDate(DateTime? value) {
    if (value == null) return '-';
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }
}

class _BackChip extends StatelessWidget {
  const _BackChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9.r),
        child: Container(
          height: 27.h,
          constraints: BoxConstraints(minWidth: 88.w),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(9.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 13.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Back',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: _ProfileFontSize.back.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.name,
    required this.phone,
    required this.avatarUrl,
    required this.initials,
    required this.statusLabel,
    required this.isActive,
  });

  final String name;
  final String phone;
  final String? avatarUrl;
  final String initials;
  final String statusLabel;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final imageUrl = avatarUrl?.trim() ?? '';
    final hasImage =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xC42D2D2D),
            Color(0xFF2F2F2F),
            Color(0xC4252525),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 12.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58.r,
            height: 58.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.brandGreen, width: 1.2),
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF262626),
              backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
              child: hasImage
                  ? null
                  : Text(
                      initials,
                      style: GoogleFonts.poppins(
                        color: AppColors.brandGreen,
                        fontSize: _ProfileFontSize.avatarInitial.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: _ProfileFontSize.summaryName.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFB5B5B5),
                    fontSize: _ProfileFontSize.value.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          _MiniStatusBadge(label: statusLabel, isActive: isActive),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: _ProfileFontSize.sectionTitle.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    this.minHeight,
    this.maxLines = 1,
    this.trailingIcon,
  });

  final String label;
  final String value;
  final double? minHeight;
  final int maxLines;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: _ProfileFontSize.label.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: minHeight ?? 32.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFF303030),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.62)),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD5D5D5),
                    fontSize: _ProfileFontSize.value.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                SizedBox(width: 8.w),
                Icon(trailingIcon, color: Colors.white, size: 18.sp),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InlineInfo extends StatelessWidget {
  const _InlineInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: _ProfileFontSize.label.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: const Color(0xFFD5D5D5),
            fontSize: _ProfileFontSize.value.sp,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.statusLabel,
    required this.description,
    required this.isActive,
  });

  final String statusLabel;
  final String description;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final accent = isActive ? AppColors.brandGreen : const Color(0xFFFFC542);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 39.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          _MiniStatusBadge(label: statusLabel, isActive: isActive),
          SizedBox(width: 18.w),
          Expanded(
            child: Text(
              description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: _ProfileFontSize.value.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Icon(
            isActive ? Icons.verified_rounded : Icons.info_outline_rounded,
            color: accent,
            size: 18.sp,
          ),
        ],
      ),
    );
  }
}

class _MiniStatusBadge extends StatelessWidget {
  const _MiniStatusBadge({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final accent = isActive ? AppColors.brandGreen : const Color(0xFFFFC542);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: accent),
        color: accent.withValues(alpha: 0.08),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: accent,
          fontSize: _ProfileFontSize.badge.sp,
          fontWeight: FontWeight.w500,
          height: 1.1,
        ),
      ),
    );
  }
}

class _QuickActionsPanel extends StatelessWidget {
  const _QuickActionsPanel({
    required this.phone,
    required this.email,
  });

  final String phone;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.call_rounded,
                  label: 'Call',
                  value: phone.trim().isEmpty ? '-' : phone,
                  onTap: phone.trim().isEmpty
                      ? null
                      : () => launchUrl(Uri(scheme: 'tel', path: phone)),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ActionTile(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: email.trim().isEmpty ? '-' : email,
                  onTap: email.trim().isEmpty
                      ? null
                      : () => launchUrl(Uri(scheme: 'mailto', path: email)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7.r),
        child: Container(
          constraints: BoxConstraints(minHeight: 69.h),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.r),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xC42D2D2D),
                Color(0xFF2F2F2F),
                Color(0xC4252525),
              ],
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: enabled ? AppColors.brandGreen : AppColors.textMuted,
                size: 24.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: _ProfileFontSize.label.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: enabled
                            ? AppColors.brandGreen
                            : const Color(0xFFB5B5B5),
                        fontSize: _ProfileFontSize.value.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileLoadingState extends StatelessWidget {
  const _ProfileLoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 82.h),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.brandGreen),
      ),
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  const _ProfileErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 22.h, 18.w, 22.h),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.white70,
            size: 32.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            'Could not load profile',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: _ProfileFontSize.errorTitle.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFFB5B5B5),
              fontSize: _ProfileFontSize.value.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 42.h,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  fontSize: _ProfileFontSize.button.sp,
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
