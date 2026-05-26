import 'package:azanto/models/member_profile_details_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps member profile API response', () {
    final profile = MemberProfileDetailsModel.fromJson(<String, dynamic>{
      'user_id': '17d162eb-6384-4987-888a-ee74d398381f',
      'avatar_url': null,
      'quote': 'fa',
      'dob': '2026-03-27',
      'phone': '9579071289',
      'is_active': true,
      'updated_at': '2026-03-27T10:37:31.279598+00:00',
      'last_name': 'fr',
      'first_name': 'Chetan Chaudhary',
      'id': '2311746c-50f2-467e-9546-e89bb26dcbbc',
      'gender': 'male',
      'height': 154,
      'weight': 654,
      'email': 'rg',
      'created_at': '2026-03-18T03:23:03.762910+00:00',
    });

    expect(profile.userId, '17d162eb-6384-4987-888a-ee74d398381f');
    expect(profile.fullName, 'Chetan Chaudhary fr');
    expect(profile.initials, 'CF');
    expect(profile.phone, '9579071289');
    expect(profile.isActive, isTrue);
    expect(profile.height, 154);
    expect(profile.weight, 654);
    expect(profile.dob, DateTime(2026, 3, 27));
    expect(profile.updatedAt, isNotNull);
  });
}
