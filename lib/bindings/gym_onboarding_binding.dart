import 'package:azanto/Services/branch_service.dart';
import 'package:azanto/Services/gym_service.dart';
import 'package:get/get.dart';

class GymOnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GymService>(() => GymService(), fenix: true);
    Get.lazyPut<BranchService>(() => BranchService(), fenix: true);
  }
}
