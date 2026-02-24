import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiServices {
  static const String baseUrl = "https://api.azanto.in/api/v1/auth";

  /// Calls the login API and returns the decoded JSON body.
  /// Throws [ApiException] with a friendly message when the request fails.
  Future<Map<String, dynamic>> loginUser({
    required String phoneno,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: const {"Content-Type": "application/x-www-form-urlencoded"},
        body: {"username": phoneno, "password": password},
      );

      final body = response.body;
      final decoded = body.isNotEmpty ? jsonDecode(body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }

      final message = _extractMessage(decoded, fallback: 'Unable to login');
      final detail = _extractDetail(decoded);
      // Log server-provided error details for debugging.
      print(
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
      print("Login unexpected error: $e");
      throw ApiException('Something went wrong, please try again.');
    }
  }

  Future<Map<String, dynamic>> signupUser({
    required String fullName,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": fullName,
          "phone": phone,
          "password": password,
          "role": "admin",
        }),
      );

      final body = response.body;
      final decoded = body.isNotEmpty ? jsonDecode(body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }

      final message = response.statusCode >= 500
          ? 'Server error, please try again later'
          : _extractMessage(decoded, fallback: 'Unable to sign up');
      final detail = _extractDetail(decoded);
      print(
        "Signup failed (${response.statusCode}): ${response.body.isNotEmpty ? response.body : message}",
      );
      throw ApiException(
        message,
        statusCode: response.statusCode,
        detail: detail ?? decoded,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      print("Signup unexpected error: $e");
      throw ApiException('Something went wrong, please try again.');
    }
  }

  Future<Map<String, dynamic>> requestOtp({required String phone}) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/request-otp"),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone}),
      );

      final body = response.body;
      final decoded = body.isNotEmpty ? jsonDecode(body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }

      final message = response.statusCode >= 500
          ? 'Server error, please try again later'
          : _extractMessage(decoded, fallback: 'Unable to send code');
      final detail = _extractDetail(decoded);
      print(
        "Request OTP failed (${response.statusCode}): ${response.body.isNotEmpty ? response.body : message}",
      );
      throw ApiException(
        message,
        statusCode: response.statusCode,
        detail: detail ?? decoded,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      print("Request OTP unexpected error: $e");
      throw ApiException('Something went wrong, please try again.');
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verify-otp"),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "otp": otp}),
      );

      final body = response.body;
      final decoded = body.isNotEmpty ? jsonDecode(body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }

      final message = response.statusCode >= 500
          ? 'Server error, please try again later'
          : _extractMessage(decoded, fallback: 'Unable to verify code');
      final detail = _extractDetail(decoded);
      print(
        "Verify OTP failed (${response.statusCode}): ${response.body.isNotEmpty ? response.body : message}",
      );
      throw ApiException(
        message,
        statusCode: response.statusCode,
        detail: detail ?? decoded,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      print("Verify OTP unexpected error: $e");
      throw ApiException('Something went wrong, please try again.');
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/reset-password"),
        headers: const {"Content-Type": "application/json"},
        body: jsonEncode({
          "reset_token": resetToken,
          "new_password": newPassword,
        }),
      );

      final body = response.body;
      final decoded = body.isNotEmpty ? jsonDecode(body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      }

      final message = response.statusCode >= 500
          ? 'Server error, please try again later'
          : _extractMessage(decoded, fallback: 'Unable to reset password');
      final detail = _extractDetail(decoded);
      print(
        "Reset password failed (${response.statusCode}): ${response.body.isNotEmpty ? response.body : message}",
      );
      throw ApiException(
        message,
        statusCode: response.statusCode,
        detail: detail ?? decoded,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      print("Reset password unexpected error: $e");
      throw ApiException('Something went wrong, please try again.');
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
