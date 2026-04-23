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
    );
  }

  static num _parseNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}
