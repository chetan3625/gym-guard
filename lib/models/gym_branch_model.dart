class GymBranchModel {
  const GymBranchModel({
    required this.branchId,
    required this.gymId,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.openingTime,
    required this.closingTime,
    required this.accessCode,
    required this.qrCode,
    required this.createdAt,
  });

  final String branchId;
  final String gymId;
  final String name;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final double latitude;
  final double longitude;
  final bool isActive;
  final String? openingTime;
  final String? closingTime;
  final String? accessCode;
  final String? qrCode;
  final DateTime? createdAt;

  String get fullAddress {
    final parts = <String>[
      address,
      city,
      state,
      country,
      pincode,
    ].where((value) => value.trim().isNotEmpty).toList();
    return parts.join(', ');
  }

  factory GymBranchModel.fromJson(Map<String, dynamic> json) {
    return GymBranchModel(
      branchId: (json['branch_id'] ?? json['id'] ?? '').toString(),
      gymId: (json['gym_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString().trim(),
      address: (json['address'] ?? '').toString().trim(),
      city: (json['city'] ?? '').toString().trim(),
      state: (json['state'] ?? '').toString().trim(),
      country: (json['country'] ?? '').toString().trim(),
      pincode: (json['pincode'] ?? '').toString().trim(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      isActive: _parseBool(json['is_active'] ?? json['isActive']),
      openingTime: _normalizeText(json['opening_time']),
      closingTime: _normalizeText(json['closing_time']),
      accessCode: _normalizeText(json['access_code']),
      qrCode: _normalizeText(json['qr_code']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  static String? _normalizeText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
}
