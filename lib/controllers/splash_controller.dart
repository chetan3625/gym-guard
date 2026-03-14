import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_manager.dart';
import 'package:azanto/Services/token_refresh_service.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  SplashController({this.duration = const Duration(milliseconds: 1800)});

  final Duration duration;
  final SessionService _session = Get.find<SessionService>();
  final TokenRefreshService _tokenRefreshService = TokenRefreshService(
    sessionService: Get.find<SessionService>(),
  );

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
    if (isLoggedIn) {
      await _refreshAccessToken();
      await TokenRefreshManager.scheduleTokenRefresh();
      final hasGym = (_session.gymId?.isNotEmpty ?? false);
      if (!hasGym) {
        Get.offNamed(AppRoutes.gymOnboarding);
        return;
      }
    }
    Get.offNamed(isLoggedIn ? AppRoutes.home : AppRoutes.roleSelection);
  }

  /// Attempts to refresh the access token on every app launch so the session
  /// always starts with the latest credentials.
  Future<void> _refreshAccessToken() async {
    final refreshed = await _tokenRefreshService.refreshToken();
    if (!refreshed) {
      // Keep navigation flow unchanged but log for investigation.
      // ignore: avoid_print
      print('[AUTH][splash] Token refresh failed on app launch');
    }
  }
}
