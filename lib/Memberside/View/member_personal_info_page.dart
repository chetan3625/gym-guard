import 'dart:io';
import 'dart:typed_data';

import 'package:azanto/Memberside/constants/member_figma_layout.dart';
import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/profile_local_prefs_service.dart';
import 'package:azanto/Services/profile_service.dart';
import 'package:azanto/models/profile_model.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Figma: `personal info` (178:204) — opened from Edit Profile.
class MemberPersonalInfoPage extends StatefulWidget {
  const MemberPersonalInfoPage({super.key, required this.avatarLetter});

  final String avatarLetter;

  @override
  State<MemberPersonalInfoPage> createState() => _MemberPersonalInfoPageState();
}

class _MemberPersonalInfoPageState extends State<MemberPersonalInfoPage> {
  final _profilePrefs = Get.find<ProfileLocalPrefsService>();
  final _profileService = Get.isRegistered<ProfileService>()
      ? Get.find<ProfileService>()
      : ProfileService();
  final _imagePicker = ImagePicker();

  late final TextEditingController _fullNameController;
  late final TextEditingController _gymNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;
  String _gender = 'Male';
  String? _avatarFilePath;
  Uint8List? _avatarBytes;
  String? _avatarUrl;
  bool _isUploadingAvatar = false;
  ProfileModel? _serverProfile;

  static const _genders = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _gymNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
    _loadProfile();
    _loadAvatar();
  }

  String _formatToUiDob(String? apiDob) {
    if (apiDob == null || apiDob.trim().isEmpty) return '';
    final parts = apiDob.trim().split('-');
    if (parts.length == 3) {
      final year = parts[0];
      final month = parts[1];
      final day = parts[2];
      return '$day/$month/$year';
    }
    return apiDob;
  }

  String _formatToApiDob(String? uiDob) {
    if (uiDob == null || uiDob.trim().isEmpty) return '';
    final parts = uiDob.trim().split('/');
    if (parts.length == 3) {
      final day = parts[0];
      final month = parts[1];
      final year = parts[2];
      return '$year-$month-$day';
    }
    return uiDob;
  }

  Future<void> _loadProfile() async {
    final seed = await _profilePrefs.getProfileSeed();
    final first = seed.firstName;
    final last = seed.lastName;
    final fullName = [first, last].where((p) => p.isNotEmpty).join(' ');

    if (mounted) {
      setState(() {
        _fullNameController.text = fullName.isNotEmpty ? fullName : 'Alex Adams';
        _gymNameController.text =
            seed.gymName.isNotEmpty ? seed.gymName : 'Getfit Studio';
        _lastNameController.text = last.isNotEmpty ? last : 'Adams';
        _phoneController.text =
            seed.phone.isNotEmpty ? seed.phone : '+91 9500999999';
        _dobController.text = seed.dob.isNotEmpty ? seed.dob : '15/06/1995';
        _gender = seed.gender.isNotEmpty ? seed.gender : 'Male';
      });
    }

    try {
      final profile = await _profileService.getProfile();
      _serverProfile = profile;
      final serverFirst = profile.firstName;
      final serverLast = profile.lastName;
      final serverFullName = [serverFirst, serverLast].where((p) => p.isNotEmpty).join(' ');

      if (!mounted) return;
      setState(() {
        if (serverFullName.isNotEmpty) {
          _fullNameController.text = serverFullName;
        }
        if (serverLast.isNotEmpty) {
          _lastNameController.text = serverLast;
        }
        if (profile.phone.isNotEmpty) {
          _phoneController.text = profile.phone;
        }
        if (profile.dob.isNotEmpty) {
          _dobController.text = _formatToUiDob(profile.dob);
        }
        if (profile.gender.isNotEmpty) {
          _gender = profile.gender;
        }
      });

      await _profilePrefs.saveProfileSeed(
        firstName: profile.firstName,
        lastName: profile.lastName,
        phone: profile.phone,
        email: profile.email,
        dob: profile.dob,
        gender: profile.gender,
      );
    } catch (e) {
      debugPrint('Error loading profile from API on personal info page: $e');
    }
  }

  Future<void> _loadAvatar() async {
    try {
      final avatar = await _profileService.getAvatar();
      if (!mounted || !avatar.hasData) return;
      setState(() {
        _avatarBytes = avatar.bytes;
        _avatarUrl = avatar.url?.trim();
        _avatarFilePath = null;
      });
    } catch (_) {
      // The rest of the profile form should remain usable if avatar loading fails.
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _gymNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final parsed = _tryParseDob(_dobController.text);
    final initial = parsed ?? DateTime(1995, 6, 15);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: MemberFigmaColors.accent,
              surface: MemberFigmaColors.cardBg,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      _dobController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    });
  }

  DateTime? _tryParseDob(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  void _pickGender() {
    Get.bottomSheet<void>(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: MemberFigmaColors.formBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _genders
              .map(
                (option) => ListTile(
                  title:
                      Text(option, style: const TextStyle(color: Colors.white)),
                  trailing: _gender == option
                      ? const Icon(Icons.check, color: MemberFigmaColors.accent)
                      : null,
                  onTap: () {
                    setState(() => _gender = option);
                    Get.back<void>();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _uploadAvatar() async {
    if (_isUploadingAvatar) return;

    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 86,
    );
    if (pickedImage == null) return;

    setState(() {
      _isUploadingAvatar = true;
      _avatarFilePath = pickedImage.path;
    });

    try {
      final message = await _profileService.uploadAvatar(
        filePath: pickedImage.path,
      );
      try {
        final avatar = await _profileService.getAvatar();
        if (mounted && avatar.hasData) {
          setState(() {
            _avatarBytes = avatar.bytes;
            _avatarUrl = avatar.url?.trim();
            _avatarFilePath = null;
          });
        }
      } catch (_) {
        // Keep the local preview if the upload succeeded but refresh is delayed.
      }
      if (!mounted) return;
      Get.snackbar(
        'Avatar updated',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: MemberFigmaColors.accent.withValues(alpha: 0.92),
        colorText: MemberFigmaColors.accentDarkText,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Upload failed',
        e.detailMessage,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Upload failed',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _save() async {
    final fullName = _fullNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    if (fullName.isEmpty || lastName.isEmpty) {
      Get.snackbar(
        'Missing details',
        'Please enter your full name and last name.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final split = _splitFullName(fullName);
    
    try {
      final seed = await _profilePrefs.getProfileSeed();

      final updatedProfile = await _profileService.updateProfile(<String, dynamic>{
        'first_name': split.firstName,
        'last_name': lastName,
        'quote': _serverProfile?.quote ?? '',
        'gender': _gender,
        'dob': _formatToApiDob(_dobController.text),
        'height': _serverProfile?.height ?? 0,
        'weight': _serverProfile?.weight ?? 0,
        'phone': _phoneController.text.trim(),
        'email': _serverProfile?.email ?? seed.email,
      });

      await _profilePrefs.saveProfileSeed(
        firstName: updatedProfile.firstName,
        lastName: updatedProfile.lastName,
        phone: updatedProfile.phone,
        email: updatedProfile.email,
        dob: updatedProfile.dob,
        gender: updatedProfile.gender,
        gymName: _gymNameController.text.trim(),
      );

      if (!mounted) return;
      Get.back<bool>(result: true);
      Get.snackbar(
        'Profile updated',
        'Your personal information was saved.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: MemberFigmaColors.accent.withValues(alpha: 0.92),
        colorText: MemberFigmaColors.accentDarkText,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Update failed',
        e.detailMessage,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Update failed',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  ({String firstName, String lastName}) _splitFullName(String rawName) {
    final parts = rawName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return (firstName: '', lastName: '');
    if (parts.length == 1) return (firstName: parts.first, lastName: '');
    return (firstName: parts.first, lastName: parts.sublist(1).join(' '));
  }

  @override
  Widget build(BuildContext context) {
    final layout = MemberFigmaLayout(
      context,
      designWidth: MemberFigmaLayout.personalInfoDesignWidth,
    );

    return Scaffold(
      backgroundColor: AppColors.mobileScaffold,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.mobileScaffold,
              AppColors.mobileGradientMid,
              Color(0xFF272727),
            ],
            stops: [0.054, 0.516, 0.927],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: layout.padLTRB(17, 12, 17, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PersonalInfoHeader(layout: layout),
                SizedBox(height: layout.s(18)),
                _ProfileAvatarSection(
                  layout: layout,
                  avatarLetter: widget.avatarLetter,
                  avatarFilePath: _avatarFilePath,
                  avatarBytes: _avatarBytes,
                  avatarUrl: _avatarUrl,
                  isUploading: _isUploadingAvatar,
                  onEditTap: _uploadAvatar,
                ),
                SizedBox(height: layout.s(20)),
                _FormCard(
                  layout: layout,
                  fullNameController: _fullNameController,
                  gymNameController: _gymNameController,
                  lastNameController: _lastNameController,
                  phoneController: _phoneController,
                  dobController: _dobController,
                  gender: _gender,
                  onPickDate: _pickDate,
                  onPickGender: _pickGender,
                  onSave: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonalInfoHeader extends StatelessWidget {
  const _PersonalInfoHeader({required this.layout});

  final MemberFigmaLayout layout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleBackButton(layout: layout),
        Expanded(
          child: Text(
            'Personal Information',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: layout.s(20),
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
        SizedBox(width: layout.s(34)),
      ],
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({required this.layout});

  final MemberFigmaLayout layout;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.back<void>(),
        customBorder: const CircleBorder(),
        child: Container(
          width: layout.s(34),
          height: layout.s(34),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.35),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: layout.s(16),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatarSection extends StatelessWidget {
  const _ProfileAvatarSection({
    required this.layout,
    required this.avatarLetter,
    required this.avatarFilePath,
    required this.avatarBytes,
    required this.avatarUrl,
    required this.isUploading,
    required this.onEditTap,
  });

  final MemberFigmaLayout layout;
  final String avatarLetter;
  final String? avatarFilePath;
  final Uint8List? avatarBytes;
  final String? avatarUrl;
  final bool isUploading;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final avatarSize = layout.s(118);
    final editSize = layout.s(31);

    return Column(
      children: [
        Stack(
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
                  avatarLetter: avatarLetter,
                  avatarFilePath: avatarFilePath,
                  avatarBytes: avatarBytes,
                  avatarUrl: avatarUrl,
                  fontSize: layout.s(40),
                ),
              ),
            ),
            Positioned(
              right: layout.s(4),
              bottom: layout.s(4),
              child: Material(
                color: MemberFigmaColors.accent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: isUploading ? null : onEditTap,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: editSize,
                    height: editSize,
                    child: isUploading
                        ? Padding(
                            padding: EdgeInsets.all(layout.s(7)),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: MemberFigmaColors.accentDarkText,
                            ),
                          )
                        : Icon(
                            LucideIcons.pencil,
                            size: layout.s(16),
                            color: MemberFigmaColors.accentDarkText,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: layout.s(12)),
        Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontSize: layout.s(18),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({
    required this.avatarLetter,
    required this.avatarFilePath,
    required this.avatarBytes,
    required this.avatarUrl,
    required this.fontSize,
  });

  final String avatarLetter;
  final String? avatarFilePath;
  final Uint8List? avatarBytes;
  final String? avatarUrl;
  final double fontSize;

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
        errorBuilder: (_, __, ___) => _InitialAvatar(
          avatarLetter: avatarLetter,
          fontSize: fontSize,
        ),
      );
    }
    if (avatarFilePath != null) {
      return Image.file(File(avatarFilePath!), fit: BoxFit.cover);
    }
    return _InitialAvatar(avatarLetter: avatarLetter, fontSize: fontSize);
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({
    required this.avatarLetter,
    required this.fontSize,
  });

  final String avatarLetter;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        avatarLetter,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2D2D2D),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.layout,
    required this.fullNameController,
    required this.gymNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.dobController,
    required this.gender,
    required this.onPickDate,
    required this.onPickGender,
    required this.onSave,
  });

  final MemberFigmaLayout layout;
  final TextEditingController fullNameController;
  final TextEditingController gymNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController dobController;
  final String gender;
  final VoidCallback onPickDate;
  final VoidCallback onPickGender;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: layout.padLTRB(17, 24, 17, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MemberFigmaColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: layout.s(24),
            offset: Offset(0, layout.s(8)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PersonalInfoField(
            layout: layout,
            label: 'Full Name',
            controller: fullNameController,
          ),
          SizedBox(height: layout.s(18)),
          _PersonalInfoField(
            layout: layout,
            label: 'Gym Name',
            controller: gymNameController,
          ),
          SizedBox(height: layout.s(18)),
          _PersonalInfoField(
            layout: layout,
            label: 'Last Name',
            controller: lastNameController,
          ),
          SizedBox(height: layout.s(18)),
          _PersonalInfoField(
            layout: layout,
            label: 'Phone Number',
            controller: phoneController,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: layout.s(18)),
          Row(
            children: [
              Expanded(
                child: _PersonalInfoField(
                  layout: layout,
                  label: 'DOB',
                  controller: dobController,
                  readOnly: true,
                  onTap: onPickDate,
                  suffix: Icon(
                    LucideIcons.calendar,
                    color: MemberFigmaColors.label,
                    size: layout.s(20),
                  ),
                ),
              ),
              SizedBox(width: layout.s(12)),
              Expanded(
                child: _PersonalInfoPickerField(
                  layout: layout,
                  label: 'Gender',
                  value: gender,
                  onTap: onPickGender,
                  suffix: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: MemberFigmaColors.label,
                    size: layout.s(22),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: layout.s(28)),
          _SaveChangesButton(layout: layout, onPressed: onSave),
        ],
      ),
    );
  }
}

class _PersonalInfoField extends StatelessWidget {
  const _PersonalInfoField({
    required this.layout,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.suffix,
  });

  final MemberFigmaLayout layout;
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: layout.s(13),
            fontWeight: FontWeight.w500,
            color: MemberFigmaColors.label,
          ),
        ),
        SizedBox(height: layout.s(8)),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: readOnly ? onTap : null,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: layout.s(55),
              padding: layout.padLTRB(16, 0, 12, 0),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: MemberFigmaColors.cardIconCircle),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      readOnly: readOnly,
                      keyboardType: keyboardType,
                      style: GoogleFonts.poppins(
                        fontSize: layout.s(14),
                        fontWeight: FontWeight.w500,
                        color: MemberFigmaColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (suffix != null) suffix!,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PersonalInfoPickerField extends StatelessWidget {
  const _PersonalInfoPickerField({
    required this.layout,
    required this.label,
    required this.value,
    required this.onTap,
    this.suffix,
  });

  final MemberFigmaLayout layout;
  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: layout.s(13),
            fontWeight: FontWeight.w500,
            color: MemberFigmaColors.label,
          ),
        ),
        SizedBox(height: layout.s(8)),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: layout.s(55),
              padding: layout.padLTRB(16, 0, 12, 0),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: MemberFigmaColors.cardIconCircle),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: layout.s(14),
                        fontWeight: FontWeight.w500,
                        color: MemberFigmaColors.textPrimary,
                      ),
                    ),
                  ),
                  if (suffix != null) suffix!,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveChangesButton extends StatelessWidget {
  const _SaveChangesButton({required this.layout, required this.onPressed});

  final MemberFigmaLayout layout;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: layout.s(45),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF43890D), MemberFigmaColors.accent],
          ),
          boxShadow: [
            BoxShadow(
              color: MemberFigmaColors.accent.withValues(alpha: 0.22),
              blurRadius: 10,
              offset: Offset(0, layout.s(4)),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                'Save Changes',
                style: GoogleFonts.poppins(
                  fontSize: layout.s(15),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
