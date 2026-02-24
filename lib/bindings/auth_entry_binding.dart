import 'package:azanto/controllers/auth_entry_controller.dart';
import 'package:get/get.dart';

class AuthEntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthEntryController>(() => AuthEntryController());
  }
}
