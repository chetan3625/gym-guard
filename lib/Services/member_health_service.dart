import 'dart:convert';

import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/core/config/api_constant.dart';
import 'package:azanto/models/member_health_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MemberHealthResult {
  const MemberHealthResult({required this.members, required this.summary});
  final List<MemberHealthModel> members;
  final Map<String, dynamic> summary;
}

class MemberHealthService {
  MemberHealthService({SessionService? sessionService, http.Client? client})
      : _session = sessionService ?? Get.find<SessionService>(),
        _client = client ?? http.Client();

  final SessionService _session;
  final http.Client _client;

  Future<MemberHealthResult> load({
    required String gymId,
    required String branchId,
    int inactiveDays = 7,
    String filter = 'all',
  }) async {
    final token = _session.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please log in again.');
    }
    final uri =
        Uri.parse('${GymApiEndpoints.memberHealth}/$gymId/member-health')
            .replace(queryParameters: {
      'branch_id': branchId,
      'inactive_days': '$inactiveDays',
      'filter': filter,
    });
    final response =
        await _client.get(uri, headers: {'Authorization': 'Bearer $token'});
    final body = response.body.trim().isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(body is Map
          ? (body['detail'] ?? 'Unable to load member health').toString()
          : 'Unable to load member health');
    }
    final map = Map<String, dynamic>.from(body as Map);
    final members = ((map['members'] as List?) ?? const [])
        .whereType<Map>()
        .map((item) =>
            MemberHealthModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    return MemberHealthResult(
        members: members,
        summary: Map<String, dynamic>.from(map['summary'] as Map? ?? const {}));
  }

  Future<void> recordOutreach({
    required String gymId,
    required String branchId,
    required String memberId,
    required String channel,
    String message = '',
  }) async {
    final token = _session.normalizedToken;
    if (token == null || token.isEmpty) return;
    await _client.post(
      Uri.parse(
          '${GymApiEndpoints.memberHealth}/$gymId/member-health/$memberId/outreach'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(
          {'branch_id': branchId, 'channel': channel, 'message': message}),
    );
  }
}
