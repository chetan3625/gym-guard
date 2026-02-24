import 'package:azanto/Services/session_service.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/routes/app_pages.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(SessionService(), permanent: true);
  runApp(const AzantoApp());
}

class AzantoApp extends StatelessWidget {
  const AzantoApp({super.key});

  @override
  Widget build(BuildContext context) {
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
  }
}
