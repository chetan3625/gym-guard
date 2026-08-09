import 'package:azanto/bindings/auth_entry_binding.dart';
import 'package:azanto/bindings/forgot_password_binding.dart';
import 'package:azanto/bindings/home_binding.dart';
import 'package:azanto/bindings/login_binding.dart';
import 'package:azanto/bindings/role_selection_binding.dart';
import 'package:azanto/bindings/signup_binding.dart';
import 'package:azanto/bindings/splash_binding.dart';
import 'package:azanto/bindings/verify_otp_binding.dart';
import 'package:azanto/bindings/reset_password_binding.dart';
import 'package:azanto/bindings/gym_onboarding_binding.dart';
import 'package:azanto/core/auth/auth_role.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:azanto/routes/middleware/auth_guard.dart';
import 'package:azanto/views/auth_entry_view.dart';
import 'package:azanto/views/forgot_password_view.dart';
import 'package:azanto/views/home_view.dart';
import 'package:azanto/views/login_view.dart';
import 'package:azanto/views/role_selection_view.dart';
import 'package:azanto/views/signup_view.dart';
import 'package:azanto/views/splash_view.dart';
import 'package:azanto/views/verify_otp_view.dart';
import 'package:azanto/views/reset_password_view.dart';
import 'package:azanto/views/password_reset_success_view.dart';
import 'package:azanto/views/gym_onboarding_view.dart';
import 'package:azanto/Memberside/View/member_dashboard.dart';
import 'package:azanto/views/pages/backend_error_screen.dart';
import 'package:azanto/views/pages/gym_payment_page.dart';
import 'package:azanto/views/pages/qr_scanner_page.dart';
import 'package:get/get.dart';
import 'package:azanto/views/pages/members/search_member_view.dart';
import 'package:azanto/bindings/search_member_binding.dart';
import 'package:azanto/views/pages/members/member_plan_selection_view.dart';
import 'package:azanto/bindings/member_plan_selection_binding.dart';

class AppPages {
  const AppPages._();

  static final List<GetPage<dynamic>> pages = [
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: () => const HomeShell(),
      binding: HomeBinding(),
      middlewares: [
        AuthGuard(allowedRoles: <String>{AuthRole.owner}),
      ],
    ),
    GetPage<dynamic>(
      name: AppRoutes.qrScanner,
      page: () => const QrScannerPage(),
      middlewares: [
        AuthGuard(allowedRoles: <String>{AuthRole.owner, AuthRole.member}),
      ],
    ),
    GetPage<dynamic>(
      name: AppRoutes.gymPayment,
      page: () => const GymPaymentPage(),
      middlewares: [
        AuthGuard(allowedRoles: <String>{AuthRole.owner}),
      ],
    ),
    GetPage<dynamic>(
      name: AppRoutes.backendError,
      page: () => const BackendErrorScreen(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionScreen(),
      binding: RoleSelectionBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.authEntry,
      page: () => const AuthEntryScreen(),
      binding: AuthEntryBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.signup,
      page: () => const SignupScreen(),
      binding: SignupBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.verifyOtp,
      page: () => const VerifyOtpScreen(),
      binding: VerifyOtpBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
      binding: ResetPasswordBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.resetPasswordSuccess,
      page: () => const PasswordResetSuccessScreen(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.gymOnboarding,
      page: () => const GymOnboardingScreen(),
      binding: GymOnboardingBinding(),
      middlewares: [
        AuthGuard(allowedRoles: <String>{AuthRole.owner}),
      ],
    ),
    GetPage<dynamic>(
      name: AppRoutes.searchMember,
      page: () => const SearchMemberView(),
      binding: SearchMemberBinding(),
      middlewares: [
        AuthGuard(allowedRoles: <String>{AuthRole.owner}),
      ],
    ),
    GetPage<dynamic>(
      name: AppRoutes.memberPlanSelection,
      page: () => const MemberPlanSelectionView(),
      binding: MemberPlanSelectionBinding(),
      middlewares: [
        AuthGuard(allowedRoles: <String>{AuthRole.owner}),
      ],
    ),
    GetPage<dynamic>(
      name: AppRoutes.memberDashboard,
      page: () => const MemberDashboardScreen(),
      middlewares: [
        AuthGuard(allowedRoles: <String>{AuthRole.member}),
      ],
    ),
  ];
}
