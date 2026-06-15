import 'dart:convert';

import 'package:azanto/core/auth/auth_role.dart';
import 'package:get_storage/get_storage.dart';

/// Lightweight session store for auth state.
class SessionService {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _loggedKey = 'is_logged_in';
  static const _gymIdKey = 'gym_id';
  static const _branchIdKey = 'branch_id';
  static const _planIdKey = 'plan_id';
  static const _gymPromptDismissedKey = 'gym_prompt_dismissed';
  static const _roleKey = 'auth_role';
  static const _authSnapshotKey = 'last_auth_response';

  final GetStorage _box = GetStorage();

  bool get isLoggedIn {
    final savedToken = normalizedToken;
    return savedToken != null && savedToken.isNotEmpty;
  }

  String? get token => _box.read<String>(_tokenKey);
  String? get refreshToken => _box.read<String>(_refreshTokenKey);
  String? get gymId => _box.read<String>(_gymIdKey);
  String? get branchId => _box.read<String>(_branchIdKey);
  String? get planId => _box.read<String>(_planIdKey);
  bool get isGymPromptDismissed => _box.read(_gymPromptDismissedKey) == true;
  String? get authenticatedRole {
    final storedRole = AuthRole.normalize(_box.read<String>(_roleKey));
    if (storedRole != null) {
      return storedRole;
    }

    final snapshotRole = AuthRole.extractFromPayload(lastAuthResponse);
    if (snapshotRole != null) {
      return snapshotRole;
    }

    return _roleFromToken(token);
  }

  bool get isOwner => authenticatedRole == AuthRole.owner;
  bool get isMember => authenticatedRole == AuthRole.member;
  Map<String, dynamic>? get lastAuthResponse {
    final stored = _box.read(_authSnapshotKey);
    if (stored is Map<String, dynamic>) return stored;
    if (stored is Map) return Map<String, dynamic>.from(stored);
    return null;
  }

  Map<String, dynamic>? get tokenClaims => _decodeJwtPayload(token);

  String? get normalizedToken => _normalizeAccessToken(token);
  String? get bearerToken {
    final normalized = normalizedToken;
    if (normalized == null || normalized.isEmpty) return null;
    return 'Bearer $normalized';
  }

  Future<void> startSession({
    String? token,
    String? refreshToken,
    String? role,
    Map<String, dynamic>? authResponse,
  }) async {
    final normalizedToken = _normalizeAccessToken(token);
    if (normalizedToken != null && normalizedToken.isNotEmpty) {
      await _box.write(_tokenKey, normalizedToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _box.write(_refreshTokenKey, refreshToken);
    }
    final normalizedRole =
        AuthRole.normalize(role) ?? AuthRole.extractFromPayload(authResponse);
    if (normalizedRole != null) {
      await _box.write(_roleKey, normalizedRole);
      await _box.write('selected_role', normalizedRole);
    }
    if (authResponse != null) {
      await _box.write(
        _authSnapshotKey,
        _sanitizeAuthResponse(
          authResponse,
          fallbackRole: normalizedRole ?? authenticatedRole,
        ),
      );
    }
    await _box.write(_loggedKey, true);
  }

  Future<void> updateToken(String newToken) async {
    final normalizedToken = _normalizeAccessToken(newToken);
    if (normalizedToken == null || normalizedToken.isEmpty) return;
    await _box.write(_tokenKey, normalizedToken);
  }

  Future<void> clearSession() async {
    await _box.remove(_tokenKey);
    await _box.remove(_refreshTokenKey);
    await _box.remove(_loggedKey);
    await _box.remove(_gymIdKey);
    await _box.remove(_branchIdKey);
    await _box.remove(_planIdKey);
    await _box.remove(_gymPromptDismissedKey);
    await _box.remove(_roleKey);
    await _box.remove(_authSnapshotKey);
  }

  Future<void> setGymId(String? gymId) async {
    if (gymId == null || gymId.trim().isEmpty) return;
    await _box.write(_gymIdKey, gymId.trim());
  }

  Future<void> setBranchId(String? branchId) async {
    if (branchId == null || branchId.trim().isEmpty) return;
    await _box.write(_branchIdKey, branchId.trim());
  }

  Future<void> setPlanId(String? planId) async {
    if (planId == null || planId.trim().isEmpty) return;
    await _box.write(_planIdKey, planId.trim());
  }

  Future<void> setGymPromptDismissed(bool dismissed) async {
    await _box.write(_gymPromptDismissedKey, dismissed);
  }

  String? _normalizeAccessToken(String? rawToken) {
    if (rawToken == null) return null;

    var trimmed = rawToken.trim();
    if (trimmed.isEmpty) return null;

    // Normalize bearer prefix regardless of case (e.g., "Bearer ", "bearer ").
    const bearerPrefixLower = 'bearer ';
    if (trimmed.toLowerCase().startsWith(bearerPrefixLower)) {
      trimmed = trimmed.substring(bearerPrefixLower.length).trim();
    }

    return trimmed.isEmpty ? null : trimmed;
  }

  Map<String, dynamic> _sanitizeAuthResponse(
    Map<String, dynamic> response, {
    String? fallbackRole,
  }) {
    final snapshot = <String, dynamic>{};

    final status = response['status'];
    if (status != null) {
      snapshot['status'] = status.toString();
    }

    final message = response['message'];
    if (message != null) {
      snapshot['message'] = message.toString();
    }

    final resolvedRole = AuthRole.extractFromPayload(response) ?? fallbackRole;
    if (resolvedRole != null) {
      snapshot['role'] = resolvedRole;
    }

    for (final key in const [
      'gym_id',
      'gymId',
      'branch_id',
      'branchId',
      'plan_id',
      'planId',
      'user_id',
      'userId',
      'member_id',
      'memberId',
      'payment_id',
      'paymentId',
      'transaction_id',
      'transactionId',
    ]) {
      final value = response[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        snapshot[key] = value;
      }
    }

    for (final key in const ['user', 'member', 'membership', 'plan']) {
      final value = response[key];
      if (value is Map) {
        snapshot[key] = Map<String, dynamic>.from(value);
      }
    }

    return snapshot;
  }

  String? _roleFromToken(String? rawToken) {
    final normalized = _normalizeAccessToken(rawToken);
    if (normalized == null || normalized.isEmpty) return null;

    try {
      final parts = normalized.split('.');
      if (parts.length < 2) {
        return null;
      }

      final decoded = _decodeJwtPayload(normalized);
      return AuthRole.extractFromPayload(decoded);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _decodeJwtPayload(String? rawToken) {
    final normalized = _normalizeAccessToken(rawToken);
    if (normalized == null || normalized.isEmpty) return null;

    try {
      final parts = normalized.split('.');
      if (parts.length < 2) return null;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
    return null;
  }
}
