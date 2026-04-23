
import 'package:azanto/Services/member_service.dart';
import 'package:azanto/Services/plan_service.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/controllers/member_plan_selection_controller.dart';
import 'package:get/get.dart';

class MemberPlanSelectionBinding extends Bindings {
  @override
  void dependencies() {
    // Register services if not already registered
    if (!Get.isRegistered<SessionService>()) {
      Get.lazyPut<SessionService>(() => SessionService());
    }
    if (!Get.isRegistered<MemberService>()) {
      Get.lazyPut<MemberService>(() => MemberService());
    }
    if (!Get.isRegistered<PlanService>()) {
      Get.lazyPut<PlanService>(() => PlanService());
    }
    Get.lazyPut<MemberPlanSelectionController>(() => MemberPlanSelectionController());
  }
}
