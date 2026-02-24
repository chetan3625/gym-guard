import 'package:azanto/controllers/role_selection_controller.dart';
import 'package:get/get.dart';

class RoleSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoleSelectionController>(() => RoleSelectionController());
  }
}
