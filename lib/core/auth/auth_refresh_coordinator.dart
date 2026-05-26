import 'package:get_storage/get_storage.dart';

/// Unified constants and utilities for token refresh coordination
/// between foreground app and WorkManager background tasks.
class AuthRefreshCoordinator {
  // Storage keys
  static const String _lastRefreshTimestampKey = 'auth_last_refresh_timestamp';
  static const String _refreshInProgressKey = 'auth_refresh_in_progress';
  static const String _refreshInitiatedKey = 'auth_refresh_initiated_at';

  // Timing constants
  static const int refreshIntervalMinutes = 10;
  static const int refreshIntervalMs = refreshIntervalMinutes * 60 * 1000;
  static const int lockTimeoutMs = 2 * 60 * 1000; // 2 minutes max wait for lock
  static const int lockLeewayMs = 5 * 1000; // 5s leeway for clock skew
  static const int minTimeBetweenAttemptsMs = 30 * 1000; // 30s minimum between attempts

  /// Get the last successful refresh timestamp.
  static int getLastRefreshTimestamp(GetStorage box) {
    return box.read<int>(_lastRefreshTimestampKey) ?? 0;
  }

  /// Set the last successful refresh timestamp.
  static Future<void> setLastRefreshTimestamp(GetStorage box, int timestamp) async {
    await box.write(_lastRefreshTimestampKey, timestamp);
  }

  /// Check if we're within the cooldown period after a successful refresh.
  static bool isWithinCooldown(GetStorage box, {int? now}) {
    final currentTime = now ?? DateTime.now().millisecondsSinceEpoch;
    final lastRefresh = getLastRefreshTimestamp(box);
    final elapsed = currentTime - lastRefresh;
    return elapsed < (refreshIntervalMs - lockLeewayMs);
  }

  /// Try to acquire the refresh lock.
  /// Returns true if lock was acquired, false if another process holds it.
  static Future<bool> tryAcquireLock(GetStorage box, int initiatedAt) async {
    final existingInitiated = box.read<int>(_refreshInitiatedKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    // If no lock exists, or existing lock is stale (older than 2 minutes)
    if (existingInitiated == null || now - existingInitiated > lockTimeoutMs) {
      await box.write(_refreshInProgressKey, true);
      await box.write(_refreshInitiatedKey, initiatedAt);
      return true;
    }

    // Lock is held by another process
    return false;
  }

  /// Release the refresh lock.
  static Future<void> releaseLock(GetStorage box) async {
    await box.remove(_refreshInProgressKey);
    await box.remove(_refreshInitiatedKey);
  }

  /// Force release lock (use only in emergency cleanup).
  static Future<void> forceReleaseLock(GetStorage box) async {
    await box.write(_refreshInProgressKey, false);
    await box.remove(_refreshInitiatedKey);
    await box.remove(_lastRefreshTimestampKey);
  }

  /// Check if a refresh is currently in progress (by any isolate/process).
  static bool isRefreshInProgress(GetStorage box) {
    final isLocked = box.read<bool>(_refreshInProgressKey) ?? false;
    if (!isLocked) return false;

    final initiatedAt = box.read<int>(_refreshInitiatedKey);
    if (initiatedAt == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    return now - initiatedAt <= lockTimeoutMs;
  }

  /// Wait until any ongoing refresh completes, with timeout.
  static Future<void> waitForCompletion(GetStorage box,
      {Duration? timeout}) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    final timeoutMs = timeout?.inMilliseconds ?? lockTimeoutMs;

    while (true) {
      if (!isRefreshInProgress(box)) {
        return;
      }

      final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;
      if (elapsed > timeoutMs) {
        throw const TimeoutException(
            'Timed out waiting for token refresh to complete');
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Clear all auth refresh state (call on logout).
  static Future<void> clearState(GetStorage box) async {
    await box.remove(_lastRefreshTimestampKey);
    await box.remove(_refreshInProgressKey);
    await box.remove(_refreshInitiatedKey);
  }
}

/// Simple timeout exception
class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);
  @override
  String toString() => 'TimeoutException: $message';
}
