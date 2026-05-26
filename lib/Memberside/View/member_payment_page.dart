import 'package:azanto/Memberside/View/widgets/member_payment_subscription_body.dart';
import 'package:azanto/views/widgets/azanto_mobile_shell.dart';
import 'package:flutter/material.dart';

/// Payment tab — Figma `Payment page` (447:1272 / 270:49) embedded in dashboard.
class MemberPaymentPage extends StatelessWidget {
  const MemberPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: azantoContentPadding(context),
      child: const MemberPaymentSubscriptionBody(),
    );
  }
}
