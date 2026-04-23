import 'dart:convert';

import 'package:azanto/Services/token_refresh_service.dart';
import 'package:azanto/core/auth/auth_refresh_coordinator.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:workmanager/workmanager.dart';

const String tokenRefreshTask = 'tokenRefreshTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await GetStorage.init();
      debugPrint('[AUTH][WorkManager] Task started: $task');
      final sessionService = SessionService();
      final tokenService = TokenRefreshService(sessionService: sessionService);

      // TokenRefreshService already owns cooldown + lock coordination.
      final success = await tokenService.refreshToken();

      if (success) {
        final rawToken = sessionService.token?.trim();
        if (rawToken != null && rawToken.isNotEmpty) {
          debugPrint('[AUTH][WorkManager] Token refreshed successfully');
          final payload = _decodeJwtPayload(rawToken);
          if (payload != null) {
            debugPrint('[AUTH][WorkManager] Token payload: $payload');
          }
        } else {
          debugPrint('[AUTH][WorkManager] Token missing after refresh');
        }
      } else {
        debugPrint('[AUTH][WorkManager] Token refresh failed');
        // If the session was cleared (e.g., due to 401 Unauthorized),
        // there is no token left to retry with. Return true to stop WorkManager
        // from uselessly retrying.
        final currentRefresh = sessionService.refreshToken?.trim() ?? '';
        if (currentRefresh.isEmpty) {
          debugPrint('[AUTH][WorkManager] No refresh token left, cancelling retries.');
          return true;
        }
      }

      return success;
    } catch (e, stack) {
      debugPrint("[AUTH][WorkManager] Background task error: $e\n$stack");
      return false; // Retry on actual exceptions (like network failures)
    }
  });
}

class TokenRefreshManager {
  static bool _initialized = false;
  static bool _initializationFailed = false;
  static const bool _refreshEnabled = true;

  /// Initialize WorkManager. Must be called before scheduling tasks.
  static Future<void> initialize() async {
    if (_initialized || _initializationFailed) return;
    try {
      await Workmanager().initialize(callbackDispatcher);
      _initialized = true;
      debugPrint('[AUTH][WorkManager] Initialized successfully');
    } catch (e, stack) {
      debugPrint('[AUTH][WorkManager] Initialization failed: $e\n$stack');
      _initializationFailed = true;
      rethrow; // Let the app know initialization failed
    }
  }

  /// Schedule periodic token refresh every 10 minutes.
  /// Calls to this method will cancel any existing scheduled refresh first.
  static Future<void> scheduleTokenRefresh() async {
    if (!_refreshEnabled) {
      await cancelTokenRefresh();
      return;
    }

    // Ensure WorkManager is initialized
    await initialize();

    // Cancel any existing task
    await Workmanager().cancelByUniqueName(tokenRefreshTask);

    // Register new periodic task with 10-minute frequency
    await Workmanager().registerPeriodicTask(
      tokenRefreshTask,
      tokenRefreshTask,
      frequency: const Duration(minutes: 10),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
    );

    debugPrint('[AUTH][WorkManager] Scheduled token refresh every 10 minutes');
  }

  /// Cancel the periodic token refresh task.
  static Future<void> cancelTokenRefresh() async {
    await Workmanager().cancelByUniqueName(tokenRefreshTask);
    debugPrint('[AUTH][WorkManager] Cancelled token refresh task');
  }

  /// Clear all token refresh state (call on logout).
  static Future<void> clearState() async {
    final box = GetStorage();
    await AuthRefreshCoordinator.clearState(box);
    await cancelTokenRefresh();
    debugPrint('[AUTH][WorkManager] Cleared all state');
  }
}

Map<String, dynamic>? _decodeJwtPayload(String token) {
  try {
    final parts = token.split('.');
    if (parts.length < 2) return null;

    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    final decoded = jsonDecode(payload);

    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return null;
  } catch (_) {
    return null;
  }
}
