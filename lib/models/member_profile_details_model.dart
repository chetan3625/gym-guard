import 'package:azanto/models/membership_model.dart';

class MemberProfileDetailsModel {
  const MemberProfileDetailsModel({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.quote,
    required this.dob,
    required this.height,
    required this.weight,
    required this.isActive,
    required this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    this.membership,
  });

  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final String quote;
  final DateTime? dob;
  final num? height;
  final num? weight;
  final bool isActive;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final MemberMembershipModel? membership;

  String get fullName {
    final name = [firstName, lastName]
        .where((part) => part.trim().isNotEmpty)
        .join(' ')
        .trim();
    return name.isEmpty ? 'Member' : name;
  }

  String get initials {
    final parts = fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'M';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  factory MemberProfileDetailsModel.fromJson(Map<String, dynamic> json) {
    return MemberProfileDetailsModel(
      id: _readText(json, const ['id']) ?? '',
      userId: _readText(json, const ['user_id', 'userId']) ?? '',
      firstName: _readText(json, const ['first_name', 'firstName']) ?? '',
      lastName: _readText(json, const ['last_name', 'lastName']) ?? '',
      email: _readText(json, const ['email']) ?? '',
      phone: _readText(json, const ['phone', 'mobile', 'phone_number']) ?? '',
      gender: _readText(json, const ['gender']) ?? '',
      quote: _readText(json, const ['quote']) ?? '',
      dob: _parseDate(json['dob']),
      height: _parseNum(json['height']),
      weight: _parseNum(json['weight']),
      isActive: _parseBool(json['is_active'] ?? json['isActive']),
      avatarUrl: _readText(json, const ['avatar_url', 'avatarUrl']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
      membership: json['membership'] != null
          ? MemberMembershipModel.fromJson(
              Map<String, dynamic>.from(json['membership'] as Map),
            )
          : null,
    );
  }

  static String? _readText(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static num? _parseNum(dynamic value) {
    if (value is num) return value;
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) return null;
    return num.tryParse(raw);
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    final raw = value?.toString().trim().toLowerCase() ?? '';
    return raw == 'true' || raw == '1' || raw == 'active';
  }
}
