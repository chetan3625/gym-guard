import 'dart:convert';
import 'dart:typed_data';

import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_service.dart';
import 'package:azanto/core/config/global_variables.dart';
import 'package:azanto/models/profile_model.dart';
import 'package:azanto/utils/api_response_logger.dart';
import 'package:http/http.dart' as http;

class AvatarPayload {
  const AvatarPayload({this.bytes, this.url});

  final Uint8List? bytes;
  final String? url;

  bool get hasData => bytes != null || (url?.trim().isNotEmpty ?? false);
}

class ProfileService {
  ProfileService({SessionService? sessionService})
      : _sessionService = sessionService ?? SessionService();

  final SessionService _sessionService;

  Future<ProfileModel> getProfile() async {
    final authorization = _requireAuthorizationHeader();
    http.Response response = await http.get(
      Uri.parse(MemberProfileApiEndpoints.getProfile),
      headers: _jsonHeaders(authorization),
    );

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newAuthorization = _sessionService.bearerToken?.trim() ?? '';
      if (refreshed && newAuthorization.isNotEmpty) {
        response = await http.get(
          Uri.parse(MemberProfileApiEndpoints.getProfile),
          headers: _jsonHeaders(newAuthorization),
        );
      }
    }

    final decoded = _decodeResponseBody(response.body);
    ApiResponseLogger.logResponse('Get Profile API', response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ProfileModel.fromJson(_normalizeProfileData(_extractMap(decoded)));
    }

    throw ApiException(
      _extractMessage(decoded, fallback: 'Unable to fetch profile'),
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

  Future<ProfileModel> updateProfile(
      Map<String, dynamic> profilePayload) async {
    final authorization = _requireBearerAuthorizationHeader();
    http.Response response = await http.patch(
      Uri.parse(MemberProfileApiEndpoints.updateProfile),
      headers: _jsonHeaders(authorization),
      body: jsonEncode(profilePayload),
    );

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newAuthorization = _sessionService.bearerToken?.trim() ?? '';
      if (refreshed && newAuthorization.isNotEmpty) {
        response = await http.patch(
          Uri.parse(MemberProfileApiEndpoints.updateProfile),
          headers: _jsonHeaders(newAuthorization),
          body: jsonEncode(profilePayload),
        );
      }
    }

    final decoded = _decodeResponseBody(response.body);
    ApiResponseLogger.logResponse('Update Profile API', response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseMap = _extractMap(decoded);
      if (responseMap.isEmpty) {
        return ProfileModel.fromJson(profilePayload);
      }
      return ProfileModel.fromJson(
        _normalizeProfileData({
          ...profilePayload,
          ...responseMap,
        }),
      );
    }

    throw ApiException(
      _extractMessage(decoded, fallback: 'Unable to update profile'),
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

  Future<String> uploadAvatar({required String filePath}) async {
    final authorization = _requireAuthorizationHeader();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(MemberProfileApiEndpoints.uploadAvatar),
    );
    request.headers['Authorization'] = authorization;
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final decoded = _decodeResponseBody(response.body);
    ApiResponseLogger.logResponse(
      'Upload Avatar API',
      response,
      uri: request.url,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _extractMessage(decoded, fallback: 'Avatar uploaded');
    }

    throw ApiException(
      _extractMessage(decoded, fallback: 'Unable to upload avatar'),
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

  Future<AvatarPayload> getAvatar() async {
    final authorization = _requireAuthorizationHeader();
    final response = await http.get(
      Uri.parse(MemberProfileApiEndpoints.getAvatar),
      headers: {'Authorization': authorization},
    );
    ApiResponseLogger.logResponse('Get Avatar API', response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = _decodeResponseBody(response.body);
      throw ApiException(
        _extractMessage(decoded, fallback: 'Unable to fetch avatar'),
        statusCode: response.statusCode,
        detail: _extractDetail(decoded),
      );
    }

    final contentType = response.headers['content-type'] ?? '';
    if (contentType.startsWith('image/')) {
      return AvatarPayload(bytes: response.bodyBytes);
    }

    final decoded = _decodeResponseBody(response.body);
    if (decoded is String && decoded.trim().isNotEmpty) {
      return AvatarPayload(url: _normalizeAvatarUrl(decoded.trim()));
    }
    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      final urlCandidate = map['url'] ??
          map['avatar'] ??
          map['avatar_url'] ??
          map['image'] ??
          map['data'];
      if (urlCandidate is String && urlCandidate.trim().isNotEmpty) {
        return AvatarPayload(url: _normalizeAvatarUrl(urlCandidate.trim()));
      }
    }

    return const AvatarPayload();
  }

  String _requireAuthorizationHeader() {
    final authorization = _sessionService.bearerToken?.trim() ?? '';
    if (authorization.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }
    return authorization;
  }

  String _requireBearerAuthorizationHeader() {
    final normalizedToken = _sessionService.normalizedToken?.trim() ?? '';
    if (normalizedToken.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }
    return 'Bearer $normalizedToken';
  }

  Map<String, String> _jsonHeaders(String authorization) {
    return <String, String>{
      'Authorization': authorization,
      'Content-Type': 'application/json',
    };
  }

  dynamic _decodeResponseBody(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) return payload;
    if (payload is Map) return Map<String, dynamic>.from(payload);
    if (payload is String) {
      try {
        final decoded = jsonDecode(payload);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        return <String, dynamic>{};
      }
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _normalizeProfileData(Map<String, dynamic> payload) {
    if (payload['data'] is Map) {
      return Map<String, dynamic>.from(payload['data'] as Map);
    }
    if (payload['profile'] is Map) {
      return Map<String, dynamic>.from(payload['profile'] as Map);
    }
    return payload;
  }

  String _extractMessage(dynamic payload, {required String fallback}) {
    if (payload is String && payload.trim().isNotEmpty) {
      return payload.trim();
    }
    if (payload is Map && payload['message'] is String) {
      return payload['message'] as String;
    }
    if (payload is Map && payload['detail'] is String) {
      return payload['detail'] as String;
    }
    if (payload is Map &&
        payload['detail'] is List &&
        payload['detail'].isNotEmpty &&
        payload['detail'][0] is Map &&
        payload['detail'][0]['msg'] is String) {
      return payload['detail'][0]['msg'] as String;
    }
    return fallback;
  }

  dynamic _extractDetail(dynamic payload) {
    if (payload is Map && payload.containsKey('detail')) {
      return payload['detail'];
    }
    return payload;
  }

  String _normalizeAvatarUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return '${GlobalVariables.apiHost}$trimmed';
    }
    return '${GlobalVariables.apiHost}/$trimmed';
  }

  bool _isAuthError(int statusCode) => statusCode == 401 || statusCode == 403;
}
