import 'package:azanto/routes/app_routes.dart';
import 'package:get/get.dart';

class RoleSelectionController extends GetxController {
  void onGymOwnerTap() {
    Get.toNamed(AppRoutes.authEntry);
  }

  void onGymMemberTap() {
    Get.toNamed(AppRoutes.authEntry);
  }
}
