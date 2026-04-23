import 'package:azanto/Services/session_service.dart';
import 'package:azanto/core/auth/auth_role.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthGuard extends GetMiddleware {
  AuthGuard({int priority = 1, this.allowedRoles}) : _priority = priority;

  @override
  int? get priority => _priority;

  final int _priority;
  final Set<String>? allowedRoles;

  SessionService? get _session =>
      Get.isRegistered<SessionService>() ? Get.find<SessionService>() : null;

  @override
  RouteSettings? redirect(String? route) {
    final session = _session;
    final loggedIn = session?.isLoggedIn ?? false;
    if (!loggedIn) {
      return const RouteSettings(name: AppRoutes.roleSelection);
    }

    final currentRole = session?.authenticatedRole;
    if (currentRole == null) {
      _showSnackbar(
        'Session expired',
        'Please sign in again so we can verify your role.',
      );
      session?.clearSession();
      return const RouteSettings(name: AppRoutes.roleSelection);
    }

    final supportedRoles = allowedRoles;
    if (supportedRoles != null && !supportedRoles.contains(currentRole)) {
      final targetRoute = _fallbackRouteForRole(session, currentRole);
      final restrictedTo = supportedRoles.contains(AuthRole.owner)
          ? AuthRole.label(AuthRole.owner)
          : AuthRole.label(AuthRole.member);
      _showSnackbar(
        'Access restricted',
        'This section is only available for $restrictedTo accounts.',
      );
      return RouteSettings(name: targetRoute);
    }

    return null;
  }

  String _fallbackRouteForRole(SessionService? session, String currentRole) {
    if (currentRole == AuthRole.member) {
      return AppRoutes.memberDashboard;
    }

    final hasGym = session?.gymId?.isNotEmpty ?? false;
    return hasGym ? AppRoutes.home : AppRoutes.gymOnboarding;
  }

  void _showSnackbar(String title, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    });
  }
}
