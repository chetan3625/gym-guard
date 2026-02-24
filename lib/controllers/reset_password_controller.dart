import 'package:azanto/Services/login_services.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isLoading = false.obs;
  final ApiServices services = ApiServices();

  String get resetToken => (Get.arguments?['reset_token'] as String?) ?? '';

  void onBackTap() {
    final canPop = Get.key.currentState?.canPop() ?? false;
    if (canPop) {
      Get.back<void>();
    } else {
      Get.offAllNamed(AppRoutes.verifyOtp);
    }
  }

  Future<void> onSubmit() async {
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    if (password.length < 6) {
      Get.snackbar('Weak password', 'Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      Get.snackbar('Password mismatch', 'Passwords do not match');
      return;
    }
    if (resetToken.trim().isEmpty) {
      Get.snackbar('Missing token', 'Reset token missing. Please retry.');
      return;
    }
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final response = await services.resetPassword(
        resetToken: resetToken.trim(),
        newPassword: password,
      );
      final message =
          response['message'] as String? ?? 'Password reset successfully';
      Get.snackbar('Success', message);
      Get.toNamed(AppRoutes.resetPasswordSuccess);
    } on ApiException catch (e) {
      Get.snackbar('Failed', e.detailMessage);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() => obscurePassword.toggle();
  void toggleConfirmPasswordVisibility() => obscureConfirmPassword.toggle();

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
