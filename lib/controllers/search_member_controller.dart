
import 'package:azanto/Services/member_service.dart';
import 'package:azanto/utils/member_search_mapper.dart';
import 'package:azanto/views/pages/select_plan_page.dart';
import 'package:flutter/material.dart';
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
        final userId = MemberSearchMapper.resolveUserId(user);
        if (userId == null || userId.isEmpty) {
          Get.snackbar('Error', 'Member ID not found in search response');
          return;
        }
        Get.to(
          () => SelectPlanPage(
            name: MemberSearchMapper.resolveMemberName(user),
            phone: MemberSearchMapper.resolvePhone(user) ?? phone,
            userId: userId,
          ),
        );
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
