import 'dart:convert';

import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_service.dart';
import 'package:azanto/core/config/global_variables.dart';
import 'package:azanto/models/gym_model.dart';
import 'package:azanto/utils/api_response_logger.dart';
import 'package:flutter/foundation.dart';
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
    ApiResponseLogger.logResponse('Create Gym API', response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map) {
        final map = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded);
        final gymId = (map['gym_id'] ?? map['id'])?.toString();
        if (gymId != null && gymId.isNotEmpty) {
          await _sessionService.setGymId(gymId);
        }
        return map;
      }
      return <String, dynamic>{'message': 'Gym created successfully'};
    }

    // Log raw error for debugging.
    debugPrint(
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

  /// Returns the first gym record for the authenticated owner, or null if none.
  Future<Map<String, dynamic>?> getGymForOwner() async {
    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    http.Response response = await _getGym(token: token);

    // Retry after refresh if auth error.
    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await _getGym(token: newToken);
      }
    }

    final decoded = _decodeResponseBody(response.body);
    ApiResponseLogger.logResponse('Get Gym API', response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Backend may return a single map or a list of maps.
      Map<String, dynamic>? map;
      if (decoded is Map) {
        map = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded);
      } else if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map) {
          map = first is Map<String, dynamic>
              ? first
              : Map<String, dynamic>.from(first);
        }
      }

      if (map != null) {
        final gymId = (map['gym_id'] ?? map['id'])?.toString();
        if (gymId != null && gymId.isNotEmpty) {
          await _sessionService.setGymId(gymId);
        }
        if (kDebugMode) {
          debugPrint('[GYM] getGym response: $map');
        }
        return map;
      }
      return null;
    }

    // Log raw error for debugging.
    debugPrint(
      'Get gym failed (${response.statusCode}): '
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
            : 'Unable to fetch gym',
      ),
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

  Future<GymModel> getGymDetails() async {
    final gym = await getGymForOwner();
    if (gym == null) {
      throw ApiException('No gym details found for this owner.');
    }
    return GymModel.fromJson(gym);
  }

  Future<String?> getGymLogo({required String gymId}) async {
    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    http.Response response = await _getGymLogo(
      token: token,
      gymId: gymId,
    );

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await _getGymLogo(
          token: newToken,
          gymId: gymId,
        );
      }
    }

    final decoded = _decodeResponseBody(response.body);
    ApiResponseLogger.logResponse('Get Gym Logo API', response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map && decoded['logo_url'] is String) {
        final logoUrl = (decoded['logo_url'] as String).trim();
        return logoUrl.isEmpty ? null : logoUrl;
      }
      return null;
    }

    throw ApiException(
      _extractMessage(decoded, fallback: 'Unable to fetch gym logo'),
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

  Future<GymModel> updateGymDetails({
    required String id,
    required String name,
    required String email,
    required String? description,
    required bool isActive,
  }) async {
    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    http.Response response = await _patchUpdateGym(
      token: token,
      id: id,
      name: name,
      email: email,
      description: description,
      isActive: isActive,
    );

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await _patchUpdateGym(
          token: newToken,
          id: id,
          name: name,
          email: email,
          description: description,
          isActive: isActive,
        );
      }
    }

    final decoded = _decodeResponseBody(response.body);
    ApiResponseLogger.logResponse('Update Gym API', response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return GymModel.fromJson(<String, dynamic>{
          ...decoded,
          'id': id,
          'is_active': isActive,
        });
      }
      if (decoded is Map) {
        return GymModel.fromJson(<String, dynamic>{
          ...Map<String, dynamic>.from(decoded),
          'id': id,
          'is_active': isActive,
        });
      }
      return GymModel(
        id: id,
        name: name,
        email: email,
        description: description,
        isActive: isActive,
      );
    }

    throw ApiException(
      _extractMessage(decoded, fallback: 'Unable to update gym details'),
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

  Future<String> uploadGymLogo({
    required String gymId,
    required String filePath,
  }) async {
    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    http.Response response = await _postUploadGymLogo(
      token: token,
      gymId: gymId,
      filePath: filePath,
    );

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await _postUploadGymLogo(
          token: newToken,
          gymId: gymId,
          filePath: filePath,
        );
      }
    }

    final decoded = _decodeResponseBody(response.body);
    ApiResponseLogger.logResponse('Upload Gym Logo API', response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map && decoded['logo_url'] is String) {
        return (decoded['logo_url'] as String).trim();
      }
      throw ApiException(
        _extractMessage(decoded, fallback: 'Logo uploaded but URL missing'),
        statusCode: response.statusCode,
        detail: _extractDetail(decoded),
      );
    }

    throw ApiException(
      _extractMessage(decoded, fallback: 'Unable to upload gym logo'),
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

  Future<http.Response> _getGym({required String token}) {
    return _client.get(
      Uri.parse(GymApiEndpoints.getGym),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<http.Response> _patchUpdateGym({
    required String token,
    required String id,
    required String name,
    required String email,
    required String? description,
    required bool isActive,
  }) {
    return _client.patch(
      Uri.parse('${GymApiEndpoints.updateGym}/$id'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'id': id,
        'name': name,
        'email': email,
        'description': description,
        'is_active': isActive,
      }),
    );
  }

  Future<http.Response> _getGymLogo({
    required String token,
    required String gymId,
  }) {
    return _client.get(
      Uri.parse('${GymApiEndpoints.getLogo}/$gymId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      },
    );
  }

  Future<http.Response> _postUploadGymLogo({
    required String token,
    required String gymId,
    required String filePath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${GymApiEndpoints.uploadLogo}/$gymId'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['accept'] = 'application/json';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }

  bool _isAuthError(int statusCode) => statusCode == 401 || statusCode == 403;
}
