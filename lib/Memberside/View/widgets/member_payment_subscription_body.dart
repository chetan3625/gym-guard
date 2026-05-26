import 'package:azanto/Memberside/View/member_plan_checkout_page.dart';
import 'package:azanto/Memberside/View/member_plan_upgrade_page.dart';
import 'package:azanto/Memberside/models/member_selected_plan.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Figma `Payment page` (270:49) content — tab embed or post-plan checkout.
class MemberPaymentSubscriptionBody extends StatelessWidget {
  const MemberPaymentSubscriptionBody({super.key, this.selectedPlan});

  final MemberSelectedPlan? selectedPlan;

  static const List<_PaymentHistoryItem> _payments = [
    _PaymentHistoryItem(
      date: 'Oct 15,\n2024',
      amount: '\$49.00',
      status: 'Successful',
      statusColor: AppColors.brandGreen,
    ),
    _PaymentHistoryItem(
      date: 'Sep 15,\n2024',
      amount: '\$49.00',
      status: 'Successful',
      statusColor: AppColors.brandGreen,
    ),
    _PaymentHistoryItem(
      date: 'Aug 15,\n2024',
      amount: '\$49.00',
      status: 'Successful',
      statusColor: AppColors.brandGreen,
    ),
    _PaymentHistoryItem(
      date: 'Jul 15,\n2024',
      amount: '\$49.00',
      status: 'Failed',
      statusColor: Color(0xFFFF6B5A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment & Subscription',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Manage your billing and membership access',
          style: GoogleFonts.poppins(
            color: Colors.white38,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        const _UpcomingRenewalCard(),
        const SizedBox(height: 10),
        _CurrentPlanCard(selectedPlan: selectedPlan),
        const SizedBox(height: 10),
        const _PaymentMethodCard(),
        const SizedBox(height: 10),
        const _PaymentsHeader(),
        const SizedBox(height: 8),
        const _PaymentsTable(items: _payments),
        const SizedBox(height: 10),
        const _SupportCard(),
      ],
    );
  }
}

class _UpcomingRenewalCard extends StatelessWidget {
  const _UpcomingRenewalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF353535),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.brandGreen.withValues(alpha: 0.70)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.brandGreen.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.sparkles,
              color: AppColors.brandGreen,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Renewal',
                  style: GoogleFonts.poppins(
                    color: AppColors.brandGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'your basic Plan will automatically reniew on Jul 23 ,2026 . No action required',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Dismiss',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({this.selectedPlan});

  final MemberSelectedPlan? selectedPlan;

  String get _planTitle =>
      selectedPlan?.displayName ?? 'Basic Plan';

  String get _billingCycle =>
      selectedPlan?.billingCycleLabel ?? 'Monthly';

  List<String> get _features {
    if (selectedPlan != null && selectedPlan!.perks.isNotEmpty) {
      return selectedPlan!.perks;
    }
    return const ['24/7 Access', 'Personal Trainer', 'Spa & Sauna'];
  }

  @override
  Widget build(BuildContext context) {
    final priceMain = selectedPlan?.priceLabel ?? '\$49';
    final priceSuffix = selectedPlan?.priceSuffix ?? '/mo';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF353535),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Plan',
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _planTitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandGreen.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.brandGreen.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 8,
                            width: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.brandGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Paid',
                            style: GoogleFonts.poppins(
                              color: AppColors.brandGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: priceMain,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                            ),
                          ),
                          TextSpan(
                            text: priceSuffix,
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: _PlanMetaItem(
                      label: 'Expiry Date',
                      value: 'Nov 15, 2026',
                    ),
                  ),
                  Expanded(
                    child: _PlanMetaItem(
                      label: 'Billing Cycle',
                      value: _billingCycle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _features
                  .map((label) => _PlanFeatureChip(label: label))
                  .toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Manage Plan',
                    isPrimary: true,
                    onTap: () =>
                        Get.to<void>(() => const MemberPlanUpgradePage()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: 'Pay Now',
                    isPrimary: selectedPlan != null,
                    onTap: selectedPlan != null
                        ? () => Get.to<void>(
                              () => MemberPlanCheckoutPage(
                                selectedPlan: selectedPlan!,
                              ),
                            )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanMetaItem extends StatelessWidget {
  const _PlanMetaItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white24,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PlanFeatureChip extends StatelessWidget {
  const _PlanFeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.brandGreen,
            size: 12,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    this.isPrimary = false,
    this.onTap,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        isPrimary ? AppColors.brandGreen : const Color(0xFF434343);
    final Color foregroundColor = isPrimary ? Colors.black : Colors.white38;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: foregroundColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF353535),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(17, 17, 17, 17),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF484848)),
            ),
            child: Row(
              children: [
                Container(
                  height: 32,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF484848)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'VISA',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '•••• 8829',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Expires 09/27',
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.pencil,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(
                child: _PaymentMethodMeta(
                  label: 'Last payment',
                  value: 'Oct 15, 2024',
                ),
              ),
              Expanded(
                child: _PaymentMethodMeta(
                  label: 'Total loyalty points',
                  value: '1,240 pts',
                  valueColor: AppColors.brandGreen,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'View Billing Address',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodMeta extends StatelessWidget {
  const _PaymentMethodMeta({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white24,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PaymentsHeader extends StatelessWidget {
  const _PaymentsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Payments',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          'Download All',
          style: GoogleFonts.poppins(
            color: AppColors.brandGreen,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PaymentsTable extends StatelessWidget {
  const _PaymentsTable({required this.items});

  final List<_PaymentHistoryItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF353535),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF484848)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                _HeaderCell(text: 'Date', flex: 26),
                _HeaderCell(text: 'Amount', flex: 23),
                _HeaderCell(text: 'Status', flex: 31),
                _HeaderCell(text: 'Invoice', flex: 20, alignEnd: true),
              ],
            ),
          ),
          ...items.map((item) => _PaymentRow(item: item)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Text(
              'Showing last 4 transactions . View Full History',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.text,
    required this.flex,
    this.alignEnd = false,
  });

  final String text;
  final int flex;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        style: GoogleFonts.poppins(
          color: Colors.white24,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.item});

  final _PaymentHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 26,
            child: Text(
              item.date,
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
          Expanded(
            flex: 23,
            child: Text(
              item.amount,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 31,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: item.statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: item.statusColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  item.status,
                  style: GoogleFonts.poppins(
                    color: item.statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const Expanded(
            flex: 20,
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(
                LucideIcons.download,
                color: Colors.white38,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF353535),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Container(
            height: 57,
            width: 53,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.18),
            ),
            child: const Icon(
              LucideIcons.headphones,
              color: Colors.white70,
              size: 25,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Need help with payments?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our support team is available 24/7 to resolve any billing issues or inquiries.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 211,
            height: 38,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  'Contact Support',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentHistoryItem {
  const _PaymentHistoryItem({
    required this.date,
    required this.amount,
    required this.status,
    required this.statusColor,
  });

  final String date;
  final String amount;
  final String status;
  final Color statusColor;
}
