import 'package:azanto/Services/profile_service.dart';
import 'package:azanto/Services/gym_service.dart';
import 'package:azanto/Services/branch_service.dart';
import 'package:azanto/controllers/home_controller.dart';
import 'package:azanto/controllers/profile_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ProfileService>(() => ProfileService(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<GymService>(() => GymService(), fenix: true);
    Get.lazyPut<BranchService>(() => BranchService(), fenix: true);
  }
}
