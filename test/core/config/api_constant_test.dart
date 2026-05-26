import 'package:azanto/core/config/api_constant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('member profile endpoint uses profile API host', () {
    expect(
      MemberProfileApiEndpoints.getProfile,
      'https://devapi.azanto.in/profile/api/v1/member/get-profile',
    );
  });

  test('add member endpoint uses gym branch API host', () {
    expect(
      GymApiEndpoints.addMember,
      'https://devapi.azanto.in/gym-branch/api/v1/gym/branch/addmember',
    );
  });

  test('legacy membership purchase constant points to add member route', () {
    expect(
      MembershipApiEndpoints.membershipPurchase,
      'https://devapi.azanto.in/gym-branch/api/v1/gym/branch/addmember',
    );
  });
}
