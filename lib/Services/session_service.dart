import 'package:get_storage/get_storage.dart';

/// Lightweight session store for auth state.
class SessionService {
  static const _tokenKey = 'auth_token';
  static const _loggedKey = 'is_logged_in';

  final GetStorage _box = GetStorage();

  bool get isLoggedIn {
    final isFlagSet = _box.read(_loggedKey) == true;
    final savedToken = _box.read<String>(_tokenKey) ?? '';
    return isFlagSet || savedToken.isNotEmpty;
  }

  String? get token => _box.read<String>(_tokenKey);

  Future<void> startSession({String? token}) async {
    if (token != null && token.isNotEmpty) {
      await _box.write(_tokenKey, token);
    }
    await _box.write(_loggedKey, true);
  }

  Future<void> clearSession() async {
    await _box.remove(_tokenKey);
    await _box.remove(_loggedKey);
  }
}
