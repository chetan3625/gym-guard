import 'package:azanto/models/branch_member_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps branch member API response', () {
    final member = BranchMemberModel.fromJson(<String, dynamic>{
      'id': 'membership-1',
      'branch_id': 'branch-1',
      'user_id': 'user-123456789',
      'status': 'active',
      'joined_at': '2026-05-26T11:30:43.011Z',
    });

    expect(member.id, 'membership-1');
    expect(member.branchId, 'branch-1');
    expect(member.userId, 'user-123456789');
    expect(member.statusLabel, 'Active');
    expect(member.effectiveName, 'Member user-123...');
    expect(member.joinedAt, isNotNull);
  });

  test('uses nested user fields when backend includes profile data', () {
    final member = BranchMemberModel.fromJson(<String, dynamic>{
      'id': 'membership-1',
      'branch_id': 'branch-1',
      'user_id': 'user-1',
      'status': 'pending',
      'user': <String, dynamic>{
        'first_name': 'Riya',
        'last_name': 'Sharma',
        'phone': '9876543210',
        'avatar_url': 'https://example.com/avatar.png',
      },
      'plan': <String, dynamic>{
        'plan_name': 'Premium Annual',
      },
    });

    expect(member.effectiveName, 'Riya Sharma');
    expect(member.phone, '9876543210');
    expect(member.avatarUrl, 'https://example.com/avatar.png');
    expect(member.planName, 'Premium Annual');
    expect(member.matchesFilter('Pending'), isTrue);
    expect(member.matchesSearch('riya'), isTrue);
  });
}
