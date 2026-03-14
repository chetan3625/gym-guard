import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/profile_local_prefs_service.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SignupViewController extends GetxController {
  final fullNameController = TextEditingController();
  final contactController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isLoading = false.obs;

  final ApiServices services = ApiServices();
  final ProfileLocalPrefsService _profilePrefs =
      Get.find<ProfileLocalPrefsService>();
  final GetStorage _box = GetStorage();

  void onBackTap() {
    final canPop = Get.key.currentState?.canPop() ?? false;
    if (canPop) {
      Get.back<void>();
    } else {
      Get.offAllNamed(AppRoutes.authEntry);
    }
  }

  void togglePasswordVisibility() => obscurePassword.toggle();
  void toggleConfirmPasswordVisibility() => obscureConfirmPassword.toggle();

  Future<void> onSignupTap() async {
    final name = fullNameController.text.trim();
    final contact = contactController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    if (name.isEmpty ||
        contact.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      Get.snackbar('Missing info', 'All fields are required');
      return;
    }
    if (name.length > 20) {
      Get.snackbar('Name too long', 'Name must be 20 characters or fewer');
      return;
    }
    final phoneDigits = contact.replaceAll(RegExp(r'\\D'), '');
    if (phoneDigits.length < 10 || phoneDigits.length > 15) {
      Get.snackbar(
        'Invalid phone',
        'Enter a valid phone number (10-15 digits)',
      );
      return;
    }
    if (password.length < 6) {
      Get.snackbar('Weak password', 'Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      Get.snackbar('Password mismatch', 'Passwords do not match');
      return;
    }
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final role = _box.read<String>('selected_role') ?? 'member'; // default to member if not set
      final response = await services.signupUser(
        fullName: name,
        phone: phoneDigits,
        password: password,
        role: role,
      );
      await _profilePrefs.saveFromSignup(fullName: name, phone: phoneDigits);
      final message = response['message'] as String? ?? 'Account created';
      Get.snackbar('Success', message);
      Get.offAllNamed(AppRoutes.login);
    } on ApiException catch (e) {
      Get.snackbar('Sign up failed', e.detailMessage);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    contactController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
