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
      padding: EdgeInsets.zero,
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
            Row(
              children: [
                Expanded(flex: 7, child: _CompactSearchCard(
                  controller: _searchController,
                  isSearching: _isSearching,
                  onSearchTap: _searchMember,
                )),
                SizedBox(width: 8.w),
                Expanded(flex: 3, child: _CompactAddButton(onTap: widget.onAddMemberTap)),
              ],
            ),
            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }
}

class _CompactSearchCard extends StatelessWidget {
  const _CompactSearchCard({
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
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF202229),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF33363E)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
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
                hintText: 'Enter mobile number',
                hintStyle: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.46),
                  fontSize: 14.sp,
                ),
                // prefixIcon removed for cleaner look
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.brandGreen),
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: isSearching ? null : onSearchTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandGreen,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: isSearching
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
                  )
                : const Icon(Icons.search_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _CompactAddButton extends StatelessWidget {
  const _CompactAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColors.brandGreen,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandGreen.withValues(alpha: 0.3),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Icon(
          Icons.add_circle_outline_rounded,
          color: Colors.black,
          size: 28.sp,
        ),
      ),
    );
  }
}
