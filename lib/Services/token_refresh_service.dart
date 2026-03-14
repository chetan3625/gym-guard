import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';

class TokenRefreshService {
  TokenRefreshService({
    SessionService? sessionService,
    ApiServices? apiServices,
  }) : _sessionService = sessionService ?? SessionService(),
       _apiServices = apiServices ?? ApiServices();

  final SessionService _sessionService;
  final ApiServices _apiServices;

  Future<bool> refreshToken() async {
    final refreshToken = _sessionService.refreshToken?.trim();
    if (refreshToken == null || refreshToken.isEmpty) {
      print('[AUTH][refresh] No refresh token available');
      return false;
    }

    try {
      final newAccessToken =
          await _apiServices.refreshToken(refreshTokenValue: refreshToken);

      if (newAccessToken == null || newAccessToken.trim().isEmpty) {
        print('[AUTH][refresh] Refresh API returned empty token');
        return false;
      }

      await _sessionService.updateToken(newAccessToken);
      print('[AUTH][refresh] Access token updated successfully');
      return true;
    } catch (e) {
      print('[AUTH][refresh] Error refreshing token: $e');
      return false;
    }
  }
}
