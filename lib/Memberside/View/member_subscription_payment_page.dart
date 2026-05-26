import 'package:azanto/Memberside/constants/Common_widgets/member_figma_page_shell.dart';
import 'package:azanto/Memberside/constants/member_figma_layout.dart';
import 'package:azanto/Memberside/models/member_selected_plan.dart';
import 'package:azanto/Memberside/View/widgets/member_payment_subscription_body.dart';
import 'package:flutter/material.dart';

/// Figma: `Payment page` (270:49) — shown after a plan is selected on upgrade.
class MemberSubscriptionPaymentPage extends StatelessWidget {
  const MemberSubscriptionPaymentPage({
    super.key,
    required this.selectedPlan,
  });

  final MemberSelectedPlan selectedPlan;

  @override
  Widget build(BuildContext context) {
    final layout = MemberFigmaLayout(context);

    return MemberFigmaPageShell(
      bottomNavIndex: 3,
      body: SingleChildScrollView(
        padding: layout.padLTRB(16, 8, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MemberFigmaBackButton(),
            SizedBox(height: layout.s(12)),
            MemberPaymentSubscriptionBody(selectedPlan: selectedPlan),
          ],
        ),
      ),
    );
  }
}
