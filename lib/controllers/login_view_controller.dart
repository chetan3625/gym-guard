import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginViewController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;

  ApiServices services = ApiServices();
  final SessionService session = Get.find<SessionService>();

  void onBackTap() {
    final canPop = Get.key.currentState?.canPop() ?? false;
    if (canPop) {
      Get.back<void>();
    } else {
      Get.offAllNamed(AppRoutes.roleSelection);
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void onForgotPasswordTap() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  Future<void> onLoginTap() async {
    final phone = usernameController.text.trim();
    final password = passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      Get.snackbar('Missing info', 'Phone number and password are required');
      return;
    }

    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final response = await services.loginUser(
        phoneno: phone,
        password: password,
      );

      final token =
          response['token'] as String? ??
          response['access_token'] as String? ??
          '';
      await session.startSession(token: token);

      final message = response['message'] as String? ?? 'Login successful';
      Get.snackbar('Success', message);
      Get.offAllNamed(AppRoutes.home);
    } on ApiException catch (e) {
      Get.snackbar('Login failed', e.detailMessage);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onSignUpTap() {
    Get.toNamed(AppRoutes.signup);
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
