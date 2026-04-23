import 'dart:async';

import 'package:azanto/Services/gym_service.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_manager.dart';
import 'package:azanto/Services/token_refresh_service.dart';
import 'package:azanto/core/auth/auth_role.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:azanto/utils/network_probe.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  SplashController({this.duration = const Duration(milliseconds: 1800)});

  final Duration duration;
  final SessionService _session = Get.find<SessionService>();
  late final GymService _gymService = GymService(sessionService: _session);
  final TokenRefreshService _tokenRefreshService = TokenRefreshService(
    sessionService: Get.find<SessionService>(),
  );
  final RxBool showOfflineState = false.obs;
  final RxBool isCheckingConnection = false.obs;

  Timer? _connectionWatcher;
  bool _navigationStarted = false;

  @override
  void onReady() {
    super.onReady();
    _startLaunchFlow();
  }

  Future<void> _startLaunchFlow() async {
    await Future<void>.delayed(duration);
    if (isClosed) {
      return;
    }
    await retryConnection();
  }

  Future<void> retryConnection() async {
    if (isClosed || _navigationStarted || isCheckingConnection.value) {
      return;
    }

    isCheckingConnection.value = true;
    final hasInternet = await NetworkProbe.hasInternetAccess();

    if (isClosed) {
      isCheckingConnection.value = false;
      return;
    }

    if (!hasInternet) {
      showOfflineState.value = true;
      isCheckingConnection.value = false;
      _ensureConnectionWatcher();
      return;
    }

    showOfflineState.value = false;
    _stopConnectionWatcher();
    _navigationStarted = true;

    final isLoggedIn = _session.isLoggedIn;
    if (isLoggedIn) {
      await _refreshAccessToken();
      try {
        await TokenRefreshManager.scheduleTokenRefresh();
      } catch (e, stack) {
        debugPrint('[AUTH] Failed to schedule token refresh in splash: $e\n$stack');
        // Continue anyway - foreground refresh will still work
      }
      final role = _session.authenticatedRole;
      if (role == AuthRole.member) {
        isCheckingConnection.value = false;
        Get.offNamed(AppRoutes.memberDashboard);
        return;
      }
      if (role != AuthRole.owner) {
        await _session.clearSession();
        isCheckingConnection.value = false;
        Get.offNamed(AppRoutes.roleSelection);
        return;
      }
      final hasGym = await _resolveOwnerHasGym();
      if (!hasGym) {
        isCheckingConnection.value = false;
        Get.offNamed(AppRoutes.gymOnboarding);
        return;
      }
    }

    isCheckingConnection.value = false;
    Get.offNamed(isLoggedIn ? AppRoutes.home : AppRoutes.roleSelection);
  }

  void _ensureConnectionWatcher() {
    _connectionWatcher ??= Timer.periodic(const Duration(seconds: 4), (
      timer,
    ) async {
      if (!showOfflineState.value || isCheckingConnection.value) {
        return;
      }

      final hasInternet = await NetworkProbe.hasInternetAccess(
        timeout: const Duration(seconds: 4),
      );
      if (!hasInternet || isClosed) {
        return;
      }

      _stopConnectionWatcher();
      await retryConnection();
    });
  }

  void _stopConnectionWatcher() {
    _connectionWatcher?.cancel();
    _connectionWatcher = null;
  }

  Future<void> _refreshAccessToken() async {
    try {
      final refreshed = await _tokenRefreshService.refreshToken();
      if (!refreshed) {
        debugPrint('[AUTH][splash] Token refresh failed on app launch');
      }
    } catch (e) {
      debugPrint('[AUTH][splash] Token refresh error: $e');
    }
  }

  Future<bool> _resolveOwnerHasGym() async {
    final storedGymId = _session.gymId?.trim() ?? '';
    if (storedGymId.isNotEmpty) {
      return true;
    }

    try {
      final gym = await _gymService.getGymForOwner();
      final gymId = (gym?['gym_id'] ?? gym?['id'])?.toString().trim() ?? '';
      return gymId.isNotEmpty;
    } catch (e) {
      debugPrint('[AUTH][splash] Could not restore owner gym state: $e');
      return false;
    }
  }

  @override
  void onClose() {
    _stopConnectionWatcher();
    super.onClose();
  }
}
