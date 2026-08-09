import 'dart:convert';

import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/core/config/api_constant.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class GymQrData {
  const GymQrData(
      {required this.payload,
      required this.gymName,
      required this.branchName,
      required this.trialDays});
  final String payload;
  final String gymName;
  final String branchName;
  final int trialDays;
  factory GymQrData.fromJson(Map<String, dynamic> json) => GymQrData(
        payload: (json['payload'] ?? '').toString(),
        gymName: (json['gym_name'] ?? 'Your gym').toString(),
        branchName: (json['branch_name'] ?? 'Main branch').toString(),
        trialDays: (json['trial_days'] as num?)?.toInt() ?? 7,
      );
}

class GymQrService {
  GymQrService({SessionService? sessionService, http.Client? client})
      : _session = sessionService ?? Get.find<SessionService>(),
        _client = client ?? http.Client();
  final SessionService _session;
  final http.Client _client;
  Future<GymQrData> getOwnerQr(
      {required String gymId, required String branchId}) async {
    final token = _session.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please log in again.');
    }
    final uri = Uri.parse('${GymApiEndpoints.memberHealth}/$gymId/qr')
        .replace(queryParameters: {'branch_id': branchId});
    final response =
        await _client.get(uri, headers: {'Authorization': 'Bearer $token'});
    final decoded =
        response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(decoded is Map
          ? (decoded['detail'] ?? 'Unable to load QR').toString()
          : 'Unable to load QR');
    }
    return GymQrData.fromJson(Map<String, dynamic>.from(decoded as Map));
  }

  Future<Map<String, dynamic>> joinGym({
    required String gymId,
    required String branchId,
    required String code,
  }) async {
    final token = _session.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please log in again.');
    }
    final response = await _client.post(
      Uri.parse('${GlobalVariables.gymBaseUrl}/gym/join-by-qr'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'gym_id': gymId, 'branch_id': branchId, 'code': code}),
    );
    final decoded =
        response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(decoded is Map
          ? (decoded['detail'] ?? 'Unable to join gym').toString()
          : 'Unable to join gym');
    }
    return Map<String, dynamic>.from(decoded as Map);
  }
}
