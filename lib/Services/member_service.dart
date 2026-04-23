
import 'dart:convert';
import 'package:azanto/Services/login_services.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/core/config/api_constant.dart';
import 'package:azanto/utils/api_response_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MemberService {
  MemberService({SessionService? sessionService})
      : _sessionService = sessionService ?? Get.find<SessionService>();

  final SessionService _sessionService;

  Future<Map<String, dynamic>?> searchMemberByPhone(String phone) async {
    final token = _sessionService.normalizedToken;
    if (token == null || token.isEmpty) {
      throw ApiException('Session expired. Please login again.');
    }

    try {
      final response = await http.get(
        Uri.parse('${MembershipApiEndpoints.searchMemberWithPhone}$phone'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      ApiResponseLogger.logResponse('Search Member API', response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) return decoded;
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        }
        return null;
      }

      if (response.statusCode == 404) {
        return null;
      }

      return null;
    } catch (e) {
      debugPrint('Search member error: $e');
      return null;
    }
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
}
