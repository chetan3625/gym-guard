import 'package:azanto/Memberside/constants/Common_widgets/member_figma_page_shell.dart';
import 'package:azanto/Memberside/constants/member_figma_layout.dart';
import 'package:azanto/Memberside/models/member_selected_plan.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Figma: plan checkout (328:156) — after Pay Now on subscription payment.
class MemberPlanCheckoutPage extends StatefulWidget {
  const MemberPlanCheckoutPage({super.key, required this.selectedPlan});

  final MemberSelectedPlan selectedPlan;

  @override
  State<MemberPlanCheckoutPage> createState() => _MemberPlanCheckoutPageState();
}

enum _CheckoutPaymentMethod { card, applePay, googlePay }

class _MemberPlanCheckoutPageState extends State<MemberPlanCheckoutPage> {
  _CheckoutPaymentMethod _paymentMethod = _CheckoutPaymentMethod.card;
  final _nameController = TextEditingController(text: 'Johnathan Doe');
  final _cardController = TextEditingController(text: '**** **** **** 4242');
  final _expiryController = TextEditingController(text: 'MM/YY');
  final _cvvController = TextEditingController(text: '•••');

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _completePurchase() {
    Get.back<void>();
    Get.back<void>();
    Get.snackbar(
      'Payment successful',
      'Your ${widget.selectedPlan.displayName} is now active.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: MemberFigmaColors.accent.withValues(alpha: 0.92),
      colorText: MemberFigmaColors.accentDarkText,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = MemberFigmaLayout(context);
    final plan = widget.selectedPlan;

    return MemberFigmaPageShell(
      bottomNavIndex: 3,
      gradientEnd: const Color(0xFF272727),
      body: SingleChildScrollView(
        padding: layout.padLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CheckoutHeader(layout: layout),
            SizedBox(height: layout.s(20)),
            _SummaryCard(layout: layout, plan: plan),
            SizedBox(height: layout.s(15)),
            _PaymentMethodSection(
              layout: layout,
              selected: _paymentMethod,
              onSelected: (method) => setState(() => _paymentMethod = method),
            ),
            if (_paymentMethod == _CheckoutPaymentMethod.card) ...[
              SizedBox(height: layout.s(21)),
              _CardDetailsSection(
                layout: layout,
                nameController: _nameController,
                cardController: _cardController,
                expiryController: _expiryController,
                cvvController: _cvvController,
              ),
            ],
            SizedBox(height: layout.s(35)),
            _OrderTotalSection(
                layout: layout, amount: plan.checkoutAmountLabel),
            SizedBox(height: layout.s(17)),
            _CompletePurchaseCta(
              layout: layout,
              onPressed: _completePurchase,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({required this.layout});

  final MemberFigmaLayout layout;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: layout.s(34),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: MemberFigmaBackButton(),
          ),
          Text(
            'Checkout',
            style: layout.montserrat(
              size: 16,
              weight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: EdgeInsets.all(layout.s(4)),
                  child: Icon(
                    LucideIcons.info,
                    color: MemberFigmaColors.label,
                    size: layout.s(20),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.layout, required this.plan});

  final MemberFigmaLayout layout;
  final MemberSelectedPlan plan;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: layout.padLTRB(25, 25, 25, 25),
          decoration: BoxDecoration(
            color: MemberFigmaColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: MemberFigmaColors.cardBorder),
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
                          plan.displayName,
                          style: layout.montserrat(
                            size: 22,
                            weight: FontWeight.w700,
                            color: Colors.white,
                            height: 30 / 22,
                          ),
                        ),
                        SizedBox(height: layout.s(4)),
                        Text(
                          plan.subscriptionTypeLabel,
                          style: layout.montserrat(
                            size: 13,
                            weight: FontWeight.w500,
                            color: MemberFigmaColors.label,
                            height: 20 / 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plan.checkoutAmountLabel,
                        style: layout.montserrat(
                          size: 28,
                          weight: FontWeight.w800,
                          color: MemberFigmaColors.accent,
                          height: 36 / 28,
                        ),
                      ),
                      Text(
                        plan.priceSuffix.trim(),
                        style: layout.montserrat(
                          size: 12,
                          weight: FontWeight.w600,
                          color: MemberFigmaColors.textDim,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: layout.s(24)),
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.08),
                  height: 1,
                ),
              ),
              SizedBox(height: layout.s(8)),
              ...plan.checkoutFeatureLabels.map(
                (feature) => Padding(
                  padding: EdgeInsets.only(top: layout.s(14)),
                  child: _FeatureRow(layout: layout, label: feature),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -layout.s(24),
          right: -layout.s(8),
          child: IgnorePointer(
            child: Container(
              width: layout.s(120),
              height: layout.s(120),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MemberFigmaColors.accent.withValues(alpha: 0.12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.layout, required this.label});

  final MemberFigmaLayout layout;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          size: layout.s(16.67),
          color: MemberFigmaColors.accent,
        ),
        SizedBox(width: layout.s(14)),
        Expanded(
          child: Text(
            label,
            style: layout.montserrat(
              size: 13,
              weight: FontWeight.w500,
              color: MemberFigmaColors.textPrimary,
              height: 20 / 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection({
    required this.layout,
    required this.selected,
    required this.onSelected,
  });

  final MemberFigmaLayout layout;
  final _CheckoutPaymentMethod selected;
  final ValueChanged<_CheckoutPaymentMethod> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: layout.s(4)),
          child: Text(
            'Payment Method',
            style: layout.montserrat(
              size: 12,
              weight: FontWeight.w700,
              color: MemberFigmaColors.label,
              letterSpacing: 0.6,
            ),
          ),
        ),
        SizedBox(height: layout.s(16)),
        _PaymentMethodTile(
          layout: layout,
          label: 'Credit/Debit Card',
          icon: LucideIcons.creditCard,
          selected: selected == _CheckoutPaymentMethod.card,
          onTap: () => onSelected(_CheckoutPaymentMethod.card),
        ),
        SizedBox(height: layout.s(10)),
        _PaymentMethodTile(
          layout: layout,
          label: 'Apple Pay',
          icon: LucideIcons.apple,
          selected: selected == _CheckoutPaymentMethod.applePay,
          onTap: () => onSelected(_CheckoutPaymentMethod.applePay),
        ),
        SizedBox(height: layout.s(10)),
        _PaymentMethodTile(
          layout: layout,
          label: 'Google Pay',
          icon: LucideIcons.wallet,
          selected: selected == _CheckoutPaymentMethod.googlePay,
          onTap: () => onSelected(_CheckoutPaymentMethod.googlePay),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.layout,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final MemberFigmaLayout layout;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MemberFigmaColors.cardBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: layout.s(58),
          padding: layout.padLTRB(17, 0, 17, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? MemberFigmaColors.accent
                  : MemberFigmaColors.cardBorder,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: MemberFigmaColors.accent.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: Offset(0, layout.s(4)),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: layout.s(18)),
              SizedBox(width: layout.s(16)),
              Expanded(
                child: Text(
                  label,
                  style: layout.montserrat(
                    size: 13,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              _RadioDot(layout: layout, selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.layout, required this.selected});

  final MemberFigmaLayout layout;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: layout.s(24),
      height: layout.s(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? MemberFigmaColors.accent : MemberFigmaColors.label,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: layout.s(12),
                height: layout.s(12),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: MemberFigmaColors.accent,
                ),
              ),
            )
          : null,
    );
  }
}

class _CardDetailsSection extends StatelessWidget {
  const _CardDetailsSection({
    required this.layout,
    required this.nameController,
    required this.cardController,
    required this.expiryController,
    required this.cvvController,
  });

  final MemberFigmaLayout layout;
  final TextEditingController nameController;
  final TextEditingController cardController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: layout.padLTRB(25, 25, 25, 25),
      decoration: BoxDecoration(
        color: MemberFigmaColors.formBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MemberFigmaColors.cardIconCircle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CheckoutField(
            layout: layout,
            label: 'Cardholder Name',
            controller: nameController,
          ),
          SizedBox(height: layout.s(20)),
          _CheckoutField(
            layout: layout,
            label: 'Card Number',
            controller: cardController,
            trailing: Icon(
              LucideIcons.creditCard,
              color: MemberFigmaColors.label,
              size: layout.s(16),
            ),
          ),
          SizedBox(height: layout.s(20)),
          Row(
            children: [
              Expanded(
                child: _CheckoutField(
                  layout: layout,
                  label: 'Expiry',
                  controller: expiryController,
                ),
              ),
              SizedBox(width: layout.s(16)),
              Expanded(
                child: _CheckoutField(
                  layout: layout,
                  label: 'CVV',
                  controller: cvvController,
                  obscure: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckoutField extends StatelessWidget {
  const _CheckoutField({
    required this.layout,
    required this.label,
    required this.controller,
    this.trailing,
    this.obscure = false,
  });

  final MemberFigmaLayout layout;
  final String label;
  final TextEditingController controller;
  final Widget? trailing;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: layout.s(4)),
          child: Text(
            label,
            style: layout.montserrat(
              size: 11,
              weight: FontWeight.w600,
              color: MemberFigmaColors.label,
              letterSpacing: 0.3,
            ),
          ),
        ),
        SizedBox(height: layout.s(8)),
        Container(
          height: layout.s(55),
          padding: layout.padLTRB(17, 0, 17, 0),
          decoration: BoxDecoration(
            color: MemberFigmaColors.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MemberFigmaColors.cardIconCircle),
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  style: layout.montserrat(
                    size: 13,
                    weight: FontWeight.w500,
                    color: MemberFigmaColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderTotalSection extends StatelessWidget {
  const _OrderTotalSection({required this.layout, required this.amount});

  final MemberFigmaLayout layout;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TotalRow(layout: layout, label: 'Subtotal', value: amount),
        SizedBox(height: layout.s(16)),
        _TotalRow(layout: layout, label: 'Processing Fee', value: '\$0.00'),
        Padding(
          padding: EdgeInsets.only(top: layout.s(16)),
          child: Divider(color: Colors.white.withValues(alpha: 0.1)),
        ),
        SizedBox(height: layout.s(12)),
        Row(
          children: [
            Text(
              'Total',
              style: layout.montserrat(
                size: 20,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              amount,
              style: layout.montserrat(
                size: 28,
                weight: FontWeight.w800,
                color: MemberFigmaColors.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.layout,
    required this.label,
    required this.value,
  });

  final MemberFigmaLayout layout;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: layout.montserrat(
            size: 13,
            weight: FontWeight.w500,
            color: MemberFigmaColors.label,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: layout.montserrat(
            size: 13,
            weight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _CompletePurchaseCta extends StatelessWidget {
  const _CompletePurchaseCta({
    required this.layout,
    required this.onPressed,
  });

  final MemberFigmaLayout layout;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: layout.s(68),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF43890D), MemberFigmaColors.accent],
              ),
              boxShadow: [
                BoxShadow(
                  color: MemberFigmaColors.accent.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: Offset(0, layout.s(6)),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.lock,
                      color: MemberFigmaColors.accentDarkText,
                      size: layout.s(18),
                    ),
                    SizedBox(width: layout.s(12)),
                    Text(
                      'Complete Purchase',
                      style: layout.montserrat(
                        size: 16,
                        weight: FontWeight.w800,
                        color: MemberFigmaColors.accentDarkText,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: layout.s(24)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              LucideIcons.shieldCheck,
              size: layout.s(12),
              color: MemberFigmaColors.textDim,
            ),
            SizedBox(width: layout.s(8)),
            Expanded(
              child: Text(
                'Secure 256-bit SSL encrypted payment. By completing this purchase, you agree to our Terms and Conditions.',
                style: layout.montserrat(
                  size: 10,
                  weight: FontWeight.w500,
                  color: MemberFigmaColors.textLegal,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
