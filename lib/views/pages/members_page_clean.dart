import 'package:azanto/Services/login_services.dart';
import 'package:azanto/core/responsive/responsive.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key, required this.onAddMemberTap});

  final VoidCallback onAddMemberTap;

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final TextEditingController _searchController = TextEditingController();
  final ApiServices _apiServices = ApiServices();

  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchMember() async {
    final phone = _searchController.text.trim();

    if (phone.length != 10) {
      _showMessage('Enter a valid 10-digit mobile number.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSearching = true);

    final result = await _apiServices.searchMemberByPhone(phone: phone);

    if (!mounted) return;

    setState(() => _isSearching = false);

    // For clean UI, show result in snackbar instead of card
    if (result != null) {
      final memberName = _findString(result, const ['name', 'full_name', 'fullName']);
      _showMessage(memberName != null ? 'Found: $memberName' : 'Member found');
    } else {
      _showMessage('No member found for $phone');
    }
  }

  String? _findString(Map<String, dynamic>? source, List<String> keys) {
    if (source == null) return null;
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 118.h + bottomPadding),
      child: MaxWidthContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Members',
              style: GoogleFonts.poppins(
                fontSize: 34.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Manage attendance, plans and renewals for your members.',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: Colors.white.withValues(alpha: 0.66),
              ),
            ),
            SizedBox(height: 18.h),
            _SearchMemberCard(
              controller: _searchController,
              isSearching: _isSearching,
              onSearchTap: _searchMember,
            ),
            SizedBox(height: 18.h),
            _AddMemberButton(onTap: widget.onAddMemberTap),
            SizedBox(height: 50.h), // Extra space for clean empty state
          ],
        ),
      ),
    );
  }
}

class _SearchMemberCard extends StatelessWidget {
  const _SearchMemberCard({
    required this.controller,
    required this.isSearching,
    required this.onSearchTap,
  });

  final TextEditingController controller;
  final bool isSearching;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFF202229),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF33363E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Member',
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Find a member quickly using their registered mobile number.',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.white.withValues(alpha: 0.66),
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.search,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            onSubmitted: (_) => onSearchTap(),
            decoration: InputDecoration(
              hintText: 'Enter 10-digit mobile number',
              hintStyle: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.46),
                fontSize: 14.sp,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: AppColors.brandGreen),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSearching ? null : onSearchTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
              child: isSearching
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(
                      'Search',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMemberButton extends StatelessWidget {
  const _AddMemberButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7BE625), Color(0xFF26D2F4)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandGreen.withValues(alpha: 0.5),
              blurRadius: 16.r,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Add Member',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

