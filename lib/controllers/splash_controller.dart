import 'package:azanto/Services/session_service.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  SplashController({this.duration = const Duration(milliseconds: 1800)});

  final Duration duration;
  final SessionService _session = Get.find<SessionService>();

  @override
  void onReady() {
    super.onReady();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future<void>.delayed(duration);
    if (isClosed) {
      return;
    }
    final isLoggedIn = _session.isLoggedIn;
    Get.offNamed(isLoggedIn ? AppRoutes.home : AppRoutes.roleSelection);
  }
}
