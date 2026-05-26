import 'package:azanto/controllers/home_controller.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/routes/app_routes.dart';
import 'package:azanto/views/widgets/azanto_mobile_shell.dart';
import 'package:azanto/views/widgets/common_app_bar.dart';
import 'package:azanto/views/pages/dashboard_page.dart';
import 'package:azanto/views/pages/invoices_page.dart';
import 'package:azanto/views/pages/members_page.dart';
import 'package:azanto/views/pages/plans_page.dart';
import 'package:azanto/views/pages/profile_page.dart';
import 'package:azanto/views/pages/reports_page.dart';
import 'package:azanto/views/pages/add_member_form_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeShell extends GetView<HomeController> {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionActive =
        (controller.session.gymId?.isNotEmpty ?? false) ? true : false;

    return Scaffold(
      backgroundColor: AppColors.mobileScaffold,
      appBar: AzantoAppBar(
        subscriptionActive: subscriptionActive,
        onStatusTap: () => Get.toNamed(
          AppRoutes.gymPayment,
          arguments: {'isActive': subscriptionActive},
        ),
        extraActions: [
          IconButton(
            tooltip: 'Scan QR',
            onPressed: () => Get.toNamed(AppRoutes.qrScanner),
            icon: Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 22,
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: controller.onLogout,
            icon: Icon(
              Icons.logout_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 22,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AzantoPageBackground(
          child: Obx(() {
            final currentIndex = controller.currentIndex.value;

            if (controller.shouldLaunchGymPrompt) {
              controller.markGymPromptLaunched();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.offAllNamed(AppRoutes.gymOnboarding);
              });
            }

            void openAddMemberScreen() {
              Get.to(
                () => AddMemberFormPage(onBack: () => Get.back()),
                transition: Transition.downToUp,
              );
            }

            return IndexedStack(
              index: currentIndex,
              children: [
                controller.isProfileOpen.value
                    ? ProfilePage(onBack: controller.closeProfile)
                    : DashboardPage(
                        greeting: controller.greetingMessage,
                        userName: controller.displayName.value,
                        userRole: controller.roleTitle.value,
                        avatarLetter: controller.avatarLetter,
                        onProfileTap: controller.openProfile,
                        onAddMemberTap: openAddMemberScreen,
                        onAddGymTap: controller.isOwner
                            ? () => Get.toNamed(AppRoutes.gymOnboarding)
                            : null,
                        onGymTap: controller.openGymDetails,
                        showAddGym: controller.shouldShowAddGymCard,
                        gymSummary: controller.gymSummary.value,
                      ),
                MembersPage(onAddMemberTap: openAddMemberScreen),
                const InvoicesPage(),
                const PlansPage(),
                const ReportsPage(),
              ],
            );
          }),
        ),
      ),
      bottomNavigationBar: Obx(
        () => AzantoBottomNavBar(
          items: AzantoBottomNavBar.ownerItems,
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}
