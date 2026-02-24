import 'dart:convert';

import 'package:azanto/Services/session_service.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final SessionService session = Get.find<SessionService>();
  final RxMap<String, dynamic> tokenPayload = <String, dynamic>{}.obs;
  final RxString tokenPayloadError = ''.obs;

  @override
  void onReady() {
    super.onReady();
    _loadTokenPayload();
  }

  void changeTab(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
  }

  Future<void> onLogout() async {
    await session.clearSession();
    Get.offAllNamed(AppRoutes.roleSelection);
  }

  void _loadTokenPayload() {
    final rawToken = session.token?.trim() ?? '';
    if (rawToken.isEmpty) {
      tokenPayload.clear();
      tokenPayloadError.value = 'No auth token found in session.';
      debugPrint('Home token payload: missing token');
      return;
    }

    final claims = _decodeJwtPayload(rawToken);
    if (claims == null) {
      tokenPayload.clear();
      tokenPayloadError.value =
          'Token payload could not be decoded (token may not be JWT).';
      debugPrint('Home token payload: decode failed');
      return;
    }

    tokenPayload.assignAll(claims);
    tokenPayloadError.value = '';
    debugPrint('Home token payload: $claims');
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return null;
      }

      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
