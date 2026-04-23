class GymModel {
  const GymModel({
    required this.id,
    required this.name,
    required this.email,
    required this.description,
    required this.isActive,
  });

  final String id;
  final String name;
  final String email;
  final String? description;
  final bool isActive;

  factory GymModel.fromJson(Map<String, dynamic> json) {
    return GymModel(
      id: (json['id'] ?? json['gym_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      description: json['description']?.toString().trim(),
      isActive: _parseBool(json['is_active'] ?? json['isActive']),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
}
