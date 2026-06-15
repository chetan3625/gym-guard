class GlobalVariables {
  const GlobalVariables._();

  static const String authHost = 'https://devapi.azanto.in/auth';
  static const String apiHost = 'https://devapi.azanto.in';
  static const String gymHost = 'https://devapi.azanto.in/gym-branch';
  static const String profileHost = 'https://devapi.azanto.in/profile';

  static const String apiVersion = '/api/v1';
  static const String authBaseUrl = '$authHost$apiVersion';
  static const String apiBaseUrl = '$apiHost$apiVersion';
  static const String gymBaseUrl = '$gymHost$apiVersion';
  static const String profileBaseUrl = '$profileHost$apiVersion';
  static const String memberProfileBaseUrl = '$profileBaseUrl/member';
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
  static const String addMember =
      '${GlobalVariables.gymBaseUrl}/gym/branch/addmember';
  static const String getAllBranches =
      '${GlobalVariables.gymBaseUrl}/gym/get-all-branches';
  static const String getBranchDetails =
      '${GlobalVariables.gymBaseUrl}/gym/branch/getbranchdetails';
  static const String getAllBranchMembers =
      '${GlobalVariables.gymBaseUrl}/gym/branch/getallbranchmembers';

  /// Returns the gyms owned
  static const String getGym = '${GlobalVariables.gymBaseUrl}/gym/getGym';
  static const String getLogo = '${GlobalVariables.gymBaseUrl}/gym/get-logo';
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
      '${GlobalVariables.memberProfileBaseUrl}/get-avatar';
}

class AttendanceApiEndpoints {
  const AttendanceApiEndpoints._();

  static const String checkIn =
      '${GlobalVariables.profileBaseUrl}/attendance/checkin';
  static const String checkOut =
      '${GlobalVariables.profileBaseUrl}/attendance/checkout';
  static const String myAttendance =
      '${GlobalVariables.profileBaseUrl}/attendance/my-attendance';
}

class MembershipApiEndpoints {
  const MembershipApiEndpoints._();

  static const String searchMember =
      'https://devapi.azanto.in/profile/api/v1/member/search-member/{by_phone}';
  static String get searchMemberWithPhone => '$searchMember?phone=';
  static const String membershipPurchase = GymApiEndpoints.addMember;
  static const String enrolledPlan =
      '${GlobalVariables.profileBaseUrl}/membership/enrolled-plan';
}

class WorkoutApiEndpoints {
  const WorkoutApiEndpoints._();

  static const String _base = '${GlobalVariables.profileBaseUrl}/workout';

  static const String createCategory = '$_base/create-categories';
  static const String getCategories = '$_base/get-categories';
  static const String createBodyPart = '$_base/create-body-part';
  static const String createExercise = '$_base/create-exercise';
  static const String trackExercise = '$_base/track-exercise';

  static String bodyPartsForCategory(String categoryId) =>
      '$_base/categories/$categoryId/body-parts';

  static String exercisesForBodyPart(String bodyPartId) =>
      '$_base/body-parts/$bodyPartId/exercises';

  static String completeExercise(String trackingId) =>
      '$_base/complete-exercise/$trackingId';

  static String logHistory(String logId) => '$_base/logs/$logId/history';
}
