import 'package:azanto/Services/login_services.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:azanto/utils/network_probe.dart';
import 'package:get/get.dart';

class BackendErrorPayload {
  const BackendErrorPayload({this.title, this.message});

  final String? title;
  final String? message;
}

class BackendErrorWidgets {
  static Future<void> showBackendError({String? title, String? message}) async {
    if (Get.currentRoute == AppRoutes.backendError) {
      return;
    }

    await Get.toNamed(
      AppRoutes.backendError,
      arguments: BackendErrorPayload(title: title, message: message),
    );
  }

  static Future<bool> handleApiException(ApiException error) async {
    final statusCode = error.statusCode;
    if (statusCode != null && statusCode >= 500) {
      await showBackendError(message: error.detailMessage);
      return true;
    }

    if (!_looksLikeServerTimeout(error.detailMessage)) {
      return false;
    }

    final hasInternet = await NetworkProbe.hasInternetAccess();
    if (!hasInternet) {
      return false;
    }

    await showBackendError(message: error.detailMessage);
    return true;
  }

  static bool hideBackendError({bool retry = false}) {
    final canPop = Get.key.currentState?.canPop() ?? false;
    if (!canPop) {
      return false;
    }

    Get.back(result: retry);
    return true;
  }

  static bool _looksLikeServerTimeout(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('timed out') ||
        normalized.contains('timeout') ||
        normalized.contains('temporarily unavailable');
  }
}
