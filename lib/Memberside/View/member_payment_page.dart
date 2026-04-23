import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MemberPaymentPage extends StatelessWidget {
  const MemberPaymentPage({super.key});

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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3C3C3C),
            Color(0xFF343434),
            Color(0xFF2D2D2D),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, 14, 8, 24),
        child: Column(
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
            const _CurrentPlanCard(),
            const SizedBox(height: 10),
            const _PaymentMethodCard(),
            const SizedBox(height: 10),
            const _PaymentsHeader(),
            const SizedBox(height: 8),
            const _PaymentsTable(items: _payments),
            const SizedBox(height: 10),
            const _SupportCard(),
          ],
        ),
      ),
    );
  }
}

class _UpcomingRenewalCard extends StatelessWidget {
  const _UpcomingRenewalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF353535),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.brandGreen.withValues(alpha: 0.70)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: AppColors.brandGreen.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.sparkles,
              color: AppColors.brandGreen,
              size: 15,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Renewal',
                  style: GoogleFonts.poppins(
                    color: AppColors.brandGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'your basic Plan will automatically renew on Jul 23 2026.',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No action required',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '35 DAYS',
            style: GoogleFonts.poppins(
              color: AppColors.brandGreen,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF353535),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
            children: [
              Text(
                'CURRENT PLAN',
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandGreen.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 6,
                      width: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.brandGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
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
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Basic Plan',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '\$49',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                    TextSpan(
                      text: '/mo',
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _PlanMetaItem(
                  label: 'Expiry Date',
                  value: 'Nov 15, 2026',
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _PlanMetaItem(
                  label: 'Billing Cycle',
                  value: 'Monthly',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PlanFeatureChip(label: '24/7 Access'),
              _PlanFeatureChip(label: 'Personal Trainer'),
              _PlanFeatureChip(label: 'Spa & Sauna'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Manage Plan',
                  isPrimary: true,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: 'Pay Now',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanMetaItem extends StatelessWidget {
  const _PlanMetaItem({
    required this.label,
    required this.value,
  });

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
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 19,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            size: 13,
          ),
          const SizedBox(width: 6),
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
  });

  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        isPrimary ? AppColors.brandGreen : const Color(0xFF434343);
    final Color foregroundColor = isPrimary ? Colors.black : Colors.white38;

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: foregroundColor,
          fontSize: 17,
          fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
           Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 18,
                        width: 26,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'VISA',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•••• 8829',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Expires 09/27',
                            style: GoogleFonts.poppins(
                              color: Colors.white38,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.pencil,
                  color: Colors.white70,
                  size: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
        const SizedBox(height: 2),
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
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          'Download All',
          style: GoogleFonts.poppins(
            color: AppColors.brandGreen,
            fontSize: 16,
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
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Row(
              children: [
                _HeaderCell(text: 'DATE', flex: 26),
                _HeaderCell(text: 'AMOUNT', flex: 23),
                _HeaderCell(text: 'STATUS', flex: 31),
                _HeaderCell(text: 'INVOICE', flex: 20, alignEnd: true),
              ],
            ),
          ),
          ...items.map((item) => _PaymentRow(item: item)),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Showing last 4 transactions.',
                    style: GoogleFonts.poppins(
                      color: Colors.white24,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  'View Full History',
                  style: GoogleFonts.poppins(
                    color: AppColors.brandGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: item.statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.status,
                  style: GoogleFonts.poppins(
                    color: item.statusColor,
                    fontSize: 12,
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
                size: 14,
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
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF353535),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.18),
            ),
            child: const Icon(
              LucideIcons.headphones,
              color: Colors.white70,
              size: 15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Need help with payments?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Our support team is available 24/7 to resolve\nany billing issues or inquiries.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              'Contact Support',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w700,
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
