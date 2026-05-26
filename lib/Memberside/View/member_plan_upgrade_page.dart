import 'package:azanto/Memberside/View/member_subscription_payment_page.dart';
import 'package:azanto/Memberside/constants/Common_widgets/member_figma_page_shell.dart';
import 'package:azanto/Memberside/constants/member_figma_layout.dart';
import 'package:azanto/Memberside/models/member_selected_plan.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Figma: `plan upgrade page` (447:1450 / 462) — compact stacked plan picker.
class MemberPlanUpgradePage extends StatefulWidget {
  const MemberPlanUpgradePage({super.key});

  @override
  State<MemberPlanUpgradePage> createState() => _MemberPlanUpgradePageState();
}

class _MemberPlanUpgradePageState extends State<MemberPlanUpgradePage> {
  bool _yearly = false;
  String _selectedPlan = 'pro_max';

  static const _plans = <_PlanOption>[
    _PlanOption(
      id: 'standard',
      name: 'STANDARD',
      price: 9,
      perks: ['CORE', 'TRACKING'],
    ),
    _PlanOption(
      id: 'elite',
      name: 'ELITE',
      price: 19,
      perks: ['AI COACH', 'LIVE', 'DIET'],
      isCurrent: true,
    ),
    _PlanOption(
      id: 'pro_max',
      name: 'PRO MAX',
      price: 39,
      perks: ['TRAINER', 'CLINIC', 'LOUNGE'],
    ),
  ];

  _PlanOption get _activePlan =>
      _plans.firstWhere((p) => p.id == _selectedPlan);

  double get _total {
    final plan = _activePlan;
    return _yearly ? plan.price * 10.0 : plan.price.toDouble();
  }

  void _confirmUpgrade() {
    final plan = _activePlan;
    if (plan.isCurrent) {
      Get.snackbar(
        'Current plan',
        'You are already on ${plan.name}.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    Get.to<void>(
      () => MemberSubscriptionPaymentPage(
        selectedPlan: MemberSelectedPlan(
          id: plan.id,
          name: plan.name,
          displayName: _planDisplayName(plan.name),
          monthlyPrice: plan.price,
          yearly: _yearly,
          perks: plan.perks,
          total: _total,
        ),
      ),
    );
  }

  static String _planDisplayName(String name) {
    switch (name) {
      case 'STANDARD':
        return 'Standard Plan';
      case 'ELITE':
        return 'Elite Plan';
      case 'PRO MAX':
        return 'Pro Max Plan';
      default:
        return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final layout = MemberFigmaLayout(context);

    return MemberFigmaPageShell(
      bottomNavIndex: 3,
      gradientEnd: const Color(0xFF272727),
      body: SingleChildScrollView(
        padding: layout.padLTRB(18, 8, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MemberFigmaBackButton(),
            SizedBox(height: layout.s(8)),
            Text(
              'Elevate Your\nPerformance',
              textAlign: TextAlign.center,
              style: layout.montserrat(
                size: 24,
                weight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.75,
                height: 36 / 24,
              ),
            ),
            SizedBox(height: layout.s(14)),
            Center(child: _BillingToggle(
              layout: layout,
              yearly: _yearly,
              onChanged: (yearly) => setState(() => _yearly = yearly),
            )),
            SizedBox(height: layout.s(14)),
            ..._plans.map(
              (plan) => Padding(
                padding: EdgeInsets.only(bottom: layout.s(12)),
                child: _PlanCard(
                  layout: layout,
                  plan: plan,
                  yearly: _yearly,
                  selected: _selectedPlan == plan.id,
                  onSelect: plan.isCurrent
                      ? null
                      : () => setState(() => _selectedPlan = plan.id),
                ),
              ),
            ),
            SizedBox(height: layout.s(4)),
            _CheckoutSummary(
              layout: layout,
              total: _total,
              onConfirm: _confirmUpgrade,
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma 462:464 — centered pill (~221px) inside bordered track.
class _BillingToggle extends StatelessWidget {
  const _BillingToggle({
    required this.layout,
    required this.yearly,
    required this.onChanged,
  });

  final MemberFigmaLayout layout;
  final bool yearly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: layout.s(221),
      height: layout.s(39),
      padding: layout.padLTRB(5, 5, 5, 5),
      decoration: BoxDecoration(
        color: MemberFigmaColors.cardBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF404040)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleChip(
              layout: layout,
              label: 'MONTHLY',
              active: !yearly,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ToggleChip(
              layout: layout,
              label: 'YEARLY',
              active: yearly,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.layout,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final MemberFigmaLayout layout;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? MemberFigmaColors.accent : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: layout.s(29),
          child: Center(
            child: Text(
              label,
              style: layout.montserrat(
                size: 11,
                weight: FontWeight.w800,
                color: active
                    ? MemberFigmaColors.accentDarkText
                    : MemberFigmaColors.label,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma 462:471 — 358×101 compact plan row.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.layout,
    required this.plan,
    required this.yearly,
    required this.selected,
    this.onSelect,
  });

  final MemberFigmaLayout layout;
  final _PlanOption plan;
  final bool yearly;
  final bool selected;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final isCurrent = plan.isCurrent;
    final highlighted = isCurrent || selected;
    final displayPrice =
        yearly ? (plan.price * 10).toString() : plan.price.toString();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: layout.s(101),
          padding: layout.padLTRB(17, 17, 17, 17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isCurrent
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF191A1A), Color(0xFF132D00)],
                  )
                : null,
            color: isCurrent
                ? null
                : highlighted
                    ? MemberFigmaColors.cardBg
                    : MemberFigmaColors.cardBg,
            border: Border.all(
              color: highlighted
                  ? MemberFigmaColors.accent
                  : MemberFigmaColors.cardBorder,
              width: highlighted ? 1.2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      plan.name,
                      style: layout.montserrat(
                        size: 10,
                        weight: FontWeight.w700,
                        color: highlighted
                            ? MemberFigmaColors.accent
                            : MemberFigmaColors.label,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: layout.s(2)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '\$$displayPrice',
                          style: layout.montserrat(
                            size: 20,
                            weight: FontWeight.w800,
                            color: Colors.white,
                            height: 28 / 20,
                          ),
                        ),
                        SizedBox(width: layout.s(4)),
                        Text(
                          yearly ? '/ YEAR' : '/ MONTH',
                          style: layout.montserrat(
                            size: 10,
                            weight: FontWeight.w700,
                            color: MemberFigmaColors.label,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: layout.s(6)),
                    Row(
                      children: [
                        for (var i = 0; i < plan.perks.length; i++) ...[
                          if (i > 0) SizedBox(width: layout.s(12)),
                          _PerkChip(
                            layout: layout,
                            label: plan.perks[i],
                            highlighted: highlighted,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: layout.s(8)),
              if (isCurrent)
                _PlanActionButton(
                  layout: layout,
                  label: 'CURRENT',
                  filled: false,
                )
              else
                _PlanActionButton(
                  layout: layout,
                  label: 'SELECT',
                  filled: selected,
                  onTap: onSelect,
                ),
            ],
          ),
        ),
        if (isCurrent)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: layout.padLTRB(12, 4, 12, 4),
              decoration: const BoxDecoration(
                color: MemberFigmaColors.accent,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Text(
                'ACTIVE',
                style: layout.montserrat(
                  size: 9,
                  weight: FontWeight.w800,
                  color: MemberFigmaColors.accentDarkText,
                  letterSpacing: 0.9,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PerkChip extends StatelessWidget {
  const _PerkChip({
    required this.layout,
    required this.label,
    required this.highlighted,
  });

  final MemberFigmaLayout layout;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle,
          size: layout.s(11.667),
          color:
              highlighted ? MemberFigmaColors.accent : MemberFigmaColors.label,
        ),
        SizedBox(width: layout.s(4)),
        Text(
          label,
          style: layout.montserrat(
            size: 9,
            weight: FontWeight.w700,
            color: highlighted ? Colors.white : MemberFigmaColors.label,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _PlanActionButton extends StatelessWidget {
  const _PlanActionButton({
    required this.layout,
    required this.label,
    this.filled = false,
    this.onTap,
  });

  final MemberFigmaLayout layout;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled
          ? MemberFigmaColors.accent.withValues(alpha: 0.15)
          : MemberFigmaColors.cardBorder,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: layout.s(96),
          height: layout.s(33),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: filled
                ? Border.all(
                    color: MemberFigmaColors.accent.withValues(alpha: 0.5),
                  )
                : null,
          ),
          child: Text(
            label,
            style: layout.montserrat(
              size: 10,
              weight: FontWeight.w800,
              color: filled ? MemberFigmaColors.accent : MemberFigmaColors.label,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  const _CheckoutSummary({
    required this.layout,
    required this.total,
    required this.onConfirm,
  });

  final MemberFigmaLayout layout;
  final double total;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: layout.padLTRB(17, 17, 17, 17),
      decoration: BoxDecoration(
        color: MemberFigmaColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MemberFigmaColors.accent.withValues(alpha: 0.26),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: layout.s(15),
            offset: Offset(0, layout.s(10)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTIMATED TOTAL',
                      style: layout.montserrat(
                        size: 9,
                        weight: FontWeight.w700,
                        color: MemberFigmaColors.label,
                        letterSpacing: 0.9,
                      ),
                    ),
                    SizedBox(height: layout.s(4)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: layout.montserrat(
                            size: 24,
                            weight: FontWeight.w800,
                            color: MemberFigmaColors.accent,
                            letterSpacing: -0.6,
                            height: 32 / 24,
                          ),
                        ),
                        SizedBox(width: layout.s(6)),
                        Text(
                          '/ BILLED TODAY',
                          style: layout.montserrat(
                            size: 9,
                            weight: FontWeight.w500,
                            color: MemberFigmaColors.textDim,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: layout.padLTRB(9, 3, 9, 3),
                decoration: BoxDecoration(
                  color: const Color(0x99262626),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0x80404040)),
                ),
                child: Text(
                  'NO TAX',
                  style: layout.montserrat(
                    size: 8,
                    weight: FontWeight.w700,
                    color: MemberFigmaColors.textDim,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: layout.s(12)),
          SizedBox(
            height: layout.s(60),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF43890D), MemberFigmaColors.accent],
                  stops: [0.0, 0.99038],
                ),
                boxShadow: [
                  BoxShadow(
                    color: MemberFigmaColors.accent.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: Offset(0, layout.s(4)),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onConfirm,
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: Text(
                      'CONFIRM UPGRADE',
                      style: layout.montserrat(
                        size: 16,
                        weight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: layout.s(10)),
          Text(
            'AGREEMENT TO AZANTO TERMS OF SERVICE REQUIRED.',
            textAlign: TextAlign.center,
            style: layout.montserrat(
              size: 8,
              color: MemberFigmaColors.textLegal,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanOption {
  const _PlanOption({
    required this.id,
    required this.name,
    required this.price,
    required this.perks,
    this.isCurrent = false,
  });

  final String id;
  final String name;
  final int price;
  final List<String> perks;
  final bool isCurrent;
}
