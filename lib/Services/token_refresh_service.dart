import 'dart:async';

import 'package:azanto/Services/login_services.dart' show ApiServices;
import 'package:azanto/core/auth/auth_refresh_coordinator.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Service for refreshing access tokens.
/// Uses a unified coordination mechanism to prevent conflicts with
/// background WorkManager token refresh tasks.
class TokenRefreshService {
  TokenRefreshService({
    SessionService? sessionService,
    ApiServices? apiServices,
  }) : _sessionService = sessionService ?? Get.find<SessionService>(),
       _apiServices = apiServices ?? ApiServices();

  final SessionService _sessionService;
  final ApiServices _apiServices;

  /// Refreshes the access token using the refresh token.
  /// This method is safe to call from both foreground and background contexts.
  /// Returns true if refresh was successful (or not needed), false if failed.
  Future<bool> refreshToken() async {
    final box = GetStorage();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Check if we're within cooldown period after last successful refresh
    if (AuthRefreshCoordinator.isWithinCooldown(box, now: now)) {
      debugPrint(
          '[AUTH][refresh] Within cooldown period (${now - AuthRefreshCoordinator.getLastRefreshTimestamp(box)}ms), skipping');
      return true; // Token is still valid, no need to refresh
    }

    // Wait for any in-progress refresh to complete (max 2 minutes)
    try {
      await AuthRefreshCoordinator.waitForCompletion(box,
          timeout: const Duration(milliseconds: AuthRefreshCoordinator.lockTimeoutMs));
    } catch (e) {
      debugPrint('[AUTH][refresh] Timeout waiting for lock: $e');
      return false;
    }

    // Try to acquire lock
    final initiatedAt = now;
    final lockAcquired = await AuthRefreshCoordinator.tryAcquireLock(box, initiatedAt);
    if (!lockAcquired) {
      debugPrint('[AUTH][refresh] Lock held by another process, skipping');
      return false; // Another process is handling it
    }

    try {
      final refreshToken = _sessionService.refreshToken?.trim();
      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('[AUTH][refresh] No refresh token available');
        return false;
      }

      debugPrint('[AUTH][refresh] Acquired lock, attempting refresh');

      final refreshResponse =
          await _apiServices.refreshToken(refreshTokenValue: refreshToken);

      if (refreshResponse == null || refreshResponse.isEmpty) {
        debugPrint('[AUTH][refresh] Refresh API returned empty response');
        return false;
      }

      // Check for 401 error response
      if (refreshResponse['_error'] == 'unauthorized') {
        debugPrint('[AUTH][refresh] 401 - Token is invalid/expired, clearing session');
        await _sessionService.clearSession();
        return false;
      }

      final hasAccess = refreshResponse['access_token'] is String;
      final hasRefresh = refreshResponse['refresh_token'] is String;
      debugPrint(
          '[AUTH][refresh] response contains access_token=$hasAccess refresh_token=$hasRefresh');

      final accessToken = (refreshResponse['access_token'] as String?)?.trim();
      final newRefreshToken = (refreshResponse['refresh_token'] as String?)?.trim();

      final effectiveToken = accessToken ?? newRefreshToken;

      if (effectiveToken == null || effectiveToken.isEmpty) {
        debugPrint('[AUTH][refresh] Refresh API did not return any usable token');
        return false;
      }

      await _sessionService.updateToken(effectiveToken);
      debugPrint('[AUTH][refresh] Token updated successfully');

      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _sessionService.startSession(refreshToken: newRefreshToken);
        debugPrint('[AUTH][refresh] New refresh token stored');
      }

      // Update last refresh timestamp on success
      await AuthRefreshCoordinator.setLastRefreshTimestamp(
          box, DateTime.now().millisecondsSinceEpoch);
      debugPrint('[AUTH][refresh] Completed successfully');

      return true;
    } catch (e, stack) {
      debugPrint('[AUTH][refresh] Error refreshing token: $e\n$stack');
      return false;
    } finally {
      // Always release lock
      await AuthRefreshCoordinator.releaseLock(box);
    }
  }
}
