import 'dart:convert';

import 'package:azanto/Services/session_service.dart';
import 'package:azanto/core/config/global_variables.dart';
import 'package:azanto/utils/api_response_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  /// Calls the login API and returns the decoded JSON body.
  /// Throws [ApiException] with a friendly message when the request fails.
  Future<Map<String, dynamic>> loginUser({
    required String phoneno,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AuthApiEndpoints.login),
        headers: const {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"username": phoneno, "password": password, "role": role},
      );

      final body = response.body;
      ApiResponseLogger.logResponse('Login API', response);
      final decoded = body.isNotEmpty ? jsonDecode(body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }

      final message = _extractMessage(decoded, fallback: 'Unable to login');
      final detail = _extractDetail(decoded);
      // Log server-provided error details for debugging.
      debugPrint(
        "Login failed (${response.statusCode}): ${response.body.isNotEmpty ? response.body : message}",
      );
      throw ApiException(
        message,
        statusCode: response.statusCode,
        detail: detail ?? decoded,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      // Log unexpected errors to console for investigation.
      debugPrint("Login unexpected error: $e");
      throw ApiException('Something went wrong, please try again.');
    }
  }

  Future<Map<String, dynamic>> signupUser({
    required String fullName,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AuthApiEndpoints.register),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": fullName,
          "phone": phone,
          "password": password,
          "role": role,
        }),
      );

      final body = response.body;
      ApiResponseLogger.logResponse('Signup API', response);
      final decoded = body.isNotEmpty ? jsonDecode(body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }

      final message = response.statusCode >= 500
          ? 'Server error, please try again later'
          : _extractMessage(decoded, fallback: 'Unable to sign up');
      final detail = _extractDetail(decoded);
      debugPrint(
        "Signup failed (${response.statusCode}): ${response.body.isNotEmpty ? response.body : message}",
      );
      throw ApiException(
        message,
        statusCode: response.statusCode,
        detail: detail ?? decoded,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      debugPrint("Signup unexpected error: $e");
      throw ApiException('Something went wrong, please try again.');
    }
  }

  Future<Map<String, dynamic>> requestOtp({required String phone}) async {
    try {
      final response = await http.post(
        Uri.parse(AuthApiEndpoints.requestOtp),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );

      final body = response.body;
      ApiResponseLogger.logResponse('Request OTP API', response);
      final decoded = body.isNotEmpty ? jsonDecode(body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }

      final message = response.statusCode >= 500
          ? 'Server error, please try again later'
          : _extractMessage(decoded, fallback: 'Unable to send code');
      final detail = _extractDetail(decoded);
      debugPrint(
        "Request OTP failed (${response.statusCode}): ${response.body.isNotEmpty ? response.body : message}",
      );
      throw ApiException(
        message,
        statusCode: response.statusCode,
        detail: detail ?? decoded,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      debugPrint("Request OTP unexpected error: $e");
      throw ApiException('Something went wrong, please try again.');
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AuthApiEndpoints.verifyOtp),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "otp": otp}),
      );

      final body = response.body;
      ApiResponseLogger.logResponse('Verify OTP API', response);
      final decoded = body.isNotEmpty ? jsonDecode(body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }

      final message = response.statusCode >= 500
          ? 'Server error, please try again later'
          : _extractMessage(decoded, fallback: 'Unable to verify code');
      final detail = _extractDetail(decoded);
      debugPrint(
        "Verify OTP failed (${response.statusCode}): ${response.body.isNotEmpty ? response.body : message}",
      );
      throw ApiException(
        message,
        statusCode: response.statusCode,
        detail: detail ?? decoded,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      debugPrint("Verify OTP unexpected error: $e");
      throw ApiException('Something went wrong, please try again.');
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AuthApiEndpoints.resetPassword),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({
          "reset_token": resetToken,
          "new_password": newPassword,
        }),
      );

      final body = response.body;
      ApiResponseLogger.logResponse('Reset Password API', response);
      final decoded = body.isNotEmpty ? jsonDecode(body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }

      final message = response.statusCode >= 500
          ? 'Server error, please try again later'
          : _extractMessage(decoded, fallback: 'Unable to reset password');
      final detail = _extractDetail(decoded);
      debugPrint(
        "Reset password failed (${response.statusCode}): ${response.body.isNotEmpty ? response.body : message}",
      );
      throw ApiException(
        message,
        statusCode: response.statusCode,
        detail: detail ?? decoded,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      debugPrint("Reset password unexpected error: $e");
      throw ApiException('Something went wrong, please try again.');
    }
  }

  Future<Map<String, dynamic>?> refreshToken({
    required String refreshTokenValue,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AuthApiEndpoints.refreshToken),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({"refresh_token": refreshTokenValue}),
      );

      final body = response.body;
      ApiResponseLogger.logResponse('Refresh Token API', response);

      // Handle 401 specifically - token is invalid/expired
      if (response.statusCode == 401) {
        debugPrint(
          '[AUTH][refresh] 401 Unauthorized - refresh token is invalid or expired',
        );
        // Return a special response to indicate 401
        return {
          '_error': 'unauthorized',
          '_status_code': 401,
          '_detail': body.isNotEmpty
              ? body
              : 'Invalid or expired refresh token',
        };
      }

      // Handle other error status codes
      if (response.statusCode >= 400) {
        debugPrint("Token refresh failed (${response.statusCode}): $body");
        return null;
      }

      final decoded = body.isNotEmpty ? jsonDecode(body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
        if (decoded is String) return {'access_token': decoded};
        return null;
      }

      return null;
    } catch (e) {
      debugPrint("Token refresh error: $e");
      return null;
    }
  }

  String _extractMessage(dynamic payload, {required String fallback}) {
    if (payload is Map && payload['message'] is String) {
      return payload['message'] as String;
    }
    if (payload is Map && payload['detail'] is String) {
      return payload['detail'] as String;
    }
    if (payload is Map &&
        payload['detail'] is List &&
        payload['detail'].isNotEmpty &&
        payload['detail'][0] is Map &&
        payload['detail'][0]['msg'] is String) {
      return payload['detail'][0]['msg'] as String;
    }
    return fallback;
  }

  Future<Map<String, dynamic>?> searchMemberByPhone({
    required String phone,
  }) async {
    try {
      final SessionService sessionService = Get.isRegistered<SessionService>()
          ? Get.find<SessionService>()
          : SessionService();
      final token = sessionService.normalizedToken;
      if (token == null || token.isEmpty) {
        throw ApiException('Session expired. Please login again.');
      }

      final response = await http.get(
        Uri.parse('${MembershipApiEndpoints.searchMemberWithPhone}$phone'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final body = response.body;
      ApiResponseLogger.logResponse('Search Member API', response);
      final decoded = body.isNotEmpty ? jsonDecode(body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map<String, dynamic>) {
          return _extractMemberPayload(decoded);
        }
        if (decoded is Map) {
          return _extractMemberPayload(Map<String, dynamic>.from(decoded));
        }
        return null;
      }

      if (response.statusCode == 404) {
        return null;
      }

      throw ApiException(
        _extractMessage(decoded, fallback: 'Unable to search member'),
        statusCode: response.statusCode,
        detail: _extractDetail(decoded),
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      debugPrint("Search Member error: $e");
      return null; // Return null if user is not found
    }
  }

  Map<String, dynamic>? _extractMemberPayload(Map<String, dynamic> source) {
    for (final key in const <String>['data', 'member', 'user', 'result']) {
      final value = source[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    return source;
  }

  Future<Map<String, dynamic>> purchaseMembership({
    required String gymId,
    required String planId,
    required String userId,
    required num amount,
    required String paymentMode,
  }) async {
    try {
      final SessionService sessionService = Get.isRegistered<SessionService>()
          ? Get.find<SessionService>()
          : SessionService();
      final token = sessionService.normalizedToken;
      if (token == null) {
        throw ApiException('No auth token. Please login again.');
      }

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

      final body = response.body;
      ApiResponseLogger.logResponse('Membership Purchase API', response);
      final decoded = body.isNotEmpty ? jsonDecode(body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded is Map<String, dynamic>
            ? decoded
            : {'message': 'Success'};
      }

      final message = _extractMessage(
        decoded,
        fallback: 'Unable to activate membership',
      );
      throw ApiException(
        message,
        statusCode: response.statusCode,
        detail: decoded,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      debugPrint("Membership purchase error: $e");
      throw ApiException('Something went wrong, please try again.');
    }
  }

  dynamic _extractDetail(dynamic payload) {
    if (payload is Map && payload.containsKey('detail')) {
      return payload['detail'];
    }
    return null;
  }
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.detail});

  final String message;
  final int? statusCode;
  final dynamic detail;

  String get detailMessage {
    if (detail is String) return detail as String;
    if (detail is List && detail.isNotEmpty) {
      // Try to join all messages from detail objects if present.
      final msgs = detail
          .whereType<Map>()
          .map((m) => m['msg'])
          .whereType<String>()
          .toList();
      if (msgs.isNotEmpty) {
        return msgs.join('\n');
      }
    }
    return message;
  }

  @override
  String toString() => message;
}
