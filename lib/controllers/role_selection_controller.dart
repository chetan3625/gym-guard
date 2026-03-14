import 'package:azanto/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RoleSelectionController extends GetxController {
  final GetStorage _box = GetStorage();

  void onGymOwnerTap() {
    _box.write('selected_role', 'owner');
    Get.toNamed(AppRoutes.authEntry);
  }

  void onGymMemberTap() {
    _box.write('selected_role', 'member');
    Get.toNamed(AppRoutes.authEntry);
  }
}
