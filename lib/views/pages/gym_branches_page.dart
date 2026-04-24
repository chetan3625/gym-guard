import 'package:azanto/Services/branch_service.dart';
import 'package:azanto/Services/login_services.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/models/gym_branch_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GymBranchesPage extends StatefulWidget {
  const GymBranchesPage({
    super.key,
    required this.gymId,
    required this.gymName,
  });

  final String gymId;
  final String gymName;

  @override
  State<GymBranchesPage> createState() => _GymBranchesPageState();
}

class _GymBranchesPageState extends State<GymBranchesPage> {
  final BranchService _branchService = BranchService();
  late Future<List<GymBranchModel>> _branchesFuture;

  @override
  void initState() {
    super.initState();
    _branchesFuture = _branchService.getAllBranches(gymId: widget.gymId);
  }

  Future<void> _reloadBranches() async {
    final future = _branchService.getAllBranches(gymId: widget.gymId);
    setState(() {
      _branchesFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back<void>(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        title: Text(
          'Gym Branches',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FutureBuilder<List<GymBranchModel>>(
        future: _branchesFuture,
        builder: (context, snapshot) {
          final branches = snapshot.data ?? const <GymBranchModel>[];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _BranchPageErrorState(
              title: 'Unable to load branches',
              error: _resolveBranchError(snapshot.error),
              onRetryTap: _reloadBranches,
            );
          }

          return RefreshIndicator(
            onRefresh: _reloadBranches,
            color: AppColors.brandGreen,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                _BranchListHeader(
                  gymName: widget.gymName,
                  totalCount: branches.length,
                ),
                const SizedBox(height: 16),
                if (branches.isEmpty)
                  const SizedBox(
                    height: 360,
                    child: _EmptyBranchesState(),
                  )
                else
                  ...branches.map(
                    (branch) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BranchCard(
                        branch: branch,
                        onTap: () {
                          Get.to<void>(
                            () => GymBranchDetailsPage(
                              branchId: branch.branchId,
                              initialTitle: branch.name,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GymBranchDetailsPage extends StatefulWidget {
  const GymBranchDetailsPage({
    super.key,
    required this.branchId,
    this.initialTitle,
  });

  final String branchId;
  final String? initialTitle;

  @override
  State<GymBranchDetailsPage> createState() => _GymBranchDetailsPageState();
}

class _GymBranchDetailsPageState extends State<GymBranchDetailsPage> {
  final BranchService _branchService = BranchService();
  late Future<GymBranchModel> _branchFuture;

  @override
  void initState() {
    super.initState();
    _branchFuture = _branchService.getBranchDetails(branchId: widget.branchId);
  }

  Future<void> _reloadBranch() async {
    final future = _branchService.getBranchDetails(branchId: widget.branchId);
    setState(() {
      _branchFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back<void>(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        title: Text(
          widget.initialTitle?.trim().isNotEmpty == true
              ? widget.initialTitle!
              : 'Branch Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FutureBuilder<GymBranchModel>(
        future: _branchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _BranchPageErrorState(
              title: 'Unable to load branch details',
              error: _resolveBranchError(snapshot.error),
              onRetryTap: _reloadBranch,
            );
          }

          final branch = snapshot.data;
          if (branch == null) {
            return _BranchPageErrorState(
              title: 'Unable to load branch details',
              error: 'Branch details not found.',
              onRetryTap: _reloadBranch,
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              _BranchHeroCard(branch: branch),
              const SizedBox(height: 16),
              _BranchInfoSection(
                title: 'Branch Information',
                children: [
                  _BranchInfoRow(
                    label: 'Status',
                    value: branch.isActive ? 'Active' : 'Inactive',
                  ),
                  _BranchInfoRow(
                    label: 'Address',
                    value: branch.fullAddress.isEmpty
                        ? 'Not available'
                        : branch.fullAddress,
                  ),
                  _BranchInfoRow(
                    label: 'Opening Time',
                    value: _formatBranchTime(branch.openingTime) ?? 'Not available',
                  ),
                  _BranchInfoRow(
                    label: 'Closing Time',
                    value: _formatBranchTime(branch.closingTime) ?? 'Not available',
                  ),
                  _BranchInfoRow(
                    label: 'Access Code',
                    value: branch.accessCode ?? 'Not available',
                  ),
                  if (branch.qrCode?.isNotEmpty ?? false)
                    _BranchQrSection(imageUrl: branch.qrCode!),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BranchListHeader extends StatelessWidget {
  const _BranchListHeader({
    required this.gymName,
    required this.totalCount,
  });

  final String gymName;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1E28), Color(0xFF101216)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gymName.trim().isEmpty ? 'Your Gym' : gymName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap a branch card to view full details.',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.brandGreen.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              '$totalCount total',
              style: GoogleFonts.poppins(
                color: AppColors.brandGreen,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchHeroCard extends StatelessWidget {
  const _BranchHeroCard({required this.branch});

  final GymBranchModel branch;

  @override
  Widget build(BuildContext context) {
    final timeRange = _formatBranchTimeRange(
      branch.openingTime,
      branch.closingTime,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C2027), Color(0xFF12151A)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: branch.isActive
                  ? AppColors.brandGreen.withValues(alpha: 0.14)
                  : Colors.orangeAccent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              branch.isActive ? 'BRANCH ACTIVE' : 'BRANCH INACTIVE',
              style: GoogleFonts.poppins(
                color: branch.isActive ? AppColors.brandGreen : Colors.orangeAccent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            branch.name.isEmpty ? 'Unnamed Branch' : branch.name,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (branch.fullAddress.isNotEmpty) ...[
            const SizedBox(height: 10),
            _BranchDetailRow(
              icon: Icons.location_on_outlined,
              text: branch.fullAddress,
            ),
          ],
          if (timeRange != null) ...[
            const SizedBox(height: 8),
            _BranchDetailRow(
              icon: Icons.schedule_rounded,
              text: timeRange,
            ),
          ],
          if (branch.accessCode?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            _BranchDetailRow(
              icon: Icons.lock_outline_rounded,
              text: 'Access code: ${branch.accessCode}',
            ),
          ],
        ],
      ),
    );
  }
}

class _BranchInfoSection extends StatelessWidget {
  const _BranchInfoSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171A20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _BranchInfoRow extends StatelessWidget {
  const _BranchInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchQrSection extends StatelessWidget {
  const _BranchQrSection({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QR Code',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(14),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      alignment: Alignment.center,
                      color: const Color(0xFFF3F3F3),
                      child: Text(
                        'Unable to load QR code',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.brandGreen,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchPageErrorState extends StatelessWidget {
  const _BranchPageErrorState({
    required this.title,
    required this.error,
    required this.onRetryTap,
  });

  final String title;
  final String error;
  final VoidCallback onRetryTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1E24),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: Colors.white70,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onRetryTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.brandGreen),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.branch,
    this.onTap,
  });

  final GymBranchModel branch;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final timeRange = _formatBranchTimeRange(
      branch.openingTime,
      branch.closingTime,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2027),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      branch.name.isEmpty ? 'Unnamed Branch' : branch.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: branch.isActive
                          ? AppColors.brandGreen.withValues(alpha: 0.14)
                          : Colors.orangeAccent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      branch.isActive ? 'Active' : 'Inactive',
                      style: GoogleFonts.poppins(
                        color: branch.isActive
                            ? AppColors.brandGreen
                            : Colors.orangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (branch.fullAddress.isNotEmpty) ...[
                const SizedBox(height: 10),
                _BranchDetailRow(
                  icon: Icons.location_on_outlined,
                  text: branch.fullAddress,
                ),
              ],
              if (timeRange != null) ...[
                const SizedBox(height: 8),
                _BranchDetailRow(
                  icon: Icons.schedule_rounded,
                  text: timeRange,
                ),
              ],
              if (branch.accessCode?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                _BranchDetailRow(
                  icon: Icons.lock_outline_rounded,
                  text: 'Access code: ${branch.accessCode}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BranchDetailRow extends StatelessWidget {
  const _BranchDetailRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyBranchesState extends StatelessWidget {
  const _EmptyBranchesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.store_mall_directory_outlined,
              color: Colors.white.withValues(alpha: 0.7),
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              'No branches found',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This gym does not have any branches available yet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _resolveBranchError(Object? error) {
  if (error is ApiException) {
    return error.detailMessage;
  }
  return error?.toString() ?? 'Unable to load branches.';
}

String? _formatBranchTimeRange(String? openingTime, String? closingTime) {
  final open = _formatBranchTime(openingTime);
  final close = _formatBranchTime(closingTime);
  if (open == null && close == null) return null;
  if (open != null && close != null) {
    return 'Open $open - $close';
  }
  return open != null ? 'Opens at $open' : 'Closes at $close';
}

String? _formatBranchTime(String? rawValue) {
  if (rawValue == null || rawValue.trim().isEmpty) return null;

  final value = rawValue.trim();
  final timePart = value.contains('T') ? value.split('T').last : value;
  final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(timePart);
  if (match == null) return value;

  final hour = int.tryParse(match.group(1) ?? '');
  final minute = int.tryParse(match.group(2) ?? '');
  if (hour == null || minute == null) return value;

  final suffix = hour >= 12 ? 'PM' : 'AM';
  final normalizedHour = hour % 12 == 0 ? 12 : hour % 12;
  final paddedMinute = minute.toString().padLeft(2, '0');
  return '$normalizedHour:$paddedMinute $suffix';
}
