import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiResponseLogger {
  const ApiResponseLogger._();

  static void logResponse(
    String label,
    http.Response response, {
    Uri? uri,
  }) {
    final resolvedUri = uri ?? response.request?.url;
    debugPrint('------($label Response)--------');
    if (resolvedUri != null) {
      debugPrint('URL: $resolvedUri');
    }
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Headers: ${response.headers}');
    debugPrint('Body: ${response.body.isNotEmpty ? response.body : 'no body'}');
    debugPrint('-----end-----');
  }
}
