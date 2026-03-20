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

    print('[AUTH][refresh] Using refresh token: ${_maskToken(refreshToken)}');

    try {
      final refreshResponse =
          await _apiServices.refreshToken(refreshTokenValue: refreshToken);

      if (refreshResponse == null || refreshResponse.isEmpty) {
        print('[AUTH][refresh] Refresh API returned empty response');
        return false;
      }

      // For debugging: show status of received tokens (without printing full value).
      final hasAccess = refreshResponse['access_token'] is String;
      final hasRefresh = refreshResponse['refresh_token'] is String;
      print(
        '[AUTH][refresh] response contains access_token=$hasAccess refresh_token=$hasRefresh',
      );

      final accessToken = (refreshResponse['access_token'] as String?)?.trim();
      final newRefreshToken = (refreshResponse['refresh_token'] as String?)?.trim();

      // Some backends return only a refresh token and expect that to be used as the
      // new access token (or simply the token used for subsequent requests).
      final effectiveToken = accessToken ?? newRefreshToken;

      if (effectiveToken == null || effectiveToken.isEmpty) {
        print('[AUTH][refresh] Refresh API did not return any usable token');
        return false;
      }

      await _sessionService.updateToken(effectiveToken);
      print('[AUTH][refresh] New effective access token: ${_maskToken(effectiveToken)}');

      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _sessionService.startSession(refreshToken: newRefreshToken);
        print('[AUTH][refresh] New refresh token stored: ${_maskToken(newRefreshToken)}');
      }

      print('[AUTH][refresh] Access token updated successfully');
      return true;
    } catch (e) {
      print('[AUTH][refresh] Error refreshing token: $e');
      return false;
    }
  }

  String _maskToken(String token) {
    const show = 6;
    if (token.length <= show * 2) return token;
    return '${token.substring(0, show)}...${token.substring(token.length - show)}';
  }
}
