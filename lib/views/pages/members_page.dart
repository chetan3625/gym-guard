import 'package:azanto/Services/branch_service.dart';
import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/member_service.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/core/responsive/responsive.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/models/branch_member_model.dart';
import 'package:azanto/views/pages/member_profile_details_page.dart';
import 'package:azanto/views/pages/member_health_page.dart';
import 'package:azanto/views/pages/gym_qr_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key, required this.onAddMemberTap});

  final VoidCallback onAddMemberTap;

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  static const List<String> _filters = <String>[
    'All',
    'Active',
    'Expired',
    'Pending',
  ];

  final TextEditingController _searchController = TextEditingController();
  late final SessionService _sessionService;
  late final MemberService _memberService;
  late final BranchService _branchService;

  List<BranchMemberModel> _members = <BranchMemberModel>[];
  BranchMemberModel? _selectedMember;
  bool _loading = false;
  String? _loadError;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _sessionService = Get.isRegistered<SessionService>()
        ? Get.find<SessionService>()
        : SessionService();
    _memberService = Get.isRegistered<MemberService>()
        ? Get.find<MemberService>()
        : MemberService(sessionService: _sessionService);
    _branchService = Get.isRegistered<BranchService>()
        ? Get.find<BranchService>()
        : BranchService(sessionService: _sessionService);
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMembers());
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<BranchMemberModel> get _visibleMembers {
    final query = _searchController.text;
    return _members
        .where((member) => member.matchesFilter(_selectedFilter))
        .where((member) => member.matchesSearch(query))
        .toList(growable: false);
  }

  Future<void> _loadMembers() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final branchId = await _resolveBranchId();
      if (branchId == null || branchId.isEmpty) {
        throw ApiException('No branch found for this gym.');
      }

      final members = await _memberService.getAllBranchMembers(
        branchId: branchId,
      );

      if (!mounted) return;
      setState(() => _members = members);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e.detailMessage);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = 'Unable to load members right now.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<String?> _resolveBranchId() async {
    final storedBranchId = _clean(_sessionService.branchId);
    if (storedBranchId != null) return storedBranchId;

    final gymId = _clean(_sessionService.gymId);
    if (gymId == null) return null;

    try {
      final branches = await _branchService.getAllBranches(gymId: gymId);
      if (branches.isEmpty) return null;

      final branchId = _clean(branches.first.branchId);
      if (branchId != null) {
        await _sessionService.setBranchId(branchId);
      }
      return branchId;
    } catch (e) {
      debugPrint('Unable to resolve branch id: $e');
      return null;
    }
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  void _selectFilter(String filter) {
    if (_selectedFilter == filter) return;
    setState(() => _selectedFilter = filter);
  }

  void _openMemberProfile(BranchMemberModel member) {
    setState(() => _selectedMember = member);
  }

  void _closeMemberProfile() {
    setState(() => _selectedMember = null);
  }

  String? _clean(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final visibleMembers = _visibleMembers;
    final selectedMember = _selectedMember;

    if (selectedMember != null) {
      return MemberProfileDetailsPage(
        member: selectedMember,
        onBack: _closeMemberProfile,
      );
    }

    return RefreshIndicator(
      color: AppColors.brandGreen,
      backgroundColor: const Color(0xFF262626),
      onRefresh: _loadMembers,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 118.h + bottomPadding),
        child: MaxWidthContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_members.length} Total Members',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.84),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 14.h),
              _MembersSearchField(controller: _searchController),
              SizedBox(height: 14.h),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => Get.to(() => const GymQrPage()),
                  icon: const Icon(Icons.qr_code_rounded),
                  label: const Text('Show gym registration QR'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Get.to(() => const MemberHealthPage()),
                  icon: const Icon(Icons.favorite_outline_rounded, size: 18),
                  label: Text(
                    'Member health & follow-up',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brandGreen,
                    side: BorderSide(
                      color: AppColors.brandGreen.withValues(alpha: 0.55),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    for (final filter in _filters) ...[
                      _StatusFilterChip(
                        label: filter,
                        isSelected: _selectedFilter == filter,
                        onTap: () => _selectFilter(filter),
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              if (_loading)
                const _MembersLoadingState()
              else if (_loadError != null)
                _MembersMessageState(
                  icon: Icons.error_outline_rounded,
                  title: 'Could not load members',
                  message: _loadError!,
                  buttonLabel: 'Retry',
                  onButtonTap: _loadMembers,
                )
              else if (_members.isEmpty)
                _MembersMessageState(
                  icon: Icons.group_outlined,
                  title: 'No members yet',
                  message: 'Members added to this branch will appear here.',
                  buttonLabel: 'Add Member',
                  onButtonTap: widget.onAddMemberTap,
                )
              else if (visibleMembers.isEmpty)
                const _MembersMessageState(
                  icon: Icons.search_off_rounded,
                  title: 'No matching members',
                  message: 'Try a different search or status filter.',
                )
              else
                Column(
                  children: [
                    for (final member in visibleMembers) ...[
                      _BranchMemberTile(
                        member: member,
                        onTap: () => _openMemberProfile(member),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MembersSearchField extends StatelessWidget {
  const _MembersSearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 39.h,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: 'Search by name, phone num...',
          hintStyle: GoogleFonts.poppins(
            color: const Color(0xFF9B9B9B),
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: const Color(0xFF9B9B9B),
            size: 23.sp,
          ),
          filled: true,
          fillColor: const Color(0xFF2E2E2E),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.r),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.r),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.r),
            borderSide: const BorderSide(color: AppColors.brandGreen),
          ),
        ),
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 33.h,
        padding: EdgeInsets.symmetric(horizontal: 17.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandGreen : const Color(0xFF242424),
          borderRadius: BorderRadius.circular(17.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.brandGreen.withValues(alpha: 0.22),
                    blurRadius: 12.r,
                    offset: Offset(0, 5.h),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.black : const Color(0xFF9E9E9E),
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _BranchMemberTile extends StatelessWidget {
  const _BranchMemberTile({required this.member, required this.onTap});

  final BranchMemberModel member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.31),
            blurRadius: 12.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 9.h,
          ),
          leading: _MemberAvatar(member: member),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.effectiveName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 7.h),
              _MemberStatusBadge(status: member.statusLabel),
              SizedBox(height: 8.h),
              Text(
                _memberSubtitle(member),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF9E9E9E),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFFA8A8A8),
            size: 28.sp,
          ),
        ),
      ),
    );
  }

  String _memberSubtitle(BranchMemberModel member) {
    final planName = member.planName?.trim() ?? '';
    if (planName.isNotEmpty) return planName;

    final joinedAt = member.joinedAt;
    if (joinedAt != null) {
      return 'Joined ${_formatDate(joinedAt)}';
    }

    final shortId = member.shortUserId;
    if (shortId.isNotEmpty) return 'User ID $shortId';
    return 'Branch member';
  }

  String _formatDate(DateTime date) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = date.toLocal();
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member});

  final BranchMemberModel member;

  static const List<Color> _palette = <Color>[
    Color(0xFF168BD7),
    Color(0xFFC8680D),
    Color(0xFFA71195),
    Color(0xFF351079),
    Color(0xFF007E7A),
    Color(0xFFB42B2B),
  ];

  @override
  Widget build(BuildContext context) {
    final avatarUrl = member.avatarUrl?.trim() ?? '';
    final initial = _initialFor(member.effectiveName);

    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.4),
      ),
      child: CircleAvatar(
        backgroundColor: _colorFor(member),
        backgroundImage: avatarUrl.isEmpty ? null : NetworkImage(avatarUrl),
        child: avatarUrl.isEmpty
            ? Text(
                initial,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
    );
  }

  Color _colorFor(BranchMemberModel member) {
    final seed = '${member.userId}${member.id}${member.effectiveName}';
    final hash = seed.codeUnits.fold<int>(0, (total, code) => total + code);
    return _palette[hash % _palette.length];
  }

  String _initialFor(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return 'M';
    return normalized.substring(0, 1).toUpperCase();
  }
}

class _MemberStatusBadge extends StatelessWidget {
  const _MemberStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final accent = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: accent, width: 1),
        color: Colors.transparent,
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: accent,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          height: 1.1,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'active':
        return AppColors.brandGreen;
      case 'expired':
        return const Color(0xFFFF2323);
      case 'pending':
        return const Color(0xFFFFFF00);
      case 'inactive':
        return const Color(0xFFB0B0B0);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

class _MembersLoadingState extends StatelessWidget {
  const _MembersLoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.brandGreen),
      ),
    );
  }
}

class _MembersMessageState extends StatelessWidget {
  const _MembersMessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onButtonTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;

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
          Icon(icon, color: Colors.white70, size: 32.sp),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF9E9E9E),
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (buttonLabel != null && onButtonTap != null) ...[
            SizedBox(height: 16.h),
            SizedBox(
              height: 42.h,
              child: ElevatedButton(
                onPressed: onButtonTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  buttonLabel!,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
