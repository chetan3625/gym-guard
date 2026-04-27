
import 'package:azanto/Services/member_service.dart';
import 'package:azanto/Services/plan_service.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/models/plan_model.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:azanto/utils/member_search_mapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberPlanSelectionController extends GetxController {
  late final PlanService _planService;
  late final MemberService _memberService;
  late final SessionService _sessionService;

  late final Map<String, dynamic> searchedUser;

  var plans = <Plan>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize services
    if (Get.isRegistered<PlanService>()) {
      _planService = Get.find<PlanService>();
    } else {
      _planService = PlanService();
    }
    if (Get.isRegistered<MemberService>()) {
      _memberService = Get.find<MemberService>();
    } else {
      _memberService = MemberService();
    }
    _sessionService = Get.find<SessionService>();
    
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      searchedUser = args;
    } else {
      searchedUser = {};
      Get.snackbar('Error', 'Invalid member data');
      Get.back();
      return;
    }
    fetchPlans();
  }

  void fetchPlans() async {
    isLoading.value = true;
    try {
      final gymId = _sessionService.gymId;
      if (gymId == null) {
        Get.snackbar('Error', 'Gym not found.');
        isLoading.value = false;
        return;
      }
      final branchId = _sessionService.branchId ?? gymId;
      plans.value = await _planService.getAllPlans(gymId: gymId, branchId: branchId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch plans: $e');
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }

  void onPlanSelected(Plan plan) {
    Get.dialog(
      AlertDialog(
        title: Text('Select Payment Method for ${plan.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Cash'),
              onTap: () {
                Get.back();
                _processSubscription(plan, 'cash');
              },
            ),
            ListTile(
              title: const Text('UPI'),
              onTap: () {
                Get.back();
                _processSubscription(plan, 'upi');
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getMemberName() {
    return MemberSearchMapper.resolveMemberName(searchedUser);
  }

  String? _getUserId() {
    return MemberSearchMapper.resolveUserId(searchedUser);
  }

  void _processSubscription(Plan plan, String paymentMode) async {
    final userId = _getUserId();
    if (userId == null || userId.isEmpty) {
      Get.snackbar('Error', 'Member ID not found');
      return;
    }
    
    isLoading.value = true;
    try {
      final gymId = _sessionService.gymId;
      if (gymId == null) {
        Get.snackbar('Error', 'Gym not found.');
        isLoading.value = false;
        return;
      }
      
      await _memberService.purchaseMembership(
        gymId: gymId,
        planId: plan.id,
        userId: userId,
        amount: plan.price.toDouble(),
        paymentMode: paymentMode,
      );
      
      Get.dialog(
        AlertDialog(
          title: const Text('Success'),
          content: Text('Subscribed ${_getMemberName()} to ${plan.name}'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // close dialog
                Get.offAllNamed(AppRoutes.home);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Subscription failed: $e');
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
    }
  }
}
