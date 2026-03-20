import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionPlan {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;

  SubscriptionPlan({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    this.isPopular = false,
  });
}

class GymPaymentPage extends StatefulWidget {
  const GymPaymentPage({super.key, this.isActive = true});

  final bool isActive;

  @override
  State<GymPaymentPage> createState() => _GymPaymentPageState();
}

class _GymPaymentPageState extends State<GymPaymentPage> {
  int _selectedPlanIndex = 1; // Default to Pro

  final List<SubscriptionPlan> dummyPlans = [
    SubscriptionPlan(
      title: 'Starter Options',
      price: '₹999',
      period: '/ month',
      features: [
        'Up to 100 members',
        'Basic Analytics',
        'Standard Support',
        'QR check-ins',
      ],
    ),
    SubscriptionPlan(
      title: 'Pro App Access',
      price: '₹2,499',
      period: '/ month',
      isPopular: true,
      features: [
        'Unlimited members',
        'Advanced Analytics',
        'Priority Support',
        'Staff management',
        'Invoices & collections',
      ],
    ),
    SubscriptionPlan(
      title: 'Elite Gym',
      price: '₹4,999',
      period: '/ month',
      features: [
        'Everything in Pro',
        'Multi-Gym Support',
        'Dedicated Account Manager',
        'Custom App Branding',
        'Early Access to Future Features',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool active = _resolveIsActive();
    final Color accent =
        active ? AppColors.brandGreen : const Color(0xFFFFC542);
    final String statusLabel = active ? 'Active' : 'Pending';
    final String cta = active ? 'Manage Billing' : 'Complete Payment';

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Subscription Status',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
          color: Colors.white70,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusCard(accent: accent, statusLabel: statusLabel),
            const SizedBox(height: 20),
            Text(
              'Select a Plan',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: dummyPlans.length,
                itemBuilder: (context, index) {
                  return _buildPlanCard(index, dummyPlans[index], accent);
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  shadowColor: accent.withOpacity(0.45),
                ),
                onPressed: _startPaymentFlow,
                child: Text(
                  cta,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Secure UPI / card payments. You will receive a receipt instantly.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 12.5,
                letterSpacing: 0.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(int index, SubscriptionPlan plan, Color accent) {
    final isSelected = _selectedPlanIndex == index;
    final cardBorderColor = isSelected ? accent : Colors.white.withOpacity(0.08);
    final cardBgColor =
        isSelected ? accent.withOpacity(0.08) : const Color(0xFF1E2026);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorderColor, width: isSelected ? 2 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (plan.isPopular)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withOpacity(0.5)),
                    ),
                    child: Text(
                      'Most Popular',
                      style: GoogleFonts.inter(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (isSelected)
                  Icon(Icons.check_circle_rounded, color: accent, size: 24)
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.price,
                  style: GoogleFonts.poppins(
                    color: isSelected ? accent : Colors.white.withOpacity(0.9),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 4),
                  child: Text(
                    plan.period,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...plan.features.map((feature) => _buildFeatureRow(feature, accent)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              color: accent.withOpacity(0.8), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              feature,
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startPaymentFlow() {
    Get.snackbar(
      'Payment',
      'Redirecting to the payment gateway...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.85),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
    // TODO: Integrate actual payment gateway redirect here.
  }

  bool _resolveIsActive() {
    final args = Get.arguments;
    if (args is Map && args['isActive'] != null) {
      return args['isActive'] == true;
    }
    return widget.isActive;
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.accent, required this.statusLabel});

  final Color accent;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181A20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withOpacity(0.8)),
            ),
            child: Icon(
              statusLabel == 'Active'
                  ? Icons.verified_rounded
                  : Icons.pending_actions_rounded,
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gym Subscription',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusLabel == 'Active'
                      ? 'Your application access is live.'
                      : 'Payment pending — complete to unlock all features.',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent),
            ),
            child: Text(
              statusLabel,
              style: GoogleFonts.poppins(
                color: Colors.white,
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
