import 'package:azanto/Services/login_services.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final phoneController = TextEditingController();
  final RxBool isLoading = false.obs;
  final ApiServices services = ApiServices();

  void onBackTap() {
    final canPop = Get.key.currentState?.canPop() ?? false;
    if (canPop) {
      Get.back<void>();
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> onSendCodeTap() async {
    final phoneDigits = phoneController.text.replaceAll(RegExp(r'\\D'), '');

    if (phoneDigits.length < 10 || phoneDigits.length > 15) {
      Get.snackbar(
        'Invalid phone',
        'Enter a valid phone number (10-15 digits)',
      );
      return;
    }
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final response = await services.requestOtp(phone: phoneDigits);
      final message = response['message'] as String? ?? 'Code sent';
      final otp = response['otp']?.toString();

      print('Request OTP response: $response');
      final display = otp != null && otp.isNotEmpty
          ? '$message (OTP: $otp)'
          : message;

      Get.snackbar('Success', display);
      Get.toNamed(
        AppRoutes.verifyOtp,
        arguments: {'phone': phoneDigits, 'otp': otp},
      );
    } on ApiException catch (e) {
      Get.snackbar('Failed', e.detailMessage);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
