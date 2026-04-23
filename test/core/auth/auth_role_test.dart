import 'package:azanto/core/auth/auth_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRole.normalize', () {
    test('normalizes owner role variants', () {
      expect(AuthRole.normalize('owner'), AuthRole.owner);
      expect(AuthRole.normalize('gym_owner'), AuthRole.owner);
      expect(AuthRole.normalize('Gym Owner'), AuthRole.owner);
    });

    test('normalizes member role variants', () {
      expect(AuthRole.normalize('member'), AuthRole.member);
      expect(AuthRole.normalize('gym_member'), AuthRole.member);
      expect(AuthRole.normalize('Gym Member'), AuthRole.member);
    });

    test('returns null for unsupported roles', () {
      expect(AuthRole.normalize('admin'), isNull);
      expect(AuthRole.normalize(''), isNull);
      expect(AuthRole.normalize(null), isNull);
    });
  });

  group('AuthRole.extractFromPayload', () {
    test('reads top-level role from api response', () {
      expect(
        AuthRole.extractFromPayload(<String, dynamic>{'role': 'member'}),
        AuthRole.member,
      );
    });

    test('reads nested role from token-style payload', () {
      expect(
        AuthRole.extractFromPayload(<String, dynamic>{
          'user': <String, dynamic>{'role': 'gym_owner'},
        }),
        AuthRole.owner,
      );
    });
  });

  group('AuthRole.matches', () {
    test('matches normalized app role and backend role', () {
      expect(
        AuthRole.matches(appRole: 'owner', responseRole: 'gym_owner'),
        isTrue,
      );
      expect(
        AuthRole.matches(appRole: 'member', responseRole: 'Gym Member'),
        isTrue,
      );
    });

    test('rejects mismatched roles', () {
      expect(
        AuthRole.matches(appRole: 'member', responseRole: 'owner'),
        isFalse,
      );
    });
  });
}
