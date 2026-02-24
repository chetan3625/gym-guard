import 'package:azanto/Services/login_services.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifyOtpController extends GetxController {
  VerifyOtpController();

  final ApiServices services = ApiServices();
  final RxBool isLoading = false.obs;
  final List<TextEditingController> digitControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> digitFocusNodes = List.generate(4, (_) => FocusNode());

  String get phone => (Get.arguments?['phone'] as String?) ?? '';

  void onBackTap() {
    final canPop = Get.key.currentState?.canPop() ?? false;
    if (canPop) {
      Get.back<void>();
    } else {
      Get.offAllNamed(AppRoutes.forgotPassword);
    }
  }

  Future<void> onVerifyTap() async {
    final code = digitControllers.map((c) => c.text.trim()).join();
    if (code.isEmpty || code.length < 4 || code.length > 8) {
      Get.snackbar('Invalid code', 'Enter the code (4-8 characters)');
      return;
    }
    final normalizedPhone = phone.replaceAll(RegExp(r'\\D'), '');
    if (normalizedPhone.isEmpty) {
      Get.snackbar('Missing phone', 'Phone number not found. Please retry.');
      return;
    }
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final response = await services.verifyOtp(
        phone: normalizedPhone,
        otp: code,
      );
      final message = response['message'] as String? ?? 'OTP verified';
      final resetToken = response['reset_token'] as String? ?? '';
      Get.snackbar('Success', message);
      if (resetToken.isEmpty) {
        Get.snackbar(
          'Missing token',
          'Reset token not provided. Please request a new code.',
        );
        return;
      }
      Get.toNamed(
        AppRoutes.resetPassword,
        arguments: {'reset_token': resetToken},
      );
    } on ApiException catch (e) {
      Get.snackbar('Failed', e.detailMessage);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onDigitChanged(int index, String value) {
    final cleaned = value.replaceAll(RegExp(r'\\D'), '');

    // Handle paste or rapid typing of multiple digits.
    if (cleaned.length > 1) {
      _fillFromIndex(index, cleaned);
      return;
    }

    // Keep single-digit and move focus as needed.
    if (cleaned.isEmpty) {
      digitControllers[index].clear();
      if (index > 0) _focusPrev(index);
      return;
    }

    if (digitControllers[index].text != cleaned) {
      digitControllers[index].text = cleaned;
      digitControllers[index].selection = TextSelection.collapsed(
        offset: cleaned.length,
      );
    }

    if (index < digitControllers.length - 1) {
      _focusNext(index);
    }
  }

  void _fillFromIndex(int start, String digits) {
    final chars = digits.split('');
    for (
      int offset = 0;
      offset < chars.length && start + offset < digitControllers.length;
      offset++
    ) {
      final target = start + offset;
      digitControllers[target].text = chars[offset];
      digitControllers[target].selection = const TextSelection.collapsed(
        offset: 1,
      );
    }

    final nextIndex = (start + chars.length).clamp(
      0,
      digitControllers.length - 1,
    );
    _focusTo(nextIndex);
  }

  void _focusNext(int index) {
    _focusTo(index + 1);
  }

  void _focusPrev(int index) {
    _focusTo(index - 1);
  }

  void _focusTo(int index) {
    final clamped = index.clamp(0, digitFocusNodes.length - 1);
    Future.microtask(() => digitFocusNodes[clamped].requestFocus());
  }

  @override
  void onClose() {
    for (final c in digitControllers) {
      c.dispose();
    }
    for (final f in digitFocusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
