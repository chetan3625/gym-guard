class MemberSearchMapper {
  const MemberSearchMapper._();

  static Map<String, dynamic>? extractMemberPayload(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      return _extractNestedMemberMap(decoded) ?? decoded;
    }
    if (decoded is Map) {
      final mapped = Map<String, dynamic>.from(decoded);
      return _extractNestedMemberMap(mapped) ?? mapped;
    }
    return null;
  }

  static String resolveMemberName(Map<String, dynamic> member) {
    final firstName = _read(member, const ['first_name', 'firstName']);
    final lastName = _read(member, const ['last_name', 'lastName']);
    final combinedName = [firstName, lastName]
        .where((part) => part.isNotEmpty)
        .join(' ')
        .trim();

    if (combinedName.isNotEmpty) {
      return combinedName;
    }

    final fallbackName = _read(
      member,
      const [
        'name',
        'full_name',
        'fullName',
        'member_name',
        'memberName',
        'phone',
        'mobile',
      ],
    );
    return fallbackName.isNotEmpty ? fallbackName : 'Member';
  }

  static String? resolveUserId(Map<String, dynamic> member) {
    return _readNullable(
      member,
      const ['user_id', 'userId', 'id', '_id', 'member_id', 'memberId'],
    );
  }

  static String? resolvePhone(Map<String, dynamic> member) {
    return _readNullable(
      member,
      const ['phone', 'mobile', 'phone_number', 'phoneNumber'],
    );
  }

  static Map<String, dynamic>? _extractNestedMemberMap(
    Map<String, dynamic> source,
  ) {
    for (final key in const <String>['data', 'member', 'user', 'result']) {
      final value = source[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static String _read(Map<String, dynamic> source, List<String> keys) {
    return _readNullable(source, keys) ?? '';
  }

  static String? _readNullable(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }
}
