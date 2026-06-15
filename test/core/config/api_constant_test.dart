import 'package:azanto/core/config/api_constant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('member profile endpoint uses profile API host', () {
    expect(
      MemberProfileApiEndpoints.getProfile,
      'https://devapi.azanto.in/profile/api/v1/member/get-profile',
    );
  });

  test('member avatar endpoint uses profile API host', () {
    expect(
      MemberProfileApiEndpoints.getAvatar,
      'https://devapi.azanto.in/profile/api/v1/member/get-avatar',
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

  test('enrolled plan endpoint uses profile API host', () {
    expect(
      MembershipApiEndpoints.enrolledPlan,
      'https://devapi.azanto.in/profile/api/v1/membership/enrolled-plan',
    );
  });

  test('attendance endpoints use profile API host', () {
    expect(
      AttendanceApiEndpoints.checkIn,
      'https://devapi.azanto.in/profile/api/v1/attendance/checkin',
    );
    expect(
      AttendanceApiEndpoints.checkOut,
      'https://devapi.azanto.in/profile/api/v1/attendance/checkout',
    );
    expect(
      AttendanceApiEndpoints.myAttendance,
      'https://devapi.azanto.in/profile/api/v1/attendance/my-attendance',
    );
  });

  test('workout endpoints use profile host', () {
    expect(
      WorkoutApiEndpoints.createCategory,
      'https://devapi.azanto.in/profile/api/v1/workout/create-categories',
    );
    expect(
      WorkoutApiEndpoints.getCategories,
      'https://devapi.azanto.in/profile/api/v1/workout/get-categories',
    );
    expect(
      WorkoutApiEndpoints.bodyPartsForCategory('cat-1'),
      'https://devapi.azanto.in/profile/api/v1/workout/categories/cat-1/body-parts',
    );
    expect(
      WorkoutApiEndpoints.exercisesForBodyPart('part-1'),
      'https://devapi.azanto.in/profile/api/v1/workout/body-parts/part-1/exercises',
    );
    expect(
      WorkoutApiEndpoints.completeExercise('track-1'),
      'https://devapi.azanto.in/profile/api/v1/workout/complete-exercise/track-1',
    );
    expect(
      WorkoutApiEndpoints.logHistory('log-1'),
      'https://devapi.azanto.in/profile/api/v1/workout/logs/log-1/history',
    );
  });
}
