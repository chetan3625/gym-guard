import 'dart:convert';

import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/gym_service.dart';
import 'package:azanto/Services/token_refresh_manager.dart';
import 'package:azanto/core/auth/auth_role.dart';
import 'package:azanto/controllers/profile_controller.dart';
import 'package:azanto/models/gym_model.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:azanto/views/pages/gym_details_page.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxBool isProfileOpen = false.obs;
  final SessionService session = Get.find<SessionService>();
  final RxMap<String, dynamic> tokenPayload = <String, dynamic>{}.obs;
  final RxString tokenPayloadError = ''.obs;
  final RxString displayName = 'User'.obs;
  final RxString roleTitle = 'Gym Administrator'.obs;
  final RxBool showAddGymCard = true.obs;
  final RxBool showGymPrompt = false.obs;
  final Rxn<GymSummaryData> gymSummary = Rxn<GymSummaryData>();
  bool _gymPromptLaunched = false;
  late final GymService _gymService = GymService(sessionService: session);

  bool get isOwner {
    final sessionRole = session.authenticatedRole;
    if (sessionRole != null) {
      return sessionRole == AuthRole.owner;
    }
    final rawRole = _rawRoleFromClaims(tokenPayload) ?? roleTitle.value;
    final normalized = rawRole.toLowerCase();
    return normalized.contains('owner');
  }

  @override
  void onReady() {
    super.onReady();
    _loadTokenPayload();
    _evaluateGymState();
  }

  void changeTab(int index) {
    if (index == currentIndex.value) return;
    isProfileOpen.value = false;
    currentIndex.value = index;
  }

  void openProfile() {
    isProfileOpen.value = true;
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().loadProfileAndAvatar();
    }
  }

  void updateDisplayNameFromProfile({
    required String firstName,
    required String lastName,
  }) {
    final fullName = [firstName.trim(), lastName.trim()]
        .where((value) => value.isNotEmpty)
        .join(' ')
        .trim();
    if (fullName.isNotEmpty) {
      displayName.value = fullName;
    }
  }

  void closeProfile() {
    isProfileOpen.value = false;
  }

  String get greetingMessage {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  String get avatarLetter {
    final normalizedName = displayName.value.trim();
    if (normalizedName.isEmpty) return 'U';
    return normalizedName.substring(0, 1).toUpperCase();
  }

  Future<void> onLogout() async {
    await TokenRefreshManager.clearState();
    await session.clearSession();
    Get.offAllNamed(AppRoutes.roleSelection);
  }

  bool get shouldShowAddGymCard => showAddGymCard.value;
  bool get shouldLaunchGymPrompt =>
      showGymPrompt.value && !_gymPromptLaunched && isOwner;

  void markGymPromptLaunched() {
    _gymPromptLaunched = true;
  }

  Future<void> dismissGymPrompt() async {
    await session.setGymPromptDismissed(true);
    showGymPrompt.value = false;
  }

  Future<void> markGymCreated({
    required String gymId,
    required String gymName,
    String? email,
    String? description,
  }) async {
    await session.setGymId(gymId);
    showAddGymCard.value = false;
    showGymPrompt.value = false;
    gymSummary.value = GymSummaryData(
      gymId: gymId,
      gymName: gymName,
      email: email,
      description: description,
    );
  }

  Future<void> openGymDetails() async {
    final summary = gymSummary.value;
    final gymId = summary?.gymId ?? session.gymId;
    if (gymId == null || gymId.trim().isEmpty) return;

    final updatedGym = await Get.to<GymModel>(
      () => GymDetailsPage(
        gymId: gymId,
        initialTitle: summary?.gymName,
      ),
    );

    if (updatedGym != null) {
      gymSummary.value = GymSummaryData(
        gymId: updatedGym.id,
        gymName: updatedGym.name,
        email: updatedGym.email,
        description: updatedGym.description,
      );
    }
  }

  void _evaluateGymState() {
    if (!isOwner) {
      showAddGymCard.value = false;
      showGymPrompt.value = false;
      return;
    }
    final hasGym = (session.gymId?.isNotEmpty ?? false);
    showAddGymCard.value = !hasGym;
    showGymPrompt.value = !hasGym && !session.isGymPromptDismissed;
    if (hasGym && gymSummary.value == null) {
      _hydrateGymSummary();
    }
  }

  Future<void> _hydrateGymSummary() async {
    // Prefer live API data; fall back to token claims if needed.
    try {
      final gym = await _gymService.getGymForOwner();
      if (gym != null) {
        final gymId = (gym['gym_id'] ?? gym['id'] ?? '').toString().trim();
        final name = (gym['name'] ?? '').toString().trim();
        final email = (gym['email'] ?? '').toString().trim();
        final desc = gym['description']?.toString().trim();
        gymSummary.value = GymSummaryData(
          gymId: gymId,
          gymName: name.isNotEmpty ? name : 'Your gym',
          email: email.isNotEmpty ? email : null,
          description: (desc != null && desc.isNotEmpty) ? desc : null,
        );
        return;
      }
    } catch (_) {
      // Ignore API errors; fall back to token claims below.
    }

    final resolvedGymName = _extractGymName(tokenPayload) ??
        (session.gymId?.isNotEmpty ?? false
            ? 'Gym ${session.gymId}'
            : 'Your gym');
    final resolvedDescription = tokenPayload['gym_description'] as String? ??
        tokenPayload['gymDescription'] as String?;
    gymSummary.value = GymSummaryData(
      gymId: session.gymId,
      gymName: resolvedGymName,
      description: resolvedDescription?.trim().isEmpty ?? true
          ? null
          : resolvedDescription!.trim(),
    );
  }

  void _loadTokenPayload() {
    final rawToken = session.token?.trim() ?? '';
    if (rawToken.isEmpty) {
      tokenPayload.clear();
      tokenPayloadError.value = 'No auth token found in session.';
      displayName.value = 'User';
      roleTitle.value = 'Gym Administrator';
      debugPrint('Home token payload: missing token');
      return;
    }

    final claims = _decodeJwtPayload(rawToken);
    if (claims == null) {
      tokenPayload.clear();
      tokenPayloadError.value =
          'Token payload could not be decoded (token may not be JWT).';
      displayName.value = 'User';
      roleTitle.value = 'Gym Administrator';
      debugPrint('Home token payload: decode failed');
      return;
    }

    tokenPayload.assignAll(claims);
    final resolvedName = _extractDisplayName(claims);
    final resolvedRole = _extractRoleTitle(claims);
    if (resolvedName.isNotEmpty) {
      displayName.value = resolvedName;
    }
    if (resolvedRole.isNotEmpty) {
      roleTitle.value = resolvedRole;
    }
    tokenPayloadError.value = '';
    debugPrint('Home token payload: $claims');
  }

  void onAddMemberTapped() {
    Get.toNamed(AppRoutes.searchMember);
  }

  String _extractDisplayName(Map<String, dynamic> claims) {
    const preferredKeys = <String>[
      'name',
      'fullName',
      'full_name',
      'displayName',
      'display_name',
      'username',
      'user_name',
      'adminName',
      'admin_name',
      'owner_name',
    ];

    for (final key in preferredKeys) {
      final value = claims[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    final userMap = claims['user'];
    if (userMap is Map) {
      final userClaims = Map<String, dynamic>.from(userMap);
      for (final key in preferredKeys) {
        final value = userClaims[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }

    final subject = claims['sub'];
    if (subject is String && subject.trim().isNotEmpty) {
      final cleanedSubject = subject.trim();
      final onlyDigits = RegExp(r'^\d+$');
      if (!onlyDigits.hasMatch(cleanedSubject)) {
        return cleanedSubject;
      }
    }

    return '';
  }

  String _extractRoleTitle(Map<String, dynamic> claims) {
    const roleKeys = <String>[
      'role',
      'userRole',
      'user_role',
      'designation',
      'title',
    ];

    for (final key in roleKeys) {
      final value = claims[key];
      if (value is String && value.trim().isNotEmpty) {
        return _formatRole(value);
      }
    }

    final userMap = claims['user'];
    if (userMap is Map) {
      final userClaims = Map<String, dynamic>.from(userMap);
      for (final key in roleKeys) {
        final value = userClaims[key];
        if (value is String && value.trim().isNotEmpty) {
          return _formatRole(value);
        }
      }
    }

    return '';
  }

  String _formatRole(String rawRole) {
    final normalized = rawRole.replaceAll('_', ' ').trim();
    if (normalized.isEmpty) return '';
    return normalized
        .split(RegExp(r'\s+'))
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return null;
      }

      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  String? _extractGymName(Map<String, dynamic> claims) {
    const gymKeys = <String>[
      'gym_name',
      'gymName',
      'gym',
      'gym_title',
      'gymTitle',
    ];

    for (final key in gymKeys) {
      final value = claims[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    final gymMap = claims['gym'];
    if (gymMap is Map) {
      final map = Map<String, dynamic>.from(gymMap);
      for (final key in gymKeys) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
    return null;
  }

  String? _rawRoleFromClaims(Map<String, dynamic> claims) {
    const roleKeys = <String>[
      'role',
      'userRole',
      'user_role',
      'designation',
      'title',
    ];

    for (final key in roleKeys) {
      final value = claims[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    final userMap = claims['user'];
    if (userMap is Map) {
      final userClaims = Map<String, dynamic>.from(userMap);
      for (final key in roleKeys) {
        final value = userClaims[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }

    return null;
  }
}

class GymSummaryData {
  const GymSummaryData({
    this.gymId,
    required this.gymName,
    this.email,
    this.description,
  });

  final String? gymId;
  final String gymName;
  final String? email;
  final String? description;
}
