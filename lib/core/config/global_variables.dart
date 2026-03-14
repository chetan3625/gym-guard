class GlobalVariables {
  const GlobalVariables._();

  // Split hosts: auth is served from api.azanto.in, profile/gym from profile-backend.
  static const String authHost = 'https://api.azanto.in';
  static const String apiHost = 'https://profile-backend-d3ts.onrender.com';

  static const String apiVersion = '/api/v1';
  static const String authBaseUrl = '$authHost$apiVersion/auth';
  static const String apiBaseUrl = '$apiHost$apiVersion';
  static const String memberProfileBaseUrl = '$apiBaseUrl/profile/member';
}

class AuthApiEndpoints {
  const AuthApiEndpoints._();

  static const String login = '${GlobalVariables.authBaseUrl}/login';
  static const String register = '${GlobalVariables.authBaseUrl}/register';
  static const String requestOtp = '${GlobalVariables.authBaseUrl}/request-otp';
  static const String verifyOtp = '${GlobalVariables.authBaseUrl}/verify-otp';
  static const String resetPassword =
      '${GlobalVariables.authBaseUrl}/reset-password';
  static const String refreshToken = '${GlobalVariables.authBaseUrl}/refresh';
}

class PlanApiEndpoints {
  const PlanApiEndpoints._();

  static const String createPlan =
      '${GlobalVariables.apiBaseUrl}/profile/plan/create-plan';
  static const String getAllPlans =
      '${GlobalVariables.apiBaseUrl}/profile/plan/get-all-plans';
}

class GymApiEndpoints {
  const GymApiEndpoints._();

  /// Creates a new gym for the authenticated owner.
  static const String createGym =
      '${GlobalVariables.apiBaseUrl}/profile/gym/onboardNewGym';
  static const String addBranch =
      '${GlobalVariables.apiBaseUrl}/profile/gym/branch/addbranch';
}

class MemberProfileApiEndpoints {
  const MemberProfileApiEndpoints._();

  static const String getProfile =
      '${GlobalVariables.memberProfileBaseUrl}/get-profile';
  static const String updateProfile =
      '${GlobalVariables.memberProfileBaseUrl}/update-profile';
  static const String uploadAvatar =
      '${GlobalVariables.memberProfileBaseUrl}/upload-avatar';
  static const String getAvatar =
      '${GlobalVariables.memberProfileBaseUrl}/getavatar';
}
