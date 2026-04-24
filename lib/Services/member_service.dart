
import 'dart:convert';
import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_service.dart';
import 'package:azanto/core/config/api_constant.dart';
import 'package:azanto/utils/api_response_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MemberService {
  MemberService({SessionService? sessionService, http.Client? client})
      : _sessionService = sessionService ?? Get.find<SessionService>(),
        _client = client ?? http.Client();

  final SessionService _sessionService;
  final http.Client _client;

  Future<Map<String, dynamic>?> searchMemberByPhone(String phone) async {
    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    http.Response response = await _searchMemberByPhone(
      token: token,
      phone: phone,
    );

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await _searchMemberByPhone(
          token: newToken,
          phone: phone,
        );
      }
    }

    final decoded = _decodeResponseBody(response.body);
    ApiResponseLogger.logResponse('Search Member API', response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _extractMemberPayload(decoded);
    }

    if (response.statusCode == 404) {
      return null;
    }

    throw ApiException(
      _extractMessage(decoded, fallback: 'Unable to search member'),
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

  Future<Map<String, dynamic>> purchaseMembership({
    required String gymId,
    required String planId,
    required String userId,
    required double amount,
    required String paymentMode,
  }) async {
    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    try {
      final response = await http.post(
        Uri.parse(MembershipApiEndpoints.membershipPurchase),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'gym_id': gymId,
          'plan_id': planId,
          'user_id': userId,
          'amount': amount,
          'payment_mode': paymentMode,
        }),
      );

      ApiResponseLogger.logResponse('Membership Purchase API', response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) return decoded;
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        }
        return {'message': 'Membership purchased successfully'};
      }

      // Parse error response
      String errorMessage = 'Unable to purchase membership';
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            errorMessage = decoded['message'].toString();
          }
        } catch (_) {
          errorMessage = response.body;
        }
      }

      throw ApiException(
        errorMessage,
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      debugPrint('Error purchasing membership: $e');
      throw ApiException('Something went wrong, please try again.');
    }
  }

  Future<http.Response> _searchMemberByPhone({
    required String token,
    required String phone,
  }) {
    return _client.get(
      Uri.parse('${MembershipApiEndpoints.searchMemberWithPhone}$phone'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
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

  Map<String, dynamic>? _extractMemberPayload(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final nested = _extractNestedMemberMap(decoded);
      return nested ?? decoded;
    }
    if (decoded is Map) {
      final mapped = Map<String, dynamic>.from(decoded);
      final nested = _extractNestedMemberMap(mapped);
      return nested ?? mapped;
    }
    return null;
  }

  Map<String, dynamic>? _extractNestedMemberMap(Map<String, dynamic> source) {
    for (final key in const <String>['data', 'member', 'user', 'result']) {
      final value = source[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    return null;
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
