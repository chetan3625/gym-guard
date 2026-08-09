class MemberHealthModel {
  const MemberHealthModel({
    required this.memberId,
    required this.name,
    required this.phone,
    required this.planName,
    required this.inactiveDays,
    required this.risk,
    this.lastCheckin,
    this.daysToEnd,
  });

  final String memberId;
  final String name;
  final String phone;
  final String planName;
  final int inactiveDays;
  final String risk;
  final DateTime? lastCheckin;
  final int? daysToEnd;

  bool get needsAttention => inactiveDays >= 7;
  bool get isRed => inactiveDays >= 10;

  factory MemberHealthModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) =>
        value == null ? null : DateTime.tryParse(value.toString());
    return MemberHealthModel(
      memberId: (json['member_id'] ?? '').toString(),
      name: (json['name'] ?? 'Member').toString(),
      phone: (json['phone'] ?? '').toString(),
      planName: (json['plan_name'] ?? 'No plan').toString(),
      inactiveDays: (json['inactive_days'] as num?)?.toInt() ?? 0,
      risk: (json['risk'] ?? 'healthy').toString(),
      lastCheckin: parseDate(json['last_checkin']),
      daysToEnd: (json['days_to_end'] as num?)?.toInt(),
    );
  }
}
