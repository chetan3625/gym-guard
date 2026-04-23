
import 'package:azanto/Services/member_service.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SearchMemberController extends GetxController {
  late final MemberService _memberService;
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<MemberService>()) {
      _memberService = Get.find<MemberService>();
    } else {
      _memberService = MemberService();
    }
  }

  void searchMember() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return;
    }
    isLoading.value = true;
    try {
      final phone = phoneController.text.replaceAll(RegExp(r'\D'), '');
      final user = await _memberService.searchMemberByPhone(phone);
      if (user != null) {
        Get.toNamed(AppRoutes.memberPlanSelection, arguments: user);
      } else {
        Get.snackbar('Error', 'Member not found');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
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
