/// Plan chosen on [MemberPlanUpgradePage] before checkout on the payment screen.
class MemberSelectedPlan {
  const MemberSelectedPlan({
    required this.id,
    required this.name,
    required this.displayName,
    required this.monthlyPrice,
    required this.yearly,
    required this.perks,
    required this.total,
  });

  final String id;
  final String name;
  final String displayName;
  final int monthlyPrice;
  final bool yearly;
  final List<String> perks;
  final double total;

  String get billingCycleLabel => yearly ? 'Yearly' : 'Monthly';

  String get priceLabel {
    if (yearly) {
      return '\$${total.toStringAsFixed(0)}';
    }
    return '\$$monthlyPrice';
  }

  String get priceSuffix => yearly ? '/yr' : '/mo';

  String get subscriptionTypeLabel =>
      yearly ? 'Yearly Subscription' : 'Monthly Subscription';

  String get checkoutAmountLabel => '\$${total.toStringAsFixed(2)}';

  /// Feature bullets on checkout summary (Figma 328:156).
  List<String> get checkoutFeatureLabels {
    switch (id) {
      case 'standard':
        return const [
          'Core Gym Access',
          'Progress Tracking',
          'Member Check-in',
          'Basic Workout Plans',
        ];
      case 'elite':
        return const [
          'AI Coaching',
          'Live Classes',
          'Diet Planning',
          'Priority Support',
        ];
      case 'pro_max':
        return const [
          'Unlimited Guest Passes',
          'Full Spa & Sauna Access',
          'All Group Fitness Classes',
          'Personal Trainer Consultation',
        ];
      default:
        return perks.isNotEmpty ? perks : const ['Membership benefits'];
    }
  }
}
