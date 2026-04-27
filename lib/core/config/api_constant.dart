class GlobalVariables {
  const GlobalVariables._();

  static const String authHost = 'https://devapi.azanto.in/auth';
  static const String apiHost = 'https://devapi.azanto.in';
  static const String gymHost = 'https://devapi.azanto.in/gym-branch';

  static const String apiVersion = '/api/v1';
  static const String authBaseUrl = '$authHost$apiVersion';
  static const String apiBaseUrl = '$apiHost$apiVersion';
  static const String gymBaseUrl = '$gymHost$apiVersion';
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
      '${GlobalVariables.gymBaseUrl}/plan/create-plan';
  static const String getAllPlans =
      '${GlobalVariables.gymBaseUrl}/plan/get-all-plans';
  static const String getPlanDetails =
      '${GlobalVariables.gymBaseUrl}/plan/get-plan-details';
  static const String updatePlan =
      '${GlobalVariables.gymBaseUrl}/plan/update-plans';
}

class GymApiEndpoints {
  const GymApiEndpoints._();

  /// Creates a new gym
  static const String createGym =
      '${GlobalVariables.gymBaseUrl}/gym/onboardNewGym';
  static const String addBranch =
      '${GlobalVariables.gymBaseUrl}/gym/branch/addbranch';
  static const String getAllBranches =
      '${GlobalVariables.gymBaseUrl}/gym/get-all-branches';
  static const String getBranchDetails =
      '${GlobalVariables.gymBaseUrl}/gym/branch/getbranchdetails';

  /// Returns the gyms owned
  static const String getGym =
      '${GlobalVariables.gymBaseUrl}/gym/getGym';
  static const String getLogo =
      '${GlobalVariables.gymBaseUrl}/gym/get-logo';
  static const String updateGym =
      '${GlobalVariables.gymBaseUrl}/gym/updateGymDetails';
  static const String uploadLogo =
      '${GlobalVariables.gymBaseUrl}/gym/upload-logo';
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

class MembershipApiEndpoints {
  const MembershipApiEndpoints._();

  static const String searchMember =
      'https://devapi.azanto.in/profile/api/v1/member/search-member/{by_phone}';
  static String get searchMemberWithPhone => '$searchMember?phone=';
  static const String membershipPurchase =
      '${GlobalVariables.apiBaseUrl}/profile/${GlobalVariables.apiVersion}/membership/membership-purchase';
}
