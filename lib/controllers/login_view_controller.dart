import 'package:azanto/Services/gym_service.dart';
import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_manager.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
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
      final refreshToken = response['refresh_token'] as String? ?? '';

      await session.startSession(token: token, refreshToken: refreshToken);
      _printTokenOnLogin(token);
      await TokenRefreshManager.scheduleTokenRefresh();

      // Verify gym status before showing success/navigating.
      bool hasGym = false;
      try {
        final gym =
            await GymService(sessionService: session).getGymForOwner();
        hasGym = gym != null;
      } on ApiException catch (e) {
        // If the backend explicitly says not found/forbidden, treat as no gym.
        if (e.statusCode == 403 || e.statusCode == 404) {
          hasGym = false;
        } else {
          Get.snackbar('Could not verify gym', e.detailMessage);
          return;
        }
      } catch (e) {
        Get.snackbar('Could not verify gym', e.toString());
        return;
      }

      final message = response['message'] as String? ?? 'Login successful';
      Get.snackbar('Success', message);
      Get.offAllNamed(hasGym ? AppRoutes.home : AppRoutes.gymOnboarding);
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

  void _printTokenOnLogin(String token) {
    if (!kDebugMode) return;
    final normalized = token.trim();
    if (normalized.isEmpty) {
      debugPrint('[AUTH][login] Bearer token is empty');
      return;
    }
    debugPrint('[AUTH][login] Bearer token: $normalized');
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
