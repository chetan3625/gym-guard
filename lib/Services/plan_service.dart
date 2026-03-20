import 'dart:convert';

import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_service.dart';
import 'package:azanto/core/config/global_variables.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PlanService {
  PlanService({SessionService? sessionService, http.Client? client})
    : _sessionService = sessionService ?? SessionService(),
      _client = client ?? http.Client();

  static const Duration _requestTimeout = Duration(seconds: 20);

  final SessionService _sessionService;
  final http.Client _client;

  Future<Map<String, dynamic>> createPlan({
    required String name,
    required String description,
    required int durationDays,
    required num basePrice,
    required bool isActive,
  }) async {
    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    http.Response response = await _postCreatePlan(
      token: token,
      name: name,
      description: description,
      durationDays: durationDays,
      basePrice: basePrice,
      isActive: isActive,
    );

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await _postCreatePlan(
          token: newToken,
          name: name,
          description: description,
          durationDays: durationDays,
          basePrice: basePrice,
          isActive: isActive,
        );
      }
    }

    final decoded = _decodeResponseBody(response.body);
    // Log every backend response for debugging/visibility.
    debugPrint(
      'Create plan response (${response.statusCode}): '
      '${response.body.isNotEmpty ? response.body : 'no body'}',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return <String, dynamic>{'message': 'Plan created successfully'};
    }

    throw ApiException(
      _extractMessage(decoded, fallback: 'Unable to create plan'),
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

  Future<List<Map<String, dynamic>>> getAllPlans({
    required String gymId,
  }) async {
    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    debugPrint('[PLAN] Fetching plans for gymId=$gymId');

    http.Response response = await _getAllPlans(token: token, gymId: gymId);

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await _getAllPlans(token: newToken, gymId: gymId);
      }
    }

    final decoded = _decodeResponseBody(response.body);
    debugPrint(
      'Fetch plans response (${response.statusCode}): '
      '${response.body.isNotEmpty ? response.body : 'no body'}',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _extractPlanList(decoded);
    }

    throw ApiException(
      _extractMessage(decoded, fallback: 'Unable to fetch plans'),
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
    return fallback;
  }

  dynamic _extractDetail(dynamic payload) {
    if (payload is Map && payload.containsKey('detail')) {
      return payload['detail'];
    }
    return null;
  }

  Future<http.Response> _postCreatePlan({
    required String token,
    required String name,
    required String description,
    required int durationDays,
    required num basePrice,
    required bool isActive,
  }) {
    return _client
        .post(
          Uri.parse(PlanApiEndpoints.createPlan),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'name': name,
            'description': description,
            'duration_days': durationDays,
            'base_price': basePrice,
            'is_active': isActive,
          }),
        )
        .timeout(
          _requestTimeout,
          onTimeout: () =>
              throw ApiException('Plan request timed out. Please try again.'),
        );
  }

  Future<http.Response> _getAllPlans({
    required String token,
    required String gymId,
  }) {
    return _client
        .get(
          Uri.parse('${PlanApiEndpoints.getAllPlans}/$gymId'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(
          _requestTimeout,
          onTimeout: () =>
              throw ApiException('Fetching plans timed out. Please try again.'),
        );
  }

  List<Map<String, dynamic>> _extractPlanList(dynamic decoded) {
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    }

    if (decoded is Map) {
      const listKeys = <String>['data', 'plans', 'items', 'results'];
      for (final key in listKeys) {
        final value = decoded[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((m) => Map<String, dynamic>.from(m))
              .toList();
        }
      }
    }

    return <Map<String, dynamic>>[];
  }

  bool _isAuthError(int statusCode) => statusCode == 401 || statusCode == 403;
}
