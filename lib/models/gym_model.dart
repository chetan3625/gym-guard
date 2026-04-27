class GymModel {
  const GymModel({
    required this.id,
    required this.name,
    required this.email,
    required this.description,
    required this.isActive,
    this.logoUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? description;
  final bool isActive;
  final String? logoUrl;

  GymModel copyWith({
    String? id,
    String? name,
    String? email,
    String? description,
    bool? isActive,
    String? logoUrl,
  }) {
    return GymModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  factory GymModel.fromJson(Map<String, dynamic> json) {
    return GymModel(
      id: (json['id'] ?? json['gym_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      description: json['description']?.toString().trim(),
      isActive: _parseBool(json['is_active'] ?? json['isActive']),
      logoUrl: _parseLogoUrl(json),
    );
  }

  static String? _parseLogoUrl(Map<String, dynamic> json) {
    final rawValue = json['logo_url'] ??
        json['logoUrl'] ??
        json['logo'] ??
        json['image'] ??
        json['image_url'];
    final trimmed = rawValue?.toString().trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return trimmed.startsWith('/') ? trimmed : '/$trimmed';
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
}
