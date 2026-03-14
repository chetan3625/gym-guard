import 'dart:convert';

import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_service.dart';
import 'package:azanto/core/config/global_variables.dart';
import 'package:http/http.dart' as http;

class GymService {
  GymService({SessionService? sessionService, http.Client? client})
    : _sessionService = sessionService ?? SessionService(),
      _client = client ?? http.Client();

  final SessionService _sessionService;
  final http.Client _client;

  /// Creates a gym for the authenticated owner.
  ///
  /// Throws [ApiException] when the request fails.
  Future<Map<String, dynamic>> createGym({
    required String name,
    required String email,
    required bool isActive,
  }) async {
    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    http.Response response = await _postCreateGym(
      token: token,
      name: name,
      email: email,
      isActive: isActive,
    );

    // If token expired/invalid, try once with a refreshed token.
    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await _postCreateGym(
          token: newToken,
          name: name,
          email: email,
          isActive: isActive,
        );
      }
    }

    final decoded = _decodeResponseBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map) {
        final map = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded);
        final gymId = map['id']?.toString();
        if (gymId != null && gymId.isNotEmpty) {
          await _sessionService.setGymId(gymId);
        }
        return map;
      }
      return <String, dynamic>{'message': 'Gym created successfully'};
    }

    // Log raw error for debugging.
    print(
      'Create gym failed (${response.statusCode}): '
      '${response.body.isNotEmpty ? response.body : 'no body'}',
    );

    if (_isAuthError(response.statusCode)) {
      throw ApiException(
        'Session expired. Please log in again.',
        statusCode: response.statusCode,
        detail: _extractDetail(decoded),
      );
    }

    throw ApiException(
      _extractMessage(
        decoded,
        fallback: response.body.trim().isNotEmpty
            ? response.body.trim()
            : 'Unable to create gym',
      ),
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

  dynamic _decodeResponseBody(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _extractMessage(dynamic payload, {required String fallback}) {
    if (payload is Map && payload['message'] is String) {
      return payload['message'] as String;
    }
    if (payload is Map && payload['detail'] is String) {
      return payload['detail'] as String;
    }
    if (payload is Map && payload['detail'] is List) {
      final details = payload['detail'] as List;
      final msgs = details
          .whereType<Map>()
          .map((m) => m['msg'])
          .whereType<String>()
          .toList();
      if (msgs.isNotEmpty) return msgs.join('\n');
    }
    if (payload is String && payload.trim().isNotEmpty) {
      return payload.trim();
    }
    return fallback;
  }

  dynamic _extractDetail(dynamic payload) {
    if (payload is Map && payload.containsKey('detail')) {
      return payload['detail'];
    }
    return null;
  }

  Future<http.Response> _postCreateGym({
    required String token,
    required String name,
    required String email,
    required bool isActive,
  }) {
    return _client.post(
      Uri.parse(GymApiEndpoints.createGym),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'email': email,
        // Send both snake_case and camelCase for maximum backend compatibility.
        'is_active': isActive,
        'isActive': isActive,
      }),
    );
  }

  bool _isAuthError(int statusCode) => statusCode == 401 || statusCode == 403;
}
