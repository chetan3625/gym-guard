import 'dart:typed_data';

import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/profile_local_prefs_service.dart';
import 'package:azanto/Services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  ProfileController({
    ProfileService? profileService,
    ProfileLocalPrefsService? profilePrefs,
  }) : _profileService = profileService ?? Get.find<ProfileService>(),
       _profilePrefs = profilePrefs ?? Get.find<ProfileLocalPrefsService>();

  final ProfileService _profileService;
  final ProfileLocalPrefsService _profilePrefs;
  final ImagePicker _imagePicker = ImagePicker();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final quoteController = TextEditingController();
  final genderController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final RxnString selectedGender = RxnString();

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploadingAvatar = false.obs;
  final Rx<Uint8List?> avatarBytes = Rx<Uint8List?>(null);
  final RxString avatarUrl = ''.obs;
  final RxString profileError = ''.obs;

  @override
  void onReady() {
    super.onReady();
    loadProfileAndAvatar();
  }

  Future<void> loadProfileAndAvatar() async {
    final localSeed = await _profilePrefs.getProfileSeed();
    _applyLocalSeed(localSeed);
    await Future.wait([loadProfile(localSeed: localSeed), loadAvatar()]);
  }

  Future<void> loadProfile({LocalProfileSeed? localSeed}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    profileError.value = '';
    final cachedSeed = localSeed ?? await _profilePrefs.getProfileSeed();
    _applyLocalSeed(cachedSeed);

    try {
      final profile = await _profileService.getProfile();
      final data = _normalizeProfileData(profile);

      firstNameController.text = _resolveValue(
        _stringOf(data['first_name']),
        cachedSeed.firstName,
      );
      lastNameController.text = _resolveValue(
        _stringOf(data['last_name']),
        cachedSeed.lastName,
      );
      quoteController.text = _stringOf(data['quote']);
      final normalizedGender = _normalizeGender(_stringOf(data['gender']));
      selectedGender.value = normalizedGender;
      genderController.text = normalizedGender ?? '';
      dobController.text = _stringOf(data['dob']);
      phoneController.text = _resolveValue(
        _stringOf(data['phone']),
        cachedSeed.phone,
      );
      emailController.text = _resolveValue(
        _stringOf(data['email']),
        cachedSeed.email,
      );

      await _persistLocalSeed();
    } on ApiException catch (e) {
      profileError.value = e.detailMessage;
    } catch (e) {
      profileError.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAvatar() async {
    try {
      final avatar = await _profileService.getAvatar();
      if (avatar.bytes != null) {
        avatarBytes.value = avatar.bytes;
        avatarUrl.value = '';
      } else if (avatar.url != null && avatar.url!.trim().isNotEmpty) {
        avatarUrl.value = avatar.url!.trim();
        avatarBytes.value = null;
      }
    } catch (_) {
      // Keep profile screen usable even if avatar endpoint fails.
    }
  }

  Future<void> onSelectDobTap(BuildContext context) async {
    final currentValue = dobController.text.trim();
    DateTime initialDate = DateTime.now();

    if (currentValue.isNotEmpty) {
      final parts = currentValue.split('-');
      if (parts.length == 3) {
        final year = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final day = int.tryParse(parts[2]);
        if (year != null && month != null && day != null) {
          initialDate = DateTime(year, month, day);
        }
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    dobController.text =
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
  }

  Future<void> onUploadAvatarTap() async {
    if (isUploadingAvatar.value) return;

    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 86,
    );

    if (pickedImage == null) return;

    isUploadingAvatar.value = true;
    try {
      await _profileService.uploadAvatar(filePath: pickedImage.path);
      await loadAvatar();
      Get.snackbar('Success', 'Avatar updated');
    } on ApiException catch (e) {
      Get.snackbar('Upload failed', e.detailMessage);
    } catch (e) {
      Get.snackbar('Upload failed', e.toString());
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  Future<void> onSaveProfileTap() async {
    if (isSaving.value) return;

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final quote = quoteController.text.trim();
    final gender = genderController.text.trim();
    final dob = dobController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      Get.snackbar('Missing info', 'First name and last name are required');
      return;
    }
    if (phone.isEmpty || email.isEmpty) {
      Get.snackbar('Missing info', 'Phone and email are required');
      return;
    }

    isSaving.value = true;
    try {
      final message = await _profileService.updateProfile(<String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'quote': quote,
        'gender': gender,
        'dob': dob,
        'phone': phone,
        'email': email,
      });
      await _persistLocalSeed();
      Get.snackbar('Success', message);
    } on ApiException catch (e) {
      Get.snackbar('Update failed', e.detailMessage);
    } catch (e) {
      Get.snackbar('Update failed', e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  Map<String, dynamic> _normalizeProfileData(Map<String, dynamic> payload) {
    if (payload['data'] is Map) {
      return Map<String, dynamic>.from(payload['data'] as Map);
    }
    if (payload['profile'] is Map) {
      return Map<String, dynamic>.from(payload['profile'] as Map);
    }
    return payload;
  }

  void _applyLocalSeed(LocalProfileSeed seed) {
    _setIfEmpty(firstNameController, seed.firstName);
    _setIfEmpty(lastNameController, seed.lastName);
    _setIfEmpty(phoneController, seed.phone);
    _setIfEmpty(emailController, seed.email);
  }

  void _setIfEmpty(TextEditingController controller, String value) {
    if (controller.text.trim().isNotEmpty) return;
    final normalized = value.trim();
    if (normalized.isEmpty) return;
    controller.text = normalized;
  }

  String _resolveValue(String primary, String fallback) {
    final normalizedPrimary = primary.trim();
    if (normalizedPrimary.isNotEmpty) return normalizedPrimary;
    return fallback.trim();
  }

  Future<void> _persistLocalSeed() {
    return _profilePrefs.saveProfileSeed(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      phone: phoneController.text,
      email: emailController.text,
    );
  }

  String _stringOf(dynamic value) => value is String ? value : '';

  String? _normalizeGender(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    if (normalized == 'male' ||
        normalized == 'female' ||
        normalized == 'other') {
      return normalized;
    }
    return null;
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    quoteController.dispose();
    genderController.dispose();
    dobController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
