class Plan {
  const Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.isActive,
  });

  final String id;
  final String name;
  final String description;
  final num price;
  final int durationDays;
  final bool isActive;

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: (json['id'] ?? json['plan_id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString().trim(),
      description: (json['description'] ?? '').toString().trim(),
      price: _parseNum(json['base_price'] ?? json['price'] ?? json['amount']),
      durationDays: _parseInt(
        json['duration_days'] ?? json['duration'] ?? json['days'],
      ),
      isActive: _parseBool(json['is_active'] ?? json['isActive']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static num _parseNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().trim().toLowerCase() ?? '';
    return text == 'true' || text == '1' || text == 'yes';
  }
}
