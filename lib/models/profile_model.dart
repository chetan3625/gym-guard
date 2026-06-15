import 'package:azanto/models/membership_model.dart';

class ProfileModel {
  const ProfileModel({
    required this.firstName,
    required this.lastName,
    required this.quote,
    required this.gender,
    required this.dob,
    required this.height,
    required this.weight,
    required this.phone,
    required this.email,
    required this.id,
    required this.avatarUrl,
    required this.userId,
    this.membership,
  });

  final String firstName;
  final String lastName;
  final String quote;
  final String gender;
  final String dob;
  final num height;
  final num weight;
  final String phone;
  final String email;
  final String id;
  final String avatarUrl;
  final String userId;
  final MemberMembershipModel? membership;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      firstName: (json['first_name'] ?? '').toString().trim(),
      lastName: (json['last_name'] ?? '').toString().trim(),
      quote: (json['quote'] ?? '').toString().trim(),
      gender: (json['gender'] ?? '').toString().trim(),
      dob: (json['dob'] ?? '').toString().trim(),
      height: _parseNum(json['height']),
      weight: _parseNum(json['weight']),
      phone: (json['phone'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      id: (json['id'] ?? '').toString().trim(),
      avatarUrl: (json['avatar_url'] ?? '').toString().trim(),
      userId: (json['user_id'] ?? '').toString().trim(),
      membership: json['membership'] != null
          ? MemberMembershipModel.fromJson(
              Map<String, dynamic>.from(json['membership'] as Map),
            )
          : null,
    );
  }

  static num _parseNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}
