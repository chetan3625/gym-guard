class AuthRole {
  const AuthRole._();

  static const String owner = 'owner';
  static const String member = 'member';

  static const List<String> _roleKeys = <String>[
    'role',
    'userRole',
    'user_role',
    'designation',
    'title',
    'accountType',
    'account_type',
  ];

  static String? normalize(String? rawRole) {
    if (rawRole == null) return null;

    final cleaned = rawRole
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) return null;
    if (cleaned.contains('owner')) return owner;
    if (cleaned.contains('member')) return member;
    return null;
  }

  static bool matches({
    required String? appRole,
    required String? responseRole,
  }) {
    final normalizedAppRole = normalize(appRole);
    final normalizedResponseRole = normalize(responseRole);
    return normalizedAppRole != null &&
        normalizedResponseRole != null &&
        normalizedAppRole == normalizedResponseRole;
  }

  static String? extractFromPayload(dynamic payload) {
    final map = _asMap(payload);
    if (map == null) return null;

    for (final key in _roleKeys) {
      final normalized = normalize(map[key]?.toString());
      if (normalized != null) {
        return normalized;
      }
    }

    for (final nestedKey in const <String>['user', 'data', 'account']) {
      final nestedMap = _asMap(map[nestedKey]);
      if (nestedMap == null) continue;

      for (final key in _roleKeys) {
        final normalized = normalize(nestedMap[key]?.toString());
        if (normalized != null) {
          return normalized;
        }
      }
    }

    return null;
  }

  static String label(String? rawRole) {
    switch (normalize(rawRole)) {
      case owner:
        return 'Gym Owner';
      case member:
        return 'Gym Member';
      default:
        return 'User';
    }
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
