import 'dart:convert';

import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:workmanager/workmanager.dart';

const String tokenRefreshTask = 'tokenRefreshTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await GetStorage.init();
      print('Workmanager task started: $task');
      final sessionService = SessionService();
      final tokenService = TokenRefreshService(sessionService: sessionService);
      final success = await tokenService.refreshToken();

      if (success) {
        final rawToken = sessionService.token?.trim();

        if (rawToken == null || rawToken.isEmpty) {
          print('Background token refresh: token missing after refresh');
        } else {
          print('Token (bg): $rawToken');
          final payload = _decodeJwtPayload(rawToken);
          if (payload != null) {
            print('Token payload (bg): $payload');
          } else {
            print('Background token refresh: could not decode token payload');
          }
        }
      }
      return success;
    } catch (e) {
      print("Background task error: $e");
      return false;
    }
  });
}

class TokenRefreshManager {
  static bool _initialized = false;
  // Toggle background refresh. Set to true when backend refresh endpoint is available.
  static const bool _refreshEnabled = true;

  static Future<void> initialize() async {
    if (_initialized) return;
    await Workmanager().initialize(callbackDispatcher);
    _initialized = true;
  }

  static Future<void> scheduleTokenRefresh() async {
    if (!_refreshEnabled) {
      await cancelTokenRefresh();
      return;
    }
    await initialize();
    await Workmanager().cancelByUniqueName(tokenRefreshTask);
    await Workmanager().registerPeriodicTask(
      tokenRefreshTask,
      tokenRefreshTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
    );
  }

  static Future<void> cancelTokenRefresh() async {
    await Workmanager().cancelByUniqueName(tokenRefreshTask);
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
