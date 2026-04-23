import 'dart:convert';

import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_service.dart';
import 'package:azanto/core/config/global_variables.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:azanto/models/plan_model.dart';
import 'package:azanto/utils/api_response_logger.dart';
import 'package:http/http.dart' as http;

class PlanService {
  PlanService({SessionService? sessionService, http.Client? client})
      : _sessionService = sessionService ?? SessionService(),
        _client = client ?? http.Client();

  static const Duration _requestTimeout = Duration(seconds: 20);

  final SessionService _sessionService;
  final http.Client _client;

  Future<Map<String, dynamic>> createPlan({
    required String gymId,
    required String branchId,
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
      gymId: gymId,
      branchId: branchId,
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
          gymId: gymId,
          branchId: branchId,
          name: name,
          description: description,
          durationDays: durationDays,
          basePrice: basePrice,
          isActive: isActive,
        );
      }
    }

    final decoded = _decodeResponseBody(response.body);
    ApiResponseLogger.logResponse('Create Plan API', response);

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

  Future<List<Plan>> getAllPlans({
    required String gymId,
    required String branchId,
  }) async {
    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    debugPrint('[PLAN] Fetching plans for gymId=$gymId branchId=$branchId');

    http.Response response = await _getAllPlans(token: token, gymId: gymId, branchId: branchId);

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await _getAllPlans(token: newToken, gymId: gymId, branchId: branchId);
      }
    }

    final decoded = _decodeResponseBody(response.body);
    ApiResponseLogger.logResponse('Fetch Plans API', response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _extractPlanList(decoded).map((p) => Plan.fromJson(p)).toList();
    }

    final errorMessage = _extractMessage(decoded, fallback: 'Unable to fetch plans');
    
    // The backend returns a specific detail message when there are no plans
    if (response.statusCode == 404 || errorMessage.toLowerCase().contains('no active plan')) {
      return [];
    }

    throw ApiException(
      errorMessage,
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

  Future<Plan> getPlanDetails({
    required String planId,
  }) async {
    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    http.Response response =
        await _getPlanDetails(token: token, planId: planId);

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await _getPlanDetails(token: newToken, planId: planId);
      }
    }

    final decoded = _decodeResponseBody(response.body);
    ApiResponseLogger.logResponse('Plan Details API', response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return Plan.fromJson(decoded);
      if (decoded is Map) {
        return Plan.fromJson(Map<String, dynamic>.from(decoded));
      }
      throw ApiException('Plan details response was empty.');
    }

    throw ApiException(
      _extractMessage(decoded, fallback: 'Unable to fetch plan details'),
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

  Future<Plan> updatePlan({
    required String planId,
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

    http.Response response = await _patchUpdatePlan(
      token: token,
      planId: planId,
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
        response = await _patchUpdatePlan(
          token: newToken,
          planId: planId,
          name: name,
          description: description,
          durationDays: durationDays,
          basePrice: basePrice,
          isActive: isActive,
        );
      }
    }

    final decoded = _decodeResponseBody(response.body);
    ApiResponseLogger.logResponse('Update Plan API', response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic> && 
          (decoded.containsKey('id') || decoded.containsKey('plan_id') || decoded.containsKey('_id'))) {
        return Plan.fromJson(decoded);
      }
      if (decoded is Map && 
          (decoded.containsKey('id') || decoded.containsKey('plan_id') || decoded.containsKey('_id'))) {
        return Plan.fromJson(Map<String, dynamic>.from(decoded));
      }
      return Plan(
        id: planId,
        name: name,
        description: description,
        price: basePrice,
        durationDays: durationDays,
        isActive: isActive,
      );
    }

    throw ApiException(
      _extractMessage(decoded, fallback: 'Unable to update plan'),
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
    required String gymId,
    required String branchId,
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
            'gym_id': gymId,
            'branch_id': branchId,
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
    required String branchId,
  }) {
    return _client.get(
      Uri.parse('${PlanApiEndpoints.getAllPlans}/$gymId?branch_id=$branchId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(
      _requestTimeout,
      onTimeout: () =>
          throw ApiException('Fetching plans timed out. Please try again.'),
    );
  }

  Future<http.Response> _getPlanDetails({
    required String token,
    required String planId,
  }) {
    return _client.get(
      Uri.parse('${PlanApiEndpoints.getPlanDetails}/$planId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(
      _requestTimeout,
      onTimeout: () => throw ApiException(
        'Fetching plan details timed out. Please try again.',
      ),
    );
  }

  Future<http.Response> _patchUpdatePlan({
    required String token,
    required String planId,
    required String name,
    required String description,
    required int durationDays,
    required num basePrice,
    required bool isActive,
  }) {
    return _client
        .patch(
          Uri.parse('${PlanApiEndpoints.updatePlan}/$planId'),
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
              throw ApiException('Updating plan timed out. Please try again.'),
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
