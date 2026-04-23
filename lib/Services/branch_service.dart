import 'dart:convert';

import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_service.dart';
import 'package:azanto/core/config/global_variables.dart';
import 'package:azanto/utils/api_response_logger.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BranchService {
  BranchService({SessionService? sessionService, http.Client? client})
    : _sessionService = sessionService ?? SessionService(),
      _client = client ?? http.Client();

  final SessionService _sessionService;
  final http.Client _client;

  Future<Map<String, dynamic>> createBranch({
    required String gymId,
    required String name,
    required String address,
    required String city,
    required String state,
    required String country,
    required String pincode,
    required TimeOfDay openingTime,
    required TimeOfDay closingTime,
    double latitude = 0,
    double longitude = 0,
  }) async {
    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    http.Response response = await _postCreateBranch(
      token: token,
      gymId: gymId,
      name: name,
      address: address,
      city: city,
      state: state,
      country: country,
      pincode: pincode,
      latitude: latitude,
      longitude: longitude,
      openingTime: openingTime,
      closingTime: closingTime,
    );

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await _postCreateBranch(
          token: newToken,
          gymId: gymId,
          name: name,
          address: address,
          city: city,
          state: state,
          country: country,
          pincode: pincode,
          latitude: latitude,
          longitude: longitude,
          openingTime: openingTime,
          closingTime: closingTime,
        );
      }
    }

    final decoded = _decodeResponseBody(response.body);
    ApiResponseLogger.logResponse('Create Branch API', response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return <String, dynamic>{'message': 'Branch created successfully'};
    }

    debugPrint(
      'Create branch failed (${response.statusCode}): '
      '${response.body.isNotEmpty ? response.body : 'no body'}',
    );

    throw ApiException(
      _extractMessage(decoded, fallback: 'Unable to create branch'),
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

  Future<http.Response> _postCreateBranch({
    required String token,
    required String gymId,
    required String name,
    required String address,
    required String city,
    required String state,
    required String country,
    required String pincode,
    required double latitude,
    required double longitude,
    required TimeOfDay openingTime,
    required TimeOfDay closingTime,
  }) {
    String formatTime(TimeOfDay t) {
      final hour = t.hour.toString().padLeft(2, '0');
      final minute = t.minute.toString().padLeft(2, '0');
      return '$hour:$minute:00.000Z';
    }

    return _client.post(
      Uri.parse(GymApiEndpoints.addBranch),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'gym_id': gymId,
        'name': name,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'pincode': pincode,
        'latitude': latitude,
        'longitude': longitude,
        'is_active': true,
        // Backend expects the time in "HH:mm:ss.SSSZ" format
        'opening_time': formatTime(openingTime),
        'closing_time': formatTime(closingTime),
        'created_at': DateTime.now().toUtc().toIso8601String(),
      }),
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
      final msgs = payload['detail']
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

  bool _isAuthError(int statusCode) => statusCode == 401 || statusCode == 403;
}
