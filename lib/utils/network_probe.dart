import 'package:http/http.dart' as http;

class NetworkProbe {
  NetworkProbe._();

  static final http.Client _client = http.Client();
  static final Uri _probeUri = Uri.parse(
    'https://clients3.google.com/generate_204',
  );

  static Future<bool> hasInternetAccess({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final response = await _client
          .get(
            _probeUri,
            headers: const <String, String>{'Cache-Control': 'no-cache'},
          )
          .timeout(timeout);
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (_) {
      return false;
    }
  }
}
