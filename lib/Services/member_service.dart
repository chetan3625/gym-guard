import 'dart:convert';
import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_service.dart';
import 'package:azanto/core/config/api_constant.dart';
import 'package:azanto/models/branch_member_model.dart';
import 'package:azanto/models/member_profile_details_model.dart';
import 'package:azanto/utils/api_response_logger.dart';
import 'package:azanto/utils/member_search_mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MemberService {
  MemberService({SessionService? sessionService, http.Client? client})
      : _sessionService = sessionService ?? Get.find<SessionService>(),
        _client = client ?? http.Client();

  final SessionService _sessionService;
  final http.Client _client;

  Future<List<BranchMemberModel>> getAllBranchMembers({
    required String branchId,
  }) async {
    final normalizedBranchId = branchId.trim();
    if (normalizedBranchId.isEmpty) {
      throw ApiException('Branch id missing. Please select a branch first.');
    }

    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    http.Response response = await _getAllBranchMembers(
      token: token,
      branchId: normalizedBranchId,
    );

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await _getAllBranchMembers(
          token: newToken,
          branchId: normalizedBranchId,
        );
      }
    }

    final decoded = _decodeResponseBody(response.body);
    ApiResponseLogger.logResponse('Get Branch Members API', response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _extractBranchMemberItems(decoded)
          .map((item) => BranchMemberModel.fromJson(item))
          .toList(growable: false);
    }

    final errorMessage = _extractMessage(
      decoded,
      fallback: 'Unable to fetch branch members',
    );
    if (response.statusCode == 404 ||
        errorMessage.toLowerCase().contains('no member')) {
      return const <BranchMemberModel>[];
    }

    throw ApiException(
      errorMessage,
      statusCode: response.statusCode,
      detail: _extractDetail(decoded),
    );
  }

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
      return MemberSearchMapper.extractMemberPayload(decoded);
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

  Future<MemberProfileDetailsModel> getMemberProfile({
    required String userId,
  }) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) {
      throw ApiException('Member id missing. Please select a member again.');
    }

    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    http.Response response = await _getMemberProfile(
      token: token,
      userId: normalizedUserId,
    );

    if (_isAuthError(response.statusCode)) {
      final refreshed = await TokenRefreshService(
        sessionService: _sessionService,
      ).refreshToken();
      final newToken = _sessionService.normalizedToken;
      if (refreshed && newToken != null && newToken.isNotEmpty) {
        response = await _getMemberProfile(
          token: newToken,
          userId: normalizedUserId,
        );
      }
    }

    final decoded = _decodeResponseBody(response.body);
    ApiResponseLogger.logResponse('Get Member Profile API', response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return MemberProfileDetailsModel.fromJson(
        _normalizeProfileData(_extractMap(decoded)),
      );
    }

    throw ApiException(
      _extractMessage(decoded, fallback: 'Unable to fetch member profile'),
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
    final branchId = _sessionService.branchId ?? gymId;

    try {
      final response = await http.post(
        Uri.parse(GymApiEndpoints.addMember),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'gym_id': gymId,
          'branch_id': branchId,
          'plan_id': planId,
          'user_id': userId,
          'amount': amount,
          'payment_mode': paymentMode,
        }),
      );

      ApiResponseLogger.logResponse('Add Member API', response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) return decoded;
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        }
        return {'message': 'Membership purchased successfully'};
      }

      final decoded = _decodeResponseBody(response.body);
      final errorMessage = _extractMessage(
        decoded,
        fallback: response.statusCode == 503
            ? 'Add member service temporarily unavailable. Please try again shortly.'
            : 'Unable to add member',
      );

      throw ApiException(
        errorMessage,
        statusCode: response.statusCode,
        detail: _extractDetail(decoded),
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

  Future<http.Response> _getAllBranchMembers({
    required String token,
    required String branchId,
  }) {
    return _client.get(
      Uri.parse('${GymApiEndpoints.getAllBranchMembers}/$branchId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<http.Response> _getMemberProfile({
    required String token,
    required String userId,
  }) {
    final uri = Uri.parse(MemberProfileApiEndpoints.getProfile).replace(
      queryParameters: <String, String>{'user_id': userId},
    );
    return _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  List<Map<String, dynamic>> _extractBranchMemberItems(dynamic payload) {
    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }

    if (payload is Map) {
      final mapped = Map<String, dynamic>.from(payload);
      if (mapped.containsKey('user_id') || mapped.containsKey('userId')) {
        return <Map<String, dynamic>>[mapped];
      }

      final candidates = <dynamic>[
        mapped['data'],
        mapped['members'],
        mapped['branch_members'],
        mapped['branchMembers'],
        mapped['items'],
        mapped['results'],
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList(growable: false);
        }
      }
    }

    return const <Map<String, dynamic>>[];
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
    if (payload['member'] is Map) {
      return Map<String, dynamic>.from(payload['member'] as Map);
    }
    return payload;
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
