import 'package:azanto/routes/app_routes.dart';
import 'package:get/get.dart';

class AuthEntryController extends GetxController {
  void onLoginTap() {
    Get.toNamed(AppRoutes.login);
  }

  void onSignUpTap() {
    Get.toNamed(AppRoutes.signup);
  }
}
