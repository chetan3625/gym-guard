import 'dart:convert';

import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_service.dart';
import 'package:azanto/core/config/api_constant.dart';
import 'package:azanto/models/attendance_model.dart';
import 'package:azanto/utils/api_response_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AttendanceService {
  AttendanceService({SessionService? sessionService, http.Client? client})
      : _sessionService = sessionService ?? Get.find<SessionService>(),
        _client = client ?? http.Client();

  final SessionService _sessionService;
  final http.Client _client;

  Future<AttendanceModel> checkIn({
    required String gymId,
    required String branchId,
  }) {
    return _submitAttendance(
      endpoint: AttendanceApiEndpoints.checkIn,
      logName: 'Attendance Checkin API',
      fallbackMessage: 'Unable to check in',
      gymId: gymId,
      branchId: branchId,
    );
  }

  Future<AttendanceModel> checkOut({
    required String gymId,
    required String branchId,
  }) {
    return _submitAttendance(
      endpoint: AttendanceApiEndpoints.checkOut,
      logName: 'Attendance Checkout API',
      fallbackMessage: 'Unable to check out',
      gymId: gymId,
      branchId: branchId,
    );
  }

  Future<List<AttendanceModel>> myAttendance() async {
    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    http.Response response = await _getMyAttendance(token: token);

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await _getMyAttendance(token: newToken);
      }
    }

    final decoded = _decodeResponseBody(response.body);
    ApiResponseLogger.logResponse('My Attendance API', response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _extractAttendanceItems(decoded)
          .map(AttendanceModel.fromJson)
          .toList(growable: false);
    }

    throw ApiException(
      _extractMessage(decoded, fallback: 'Unable to fetch attendance'),
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

  Future<AttendanceModel> _submitAttendance({
    required String endpoint,
    required String logName,
    required String fallbackMessage,
    required String gymId,
    required String branchId,
  }) async {
    final normalizedGymId = gymId.trim();
    final normalizedBranchId = branchId.trim();
    if (normalizedGymId.isEmpty || normalizedBranchId.isEmpty) {
      throw ApiException('Gym and branch are required for attendance.');
    }

    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    debugPrint(
      '$logName request payload: ${jsonEncode({
            'gym_id': normalizedGymId,
            'branch_id': normalizedBranchId,
          })}',
    );

    http.Response response = await _postAttendance(
      endpoint: endpoint,
      logName: logName,
      token: token,
      gymId: normalizedGymId,
      branchId: normalizedBranchId,
    );

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await _postAttendance(
          endpoint: endpoint,
          logName: logName,
          token: newToken,
          gymId: normalizedGymId,
          branchId: normalizedBranchId,
        );
      }
    }

    final decoded = _decodeResponseBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AttendanceModel.fromJson(_extractMap(decoded));
    }

    throw ApiException(
      _extractMessage(decoded, fallback: fallbackMessage),
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

  Future<http.Response> _getMyAttendance({required String token}) {
    return _client.get(
      Uri.parse(AttendanceApiEndpoints.myAttendance),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<http.Response> _postAttendance({
    required String endpoint,
    required String logName,
    required String token,
    required String gymId,
    required String branchId,
  }) async {
    final uri = Uri.parse(endpoint);
    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'gym_id': gymId,
        'branch_id': branchId,
      }),
    );
    ApiResponseLogger.logResponse(logName, response, uri: uri);
    return response;
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

  List<Map<String, dynamic>> _extractAttendanceItems(dynamic payload) {
    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      for (final key in const [
        'data',
        'attendance',
        'attendances',
        'records'
      ]) {
        final value = map[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList(growable: false);
        }
      }
    }
    return const <Map<String, dynamic>>[];
  }

  String _extractMessage(dynamic payload, {required String fallback}) {
    if (payload is Map && payload['message'] is String) {
      return payload['message'] as String;
    }
    if (payload is Map && payload['detail'] is String) {
      return payload['detail'] as String;
    }
    if (payload is Map && payload['detail'] is List) {
      final messages = payload['detail']
          .whereType<Map>()
          .map((item) => item['msg'])
          .whereType<String>()
          .toList();
      if (messages.isNotEmpty) return messages.join('\n');
    }
    if (payload is String && payload.trim().isNotEmpty) {
      final message = payload.trim();
      if (!message.startsWith('<html')) return message;
    }
    return fallback;
  }

  dynamic _extractDetail(dynamic payload) {
    if (payload is Map && payload.containsKey('detail')) {
      return payload['detail'];
    }
    return null;
  }

  bool _isAuthError(int statusCode) => statusCode == 401 || statusCode == 403;
}
