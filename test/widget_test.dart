import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Route constants are stable', () {
    expect(AppRoutes.splash, '/');
    expect(AppRoutes.roleSelection, '/role-selection');
    expect(AppRoutes.authEntry, '/auth-entry');
    expect(AppRoutes.login, '/login');
  });

test('Brand color remains unchanged', () {
  expect(AppColors.brandGreen.toARGB32(), 0xFF74FD15);
});
}
