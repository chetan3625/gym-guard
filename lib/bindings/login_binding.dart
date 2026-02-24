import 'package:azanto/controllers/login_view_controller.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Recreate controller if it was disposed during flows like password reset.
    Get.lazyPut<LoginViewController>(() => LoginViewController(), fenix: true);
  }
}
