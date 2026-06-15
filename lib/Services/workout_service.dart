import 'dart:convert';

import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_service.dart';
import 'package:azanto/core/config/api_constant.dart';
import 'package:azanto/models/workout_model.dart';
import 'package:azanto/utils/api_response_logger.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class WorkoutService {
  WorkoutService({SessionService? sessionService, http.Client? client})
      : _sessionService = sessionService ?? Get.find<SessionService>(),
        _client = client ?? http.Client();

  final SessionService _sessionService;
  final http.Client _client;

  Future<List<WorkoutCategoryModel>> getCategories() async {
    final response = await _authorizedRequest(
      (token) => _client.get(
        Uri.parse(WorkoutApiEndpoints.getCategories),
        headers: _jsonHeaders(token),
      ),
      logName: 'Get Workout Categories API',
    );

    return _extractList(response.body)
        .map(WorkoutCategoryModel.fromJson)
        .toList(growable: false);
  }

  Future<WorkoutCategoryModel> createCategory({
    required String name,
    required String description,
  }) async {
    final response = await _authorizedRequest(
      (token) => _client.post(
        Uri.parse(WorkoutApiEndpoints.createCategory),
        headers: _jsonHeaders(token),
        body: jsonEncode({'name': name.trim(), 'description': description.trim()}),
      ),
      logName: 'Create Workout Category API',
    );

    return WorkoutCategoryModel.fromJson(_extractMap(response.body));
  }

  Future<List<WorkoutBodyPartModel>> getBodyParts(String categoryId) async {
    final normalizedId = categoryId.trim();
    if (normalizedId.isEmpty) {
      throw ApiException('Category is required to fetch body parts.');
    }

    final response = await _authorizedRequest(
      (token) => _client.get(
        Uri.parse(WorkoutApiEndpoints.bodyPartsForCategory(normalizedId)),
        headers: _jsonHeaders(token),
      ),
      logName: 'Get Body Parts API',
    );

    return _extractList(response.body)
        .map(WorkoutBodyPartModel.fromJson)
        .toList(growable: false);
  }

  Future<WorkoutBodyPartModel> createBodyPart({
    required String name,
    required String categoryId,
  }) async {
    final response = await _authorizedRequest(
      (token) => _client.post(
        Uri.parse(WorkoutApiEndpoints.createBodyPart),
        headers: _jsonHeaders(token),
        body: jsonEncode({
          'name': name.trim(),
          'category_id': categoryId.trim(),
        }),
      ),
      logName: 'Create Body Part API',
    );

    return WorkoutBodyPartModel.fromJson(_extractMap(response.body));
  }

  Future<List<WorkoutExerciseModel>> getExercises(String bodyPartId) async {
    final normalizedId = bodyPartId.trim();
    if (normalizedId.isEmpty) {
      throw ApiException('Body part is required to fetch exercises.');
    }

    final response = await _authorizedRequest(
      (token) => _client.get(
        Uri.parse(WorkoutApiEndpoints.exercisesForBodyPart(normalizedId)),
        headers: _jsonHeaders(token),
      ),
      logName: 'Get Exercises API',
    );

    return _extractList(response.body)
        .map(WorkoutExerciseModel.fromJson)
        .toList(growable: false);
  }

  Future<WorkoutExerciseModel> createExercise({
    required String name,
    required String bodyPartId,
    required String description,
    String mediaUrl = '',
    int defaultReps = 0,
    int defaultSets = 0,
  }) async {
    final response = await _authorizedRequest(
      (token) => _client.post(
        Uri.parse(WorkoutApiEndpoints.createExercise),
        headers: _jsonHeaders(token),
        body: jsonEncode({
          'name': name.trim(),
          'body_part_id': bodyPartId.trim(),
          'description': description.trim(),
          'media_url': mediaUrl.trim(),
          'default_reps': defaultReps,
          'default_sets': defaultSets,
        }),
      ),
      logName: 'Create Exercise API',
    );

    return WorkoutExerciseModel.fromJson(_extractMap(response.body));
  }

  Future<WorkoutTrackingModel> trackExercise({
    required String exerciseId,
    required int setsCompleted,
    required String repsCompleted,
  }) async {
    final response = await _authorizedRequest(
      (token) => _client.post(
        Uri.parse(WorkoutApiEndpoints.trackExercise),
        headers: _jsonHeaders(token),
        body: jsonEncode({
          'exercise_id': exerciseId.trim(),
          'sets_completed': setsCompleted,
          'reps_completed': repsCompleted.trim(),
        }),
      ),
      logName: 'Track Exercise API',
    );

    return WorkoutTrackingModel.fromJson(_extractMap(response.body));
  }

  Future<WorkoutLogModel> completeExercise(String trackingId) async {
    final normalizedId = trackingId.trim();
    if (normalizedId.isEmpty) {
      throw ApiException('Tracking id is required to complete exercise.');
    }

    final response = await _authorizedRequest(
      (token) => _client.patch(
        Uri.parse(WorkoutApiEndpoints.completeExercise(normalizedId)),
        headers: _jsonHeaders(token),
        body: jsonEncode({'is_completed': true}),
      ),
      logName: 'Complete Exercise API',
    );

    return WorkoutLogModel.fromJson(_extractMap(response.body));
  }

  Future<WorkoutLogModel> getLogHistory(String logId) async {
    final normalizedId = logId.trim();
    if (normalizedId.isEmpty) {
      throw ApiException('Log id is required to fetch workout history.');
    }

    final response = await _authorizedRequest(
      (token) => _client.get(
        Uri.parse(WorkoutApiEndpoints.logHistory(normalizedId)),
        headers: _jsonHeaders(token),
      ),
      logName: 'Workout Log History API',
    );

    return WorkoutLogModel.fromJson(_extractMap(response.body));
  }

  Future<http.Response> _authorizedRequest(
    Future<http.Response> Function(String token) request, {
    required String logName,
  }) async {
    final token = _requireToken();
    http.Response response = await request(token);
    ApiResponseLogger.logResponse(logName, response);

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await request(newToken);
        ApiResponseLogger.logResponse('$logName (retry)', response);
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    final decoded = _decodeResponseBody(response.body);
    throw ApiException(
      _extractMessage(decoded, fallback: 'Workout request failed'),
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

  String _requireToken() {
    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }
    return token;
  }

  Map<String, String> _jsonHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
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

  Map<String, dynamic> _extractMap(String body) {
    final payload = _decodeResponseBody(body);
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

  List<Map<String, dynamic>> _extractList(String body) {
    final payload = _decodeResponseBody(body);
    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      for (final key in const ['data', 'categories', 'body_parts', 'exercises']) {
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
