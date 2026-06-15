class MemberMembershipModel {
  const MemberMembershipModel({
    required this.membershipId,
    required this.gymId,
    required this.branchId,
    required this.planId,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  final String membershipId;
  final String gymId;
  final String branchId;
  final String planId;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;

  factory MemberMembershipModel.fromJson(Map<String, dynamic> json) {
    return MemberMembershipModel(
      membershipId: (json['membership_id'] ?? json['membershipId'] ?? '').toString().trim(),
      gymId: (json['gym_id'] ?? json['gymId'] ?? '').toString().trim(),
      branchId: (json['branch_id'] ?? json['branchId'] ?? '').toString().trim(),
      planId: (json['plan_id'] ?? json['planId'] ?? '').toString().trim(),
      status: (json['status'] ?? '').toString().trim(),
      startDate: _parseDate(json['start_date'] ?? json['startDate']),
      endDate: _parseDate(json['end_date'] ?? json['endDate']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Map<String, dynamic> toJson() {
    return {
      'membership_id': membershipId,
      'gym_id': gymId,
      'branch_id': branchId,
      'plan_id': planId,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }
}
