import 'dart:io';

import 'package:azanto/Services/gym_service.dart';
import 'package:azanto/core/config/global_variables.dart';
import 'package:azanto/Services/login_services.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/models/gym_model.dart';
import 'package:azanto/utils/backend_error_widgets.dart';
import 'package:azanto/views/pages/gym_branches_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class GymDetailsPage extends StatefulWidget {
  const GymDetailsPage({
    super.key,
    required this.gymId,
    this.initialTitle,
  });

  final String gymId;
  final String? initialTitle;

  @override
  State<GymDetailsPage> createState() => _GymDetailsPageState();
}

class _GymDetailsPageState extends State<GymDetailsPage> {
  final GymService _gymService = GymService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  GymModel? _gym;
  bool _loading = true;
  bool _saving = false;
  bool _uploadingLogo = false;
  bool _isActive = true;
  String? _error;
  String? _selectedLogoPath;

  @override
  void initState() {
    super.initState();
    _loadGymDetails();
  }

  Future<void> _loadGymDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final gym = await _gymService.getGymDetails();
      String? logoUrl;
      try {
        logoUrl = await _gymService.getGymLogo(gymId: widget.gymId);
      } catch (_) {
        logoUrl = gym.logoUrl;
      }
      if (!mounted) return;
      setState(() {
        _gym = gym.copyWith(logoUrl: logoUrl ?? gym.logoUrl);
        _syncControllers(_gym!);
      });
    } on ApiException catch (e) {
      await BackendErrorWidgets.handleApiException(e);
      if (!mounted) return;
      setState(() {
        _error = e.detailMessage;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _syncControllers(GymModel gym) {
    _nameController.text = gym.name;
    _emailController.text = gym.email;
    _descriptionController.text = gym.description ?? '';
    _isActive = gym.isActive;
  }

  Future<GymModel?> _updateGymDetails() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      Get.snackbar(
        'Missing info',
        'Gym name and email are required.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    setState(() {
      _saving = true;
    });

    try {
      final updatedGym = await _gymService.updateGymDetails(
        id: widget.gymId,
        name: name,
        email: email,
        description: description.isEmpty ? null : description,
        isActive: _isActive,
      );
      if (!mounted) return null;
      GymModel resolvedGym = updatedGym;
      if (_selectedLogoPath != null && _selectedLogoPath!.trim().isNotEmpty) {
        final logoUrl = await _gymService.uploadGymLogo(
          gymId: widget.gymId,
          filePath: _selectedLogoPath!,
        );
        resolvedGym = updatedGym.copyWith(logoUrl: logoUrl);
      }
      setState(() {
        _gym = resolvedGym;
        _syncControllers(resolvedGym);
        _selectedLogoPath = null;
      });
      Get.snackbar(
        'Gym updated',
        'Gym details were saved successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return updatedGym;
    } on ApiException catch (e) {
      await BackendErrorWidgets.handleApiException(e);
      if (!mounted) return null;
      Get.snackbar(
        'Update failed',
        e.detailMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } catch (e) {
      if (!mounted) return null;
      Get.snackbar(
        'Update failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _pickLogo() async {
    if (_uploadingLogo || _saving) return;

    setState(() {
      _uploadingLogo = true;
    });

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1400,
        maxHeight: 1400,
        imageQuality: 88,
      );
      if (!mounted || pickedFile == null) return;
      setState(() {
        _selectedLogoPath = pickedFile.path;
      });
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Logo selection failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploadingLogo = false;
        });
      }
    }
  }

  Future<void> _openBranchesPage() async {
    final gym = _gym;
    if (gym == null) return;

    await Get.to<void>(
      () => GymBranchesPage(
        gymId: gym.id,
        gymName: gym.name,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gym = _gym;

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back<void>(),
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        title: Text(
          'Gym Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _GymErrorState(error: _error!, onRetryTap: _loadGymDetails)
              : gym == null
                  ? _GymErrorState(
                      error: 'Gym details not found.',
                      onRetryTap: _loadGymDetails,
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _GymSummaryCard(
                            gym: gym,
                            selectedLogoPath: _selectedLogoPath,
                            isUploadingLogo: _uploadingLogo,
                            onUploadTap: _pickLogo,
                          ),
                          const SizedBox(height: 16),
                          _GymSection(
                            title: 'Update Gym Details',
                            child: Column(
                              children: [
                                _GymInputField(
                                  label: 'Gym Name',
                                  controller: _nameController,
                                ),
                                const SizedBox(height: 14),
                                _GymInputField(
                                  label: 'Email',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 14),
                                _GymInputField(
                                  label: 'Description',
                                  controller: _descriptionController,
                                  maxLines: 4,
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Active',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Switch(
                                      value: _isActive,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: AppColors.brandGreen,
                                      onChanged: (value) {
                                        setState(() {
                                          _isActive = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _GymInfoRow(label: 'Gym ID', value: gym.id),
                                const SizedBox(height: 18),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _openBranchesPage,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.14,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: const Icon(Icons.storefront_rounded),
                                    label: Text(
                                      'View Branches',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _saving
                                        ? null
                                        : () async {
                                            final updatedGym =
                                                await _updateGymDetails();
                                            if (!mounted ||
                                                updatedGym == null) {
                                              return;
                                            }
                                            Get.back(result: updatedGym);
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.brandGreen,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _saving
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.black,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'Update Gym',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}

class _GymSummaryCard extends StatelessWidget {
  const _GymSummaryCard({
    required this.gym,
    required this.selectedLogoPath,
    required this.isUploadingLogo,
    required this.onUploadTap,
  });

  final GymModel gym;
  final String? selectedLogoPath;
  final bool isUploadingLogo;
  final VoidCallback onUploadTap;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GymLogoAvatar(
                selectedLogoPath: selectedLogoPath,
                logoUrl: gym.logoUrl,
                isUploading: isUploadingLogo,
                onTap: onUploadTap,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: gym.isActive
                            ? AppColors.brandGreen.withValues(alpha: 0.16)
                            : Colors.orangeAccent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        gym.isActive ? 'GYM ACTIVE' : 'GYM INACTIVE',
                        style: GoogleFonts.poppins(
                          color: gym.isActive
                              ? AppColors.brandGreen
                              : Colors.orangeAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      gym.name.isEmpty ? 'Your Gym' : gym.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      gym.email,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (gym.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Text(
              gym.description!,
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GymLogoAvatar extends StatelessWidget {
  const _GymLogoAvatar({
    required this.selectedLogoPath,
    required this.logoUrl,
    required this.isUploading,
    required this.onTap,
  });

  final String? selectedLogoPath;
  final String? logoUrl;
  final bool isUploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: isUploading ? null : onTap,
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              clipBehavior: Clip.antiAlias,
              child: _GymLogoImage(
                selectedLogoPath: selectedLogoPath,
                logoUrl: logoUrl,
              ),
            ),
          ),
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isUploading ? null : onTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.brandGreen,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF101216),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isUploading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.add_rounded,
                          color: Colors.black,
                          size: 18,
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GymLogoImage extends StatelessWidget {
  const _GymLogoImage({
    required this.selectedLogoPath,
    required this.logoUrl,
  });

  final String? selectedLogoPath;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    if (selectedLogoPath != null && selectedLogoPath!.trim().isNotEmpty) {
      return Image.file(
        File(selectedLogoPath!),
        fit: BoxFit.cover,
      );
    }

    final normalized = logoUrl?.trim() ?? '';
    if (normalized.isNotEmpty) {
      final resolved = normalized.startsWith('http://') ||
              normalized.startsWith('https://')
          ? normalized
          : '${GlobalVariables.apiHost}$normalized';
      return Image.network(
        resolved,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _GymLogoPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.brandGreen,
              ),
            ),
          );
        },
      );
    }

    return const _GymLogoPlaceholder();
  }
}

class _GymLogoPlaceholder extends StatelessWidget {
  const _GymLogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.image_outlined,
        color: Colors.white54,
        size: 32,
      ),
    );
  }
}

class _GymSection extends StatelessWidget {
  const _GymSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

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
          child,
        ],
      ),
    );
  }
}

class _GymInfoRow extends StatelessWidget {
  const _GymInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            ),
          ),
        ),
      ],
    );
  }
}

class _GymInputField extends StatelessWidget {
  const _GymInputField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: AppColors.brandGreen),
            ),
          ),
        ),
      ],
    );
  }
}

class _GymErrorState extends StatelessWidget {
  const _GymErrorState({
    required this.error,
    required this.onRetryTap,
  });

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
                'Unable to load gym details',
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
