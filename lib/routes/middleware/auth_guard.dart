import 'package:azanto/Services/session_service.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthGuard extends GetMiddleware {
  AuthGuard({this.priority = 1});

  @override
  final int? priority;

  SessionService? get _session =>
      Get.isRegistered<SessionService>() ? Get.find<SessionService>() : null;

  @override
  RouteSettings? redirect(String? route) {
    final loggedIn = _session?.isLoggedIn ?? false;
    if (!loggedIn) {
      return const RouteSettings(name: AppRoutes.roleSelection);
    }
    return null;
  }
}
