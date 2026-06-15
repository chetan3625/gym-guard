import 'dart:convert';

import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_service.dart';
import 'package:azanto/core/config/api_constant.dart';
import 'package:azanto/utils/api_response_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MembershipService {
  MembershipService({SessionService? sessionService, http.Client? client})
      : _sessionService = sessionService ?? Get.find<SessionService>(),
        _client = client ?? http.Client();

  final SessionService _sessionService;
  final http.Client _client;

  Future<String> getEnrolledPlanName() async {
    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    final cachedPlanName = _extractPlanName(_sessionService.lastAuthResponse);
    if (cachedPlanName.isNotEmpty) return cachedPlanName;

    final payload = _buildEnrolledPlanPayload();
    debugPrint('Enrolled Plan API request payload: ${jsonEncode(payload)}');
    final missingFields = _missingRequiredUuidFields(payload);
    if (missingFields.isNotEmpty) {
      debugPrint(
        'Enrolled Plan API skipped. Missing/invalid UUID fields: $missingFields',
      );
      throw ApiException(
        'Membership details missing. Please refresh your session and try again.',
        detail: {'missing_fields': missingFields},
      );
    }

    http.Response response = await _postEnrolledPlan(
      token: token,
      payload: payload,
    );

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await _postEnrolledPlan(
          token: newToken,
          payload: payload,
        );
      }
    }

    final decoded = _decodeResponseBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final planName = _extractPlanName(decoded);
      if (planName.isNotEmpty) return planName;
      throw ApiException('Enrolled plan response did not include a plan name.');
    }

    throw ApiException(
      _extractMessage(decoded, fallback: 'Unable to fetch enrolled plan'),
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

  Map<String, String> _buildEnrolledPlanPayload() {
    return <String, String>{
      'gym_id': _sessionService.gymId?.trim() ??
          _findIdentifier(const ['gym_id', 'gymId', 'gid']),
      'branch_id': _sessionService.branchId?.trim() ??
          _findIdentifier(const ['branch_id', 'branchId', 'bid']),
      'plan_id': _sessionService.planId?.trim() ??
          _findIdentifier(
            const ['plan_id', 'planId', 'membership_plan_id', 'membershipPlanId'],
          ),
      'user_id': _findIdentifier(
        const ['user_id', 'userId', 'member_id', 'memberId', 'sub', 'id'],
      ),
      'payment_id': _findIdentifier(
        const ['payment_id', 'paymentId', 'transaction_id', 'transactionId'],
      ),
    };
  }

  String _findIdentifier(List<String> keys) {
    final sources = <Map<String, dynamic>>[
      if (_sessionService.lastAuthResponse != null)
        _sessionService.lastAuthResponse!,
      if (_sessionService.tokenClaims != null) _sessionService.tokenClaims!,
    ];

    for (final source in sources) {
      final value = _readText(source, keys);
      if (value != null) return value;

      for (final nestedKey in const ['user', 'member', 'membership', 'plan']) {
        final nested = source[nestedKey];
        if (nested is Map) {
          final nestedValue =
              _readText(Map<String, dynamic>.from(nested), keys);
          if (nestedValue != null) return nestedValue;
        }
      }
    }

    return '';
  }

  List<String> _missingRequiredUuidFields(Map<String, String> payload) {
    return const ['gym_id', 'branch_id', 'plan_id', 'payment_id']
        .where((key) => !_isUuid(payload[key]))
        .toList(growable: false);
  }

  bool _isUuid(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return false;
    return RegExp(
      r'^[0-9a-fA-F]{8}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{12}$',
    ).hasMatch(normalized);
  }

  Future<http.Response> _postEnrolledPlan({
    required String token,
    required Map<String, String> payload,
  }) async {
    final uri = Uri.parse(MembershipApiEndpoints.enrolledPlan);
    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );
    ApiResponseLogger.logResponse('Enrolled Plan API', response, uri: uri);
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

  String _extractPlanName(dynamic payload) {
    if (payload is String) return _cleanPlanName(payload);
    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      final direct = _readText(map, const [
        'plan_name',
        'planName',
        'name',
        'data',
        'message',
        'plan',
      ]);
      if (direct != null) return _cleanPlanName(direct);

      for (final key in const ['data', 'plan', 'membership']) {
        final nested = map[key];
        if (nested is Map) {
          final nestedName =
              _extractPlanName(Map<String, dynamic>.from(nested));
          if (nestedName.isNotEmpty) return nestedName;
        }
      }
    }
    return '';
  }

  String _cleanPlanName(String raw) {
    var value = raw.trim();
    if (value.startsWith('"') && value.endsWith('"') && value.length >= 2) {
      value = value.substring(1, value.length - 1).trim();
    }
    return value;
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
      return _cleanPlanName(payload);
    }
    return fallback;
  }

  dynamic _extractDetail(dynamic payload) {
    if (payload is Map && payload.containsKey('detail')) {
      return payload['detail'];
    }
    return null;
  }

  String? _readText(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  bool _isAuthError(int statusCode) => statusCode == 401 || statusCode == 403;
}
