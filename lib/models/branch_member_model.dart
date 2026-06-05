class BranchMemberModel {
  const BranchMemberModel({
    required this.id,
    required this.branchId,
    required this.userId,
    required this.status,
    required this.joinedAt,
    this.displayName,
    this.phone,
    this.avatarUrl,
    this.planName,
  });

  final String id;
  final String branchId;
  final String userId;
  final String status;
  final DateTime? joinedAt;
  final String? displayName;
  final String? phone;
  final String? avatarUrl;
  final String? planName;

  String get effectiveName {
    final name = displayName?.trim() ?? '';
    if (name.isNotEmpty) return name;

    final shortId = shortUserId;
    if (shortId.isNotEmpty) return 'Member $shortId';
    return 'Member';
  }

  String get shortUserId {
    final normalized = userId.trim();
    if (normalized.isEmpty) return '';
    if (normalized.length <= 8) return normalized;
    return '${normalized.substring(0, 8)}...';
  }

  String get normalizedStatus => status.trim().toLowerCase();

  String get statusLabel {
    final normalized = normalizedStatus;
    if (normalized.isEmpty) return 'Unknown';
    if (normalized == 'active') return 'Active';
    if (normalized == 'expired') return 'Expired';
    if (normalized == 'pending') return 'Pending';
    if (normalized == 'inactive') return 'Inactive';
    return normalized.substring(0, 1).toUpperCase() + normalized.substring(1);
  }

  bool matchesFilter(String filter) {
    final normalizedFilter = filter.trim().toLowerCase();
    if (normalizedFilter.isEmpty || normalizedFilter == 'all') return true;
    return normalizedStatus == normalizedFilter;
  }

  bool matchesSearch(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    final joinedText = joinedAt?.toIso8601String() ?? '';
    final tokens = <String>[
      id,
      branchId,
      userId,
      status,
      effectiveName,
      phone ?? '',
      planName ?? '',
      joinedText,
    ];

    return tokens.any((token) => token.toLowerCase().contains(normalized));
  }

  factory BranchMemberModel.fromJson(Map<String, dynamic> json) {
    final user = _readMap(json, const [
      'user',
      'member',
      'profile',
      'user_profile',
      'member_profile',
    ]);
    final plan = _readMap(json, const [
      'plan',
      'membership_plan',
      'membershipPlan',
    ]);

    final firstName = _readText(
      json,
      const ['first_name', 'firstName'],
      nested: user,
    );
    final lastName = _readText(
      json,
      const ['last_name', 'lastName'],
      nested: user,
    );
    final combinedName = [firstName, lastName]
        .where((part) => part != null && part.trim().isNotEmpty)
        .join(' ')
        .trim();
    final fallbackName = _readText(
      json,
      const [
        'name',
        'full_name',
        'fullName',
        'display_name',
        'displayName',
        'member_name',
        'memberName',
      ],
      nested: user,
    );

    return BranchMemberModel(
      id: _readText(json, const ['id', 'membership_id', 'membershipId']) ?? '',
      branchId: _readText(json, const ['branch_id', 'branchId']) ?? '',
      userId: _readText(
              json, const ['user_id', 'userId', 'member_id', 'memberId']) ??
          '',
      status: _readText(json, const ['status', 'membership_status']) ?? '',
      joinedAt: _parseDateTime(json['joined_at'] ?? json['joinedAt']),
      displayName: combinedName.isNotEmpty ? combinedName : fallbackName,
      phone: _readText(
        json,
        const ['phone', 'mobile', 'phone_number', 'phoneNumber'],
        nested: user,
      ),
      avatarUrl: _readText(
        json,
        const ['avatar_url', 'avatarUrl', 'profile_image', 'profileImage'],
        nested: user,
      ),
      planName: _readText(
        json,
        const ['plan_name', 'planName', 'membership_name', 'membershipName'],
        nested: plan,
      ),
    );
  }

  static Map<String, dynamic>? _readMap(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static String? _readText(
    Map<String, dynamic> source,
    List<String> keys, {
    Map<String, dynamic>? nested,
  }) {
    for (final key in keys) {
      final value = source[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }

    if (nested == null) return null;
    for (final key in keys) {
      final value = nested[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
