import 'package:azanto/Services/profile_local_prefs_service.dart';
import 'package:azanto/Services/session_service.dart';
import 'package:azanto/Services/token_refresh_manager.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/routes/app_pages.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:azanto/Services/attendance_service.dart';
import 'package:azanto/Services/member_service.dart';
import 'package:azanto/Services/membership_service.dart';
import 'package:azanto/Services/plan_service.dart';
import 'package:azanto/Services/profile_service.dart';
import 'package:azanto/Services/workout_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize WorkManager for background token refresh
  try {
    await TokenRefreshManager.initialize();
  } catch (e, stack) {
    debugPrint('[AUTH] WorkManager initialization failed: $e\n$stack');
    // Continue without background refresh - foreground refresh will still work
  }

  final session = Get.put(SessionService(), permanent: true);
  Get.put(ProfileLocalPrefsService(), permanent: true);
  Get.lazyPut(() => AttendanceService());
  Get.lazyPut(() => MemberService());
  Get.lazyPut(() => MembershipService());
  Get.lazyPut(() => PlanService());
  Get.lazyPut(() => ProfileService());
  Get.lazyPut(() => WorkoutService());
  _printTokenIfLoggedIn(context: 'app_start', session: session);

  // Schedule background refresh if logged in
  if (session.isLoggedIn) {
    try {
      await TokenRefreshManager.scheduleTokenRefresh();
    } catch (e, stack) {
      debugPrint('[AUTH] Failed to schedule token refresh: $e\n$stack');
    }
  }

  runApp(const AzantoApp());
}

void _printTokenIfLoggedIn({
  required String context,
  required SessionService session,
}) {
  if (!kDebugMode) return;
  if (!session.isLoggedIn) return;
  final token = session.token?.trim() ?? '';
  if (token.isEmpty) return;
  debugPrint('[AUTH][$context] Bearer token: $token');
}

class AzantoApp extends StatefulWidget {
  const AzantoApp({super.key});

  @override
  State<AzantoApp> createState() => _AzantoAppState();
}

class _AzantoAppState extends State<AzantoApp> {
  @override
  void reassemble() {
    super.reassemble();
    if (!Get.isRegistered<SessionService>()) return;
    _printTokenIfLoggedIn(
      context: 'hot_reload',
      session: Get.find<SessionService>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Azanto',
          theme: ThemeData(
            useMaterial3: false,
            scaffoldBackgroundColor: AppColors.scaffoldDark,
            textTheme: GoogleFonts.poppinsTextTheme(),
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.brandGreen,
              brightness: Brightness.dark,
            ),
          ),
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
        );
      },
    );
  }
}
