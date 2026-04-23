import 'dart:convert';

import 'package:azanto/Services/gym_service.dart';
import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_manager.dart';
import 'package:azanto/core/auth/auth_role.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:azanto/utils/backend_error_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginViewController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;

  ApiServices services = ApiServices();
  final SessionService session = Get.find<SessionService>();
  final GetStorage _box = GetStorage();

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
      final selectedRole =
          AuthRole.normalize(_box.read<String>('selected_role')) ??
          AuthRole.owner;
      debugPrint('[AUTH][login] Logging in with role: $selectedRole');

      final response = await services.loginUser(
        phoneno: phone,
        password: password,
        role: selectedRole,
      );

      final loggedInRole = AuthRole.extractFromPayload(response);
      _logLoginResponse(
        response: response,
        selectedRole: selectedRole,
        extractedRole: loggedInRole,
      );

      if (!AuthRole.matches(
        appRole: selectedRole,
        responseRole: loggedInRole,
      )) {
        isLoading.value = false;
        final selectedRoleLabel = AuthRole.label(selectedRole);
        final responseRoleLabel = AuthRole.label(loggedInRole);
        final message = loggedInRole == null
            ? 'We could not verify the account role from the login response. Please try again.'
            : 'This account is registered as $responseRoleLabel, but you selected $selectedRoleLabel. Please choose the correct role to continue.';
        Get.snackbar(
          'Access Denied',
          message,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      final token =
          response['token'] as String? ??
          response['access_token'] as String? ??
          '';
      final refreshToken = response['refresh_token'] as String? ?? '';
      if (token.trim().isEmpty) {
        throw ApiException(
          'Login succeeded but the response did not include a token.',
        );
      }

      await session.startSession(
        token: token,
        refreshToken: refreshToken,
        role: loggedInRole,
        authResponse: response,
      );
      _printTokenOnLogin(token);
      try {
        await TokenRefreshManager.scheduleTokenRefresh();
      } catch (e, stack) {
        debugPrint('[AUTH] Failed to schedule token refresh after login: $e\n$stack');
        // Continue anyway - foreground refresh will still work
      }

      if (loggedInRole == AuthRole.member) {
        final message = response['message'] as String? ?? 'Login successful';
        Get.snackbar('Success', message);
        Get.offAllNamed(AppRoutes.memberDashboard);
        return;
      }

      // Verify gym status before showing success/navigating.
      bool hasGym = false;
      try {
        final gym = await GymService(sessionService: session).getGymForOwner();
        hasGym = gym != null;
      } on ApiException catch (e) {
        // Some backend environments report "no gym found" with inconsistent
        // status codes. Treat those as onboarding instead of a fatal error.
        if (_shouldTreatGymLookupAsMissing(e)) {
          hasGym = false;
        } else {
          if (await BackendErrorWidgets.handleApiException(e)) {
            return;
          }
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
      if (await BackendErrorWidgets.handleApiException(e)) {
        return;
      }
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

  bool _shouldTreatGymLookupAsMissing(ApiException error) {
    final statusCode = error.statusCode;
    if (statusCode == 403 || statusCode == 404) {
      return true;
    }

    final normalizedMessage =
        '${error.message}\n${error.detailMessage}'.toLowerCase();
    return normalizedMessage.contains('no gym') ||
        normalizedMessage.contains('gym not found') ||
        normalizedMessage.contains('no gym details found') ||
        normalizedMessage.contains('not found for this owner') ||
        normalizedMessage.contains('owner has no gym');
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

  void _logLoginResponse({
    required Map<String, dynamic> response,
    required String selectedRole,
    required String? extractedRole,
  }) {
    final prettyResponse = const JsonEncoder.withIndent('  ').convert(response);
    debugPrint('[AUTH][login] Selected role: $selectedRole');
    debugPrint(
      '[AUTH][login] Extracted response role: ${extractedRole ?? "null"}',
    );
    debugPrint('[AUTH][login] Response keys: ${response.keys.join(', ')}');

    for (final line in prettyResponse.split('\n')) {
      debugPrint('[AUTH][login][response] $line');
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
