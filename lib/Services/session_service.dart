import 'package:get_storage/get_storage.dart';

/// Lightweight session store for auth state.
class SessionService {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _loggedKey = 'is_logged_in';
  static const _gymIdKey = 'gym_id';
  static const _gymPromptDismissedKey = 'gym_prompt_dismissed';

  final GetStorage _box = GetStorage();

  bool get isLoggedIn {
    final isFlagSet = _box.read(_loggedKey) == true;
    final savedToken = _box.read<String>(_tokenKey) ?? '';
    return isFlagSet || savedToken.isNotEmpty;
  }

  String? get token => _box.read<String>(_tokenKey);
  String? get refreshToken => _box.read<String>(_refreshTokenKey);
  String? get gymId => _box.read<String>(_gymIdKey);
  bool get isGymPromptDismissed => _box.read(_gymPromptDismissedKey) == true;
  String? get normalizedToken => _normalizeAccessToken(token);
  String? get bearerToken {
    final normalized = normalizedToken;
    if (normalized == null || normalized.isEmpty) return null;
    return 'Bearer $normalized';
  }

  Future<void> startSession({String? token, String? refreshToken}) async {
    final normalizedToken = _normalizeAccessToken(token);
    if (normalizedToken != null && normalizedToken.isNotEmpty) {
      await _box.write(_tokenKey, normalizedToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _box.write(_refreshTokenKey, refreshToken);
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
    await _box.remove(_gymPromptDismissedKey);
  }

  Future<void> setGymId(String? gymId) async {
    if (gymId == null || gymId.trim().isEmpty) return;
    await _box.write(_gymIdKey, gymId.trim());
  }

  Future<void> setGymPromptDismissed(bool dismissed) async {
    await _box.write(_gymPromptDismissedKey, dismissed);
  }

  String? _normalizeAccessToken(String? rawToken) {
    if (rawToken == null) return null;
    final trimmed = rawToken.trim();
    if (trimmed.isEmpty) return null;
    const bearerPrefix = 'Bearer ';
    if (trimmed.startsWith(bearerPrefix)) {
      final stripped = trimmed.substring(bearerPrefix.length).trim();
      return stripped.isEmpty ? null : stripped;
    }
    return trimmed;
  }
}
