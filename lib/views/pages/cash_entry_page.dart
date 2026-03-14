import 'dart:math' as math;
import 'dart:ui';

import 'package:azanto/views/models/plan_option.dart';
import 'package:azanto/views/widgets/corner_back_button.dart';
import 'package:azanto/views/widgets/plan_card.dart';
import 'package:azanto/views/pages/payment_success_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CashEntryPage extends StatefulWidget {
  const CashEntryPage({
    super.key,
    required this.planOption,
    required this.name,
    required this.phone,
  });

  final PlanOption planOption;
  final String name;
  final String phone;

  @override
  State<CashEntryPage> createState() => _CashEntryPageState();
}

class _CashEntryPageState extends State<CashEntryPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _upiIdController = TextEditingController();
  final _upiTxnController = TextEditingController();
  String _paymentType = 'cash';

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _upiIdController.dispose();
    _upiTxnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final widthScale = size.width / 393.0;
    final heightScale = size.height / 852.0;
    final scale = math
        .min(math.min(widthScale, heightScale), 1.0)
        .clamp(0.9, 1.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/cash_entry.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC0C0C0D),
                    Color(0xE6101012),
                    Color(0xF0111113),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(15, 96 * scale, 15, 80 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PlanCard(
                    option: widget.planOption,
                    scale: scale,
                    isSelected: true,
                    showAccentBar: false,
                    showButton: false,
                    forcedWidth: 364 * scale,
                    forcedHeight: 214 * scale,
                    customContentPadding: EdgeInsets.fromLTRB(
                      18 * scale,
                      22 * scale,
                      18 * scale,
                      18 * scale,
                    ),
                    titleFontSize: 31 * scale,
                    titleFontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 24 * scale),
                  _buildPaymentTypeToggle(scale),
                  SizedBox(height: 18 * scale),
                  if (_paymentType == 'cash')
                    _buildCashCard(scale)
                  else
                    _buildUpiCard(scale),
                  SizedBox(height: 30 * scale),
                  SizedBox(
                    width: 311 * scale,
                    child: _buildConfirmButton(scale),
                  ),
                  SizedBox(height: 40 * scale),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 64,
            child: SizedBox(
              width: 36,
              height: 34,
              child: CornerBackButton(size: 36, onTap: () => Get.back()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTypeToggle(double scale) {
    return Center(
      child: SizedBox(
        width: 364 * scale,
        child: Row(
          children: [
            Expanded(
              child: _PaymentChip(
                label: 'Cash',
                selected: _paymentType == 'cash',
                onTap: () => setState(() => _paymentType = 'cash'),
                scale: scale,
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: _PaymentChip(
                label: 'UPI',
                selected: _paymentType == 'upi',
                onTap: () => setState(() => _paymentType = 'upi'),
                scale: scale,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashCard(double scale) {
    return Center(
      child: SizedBox(
        width: 364 * scale,
        height: 430 * scale,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26 * scale),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16 * scale, sigmaY: 16 * scale),
            child: Container(
              padding: EdgeInsets.all(24 * scale),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(26 * scale),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 18 * scale,
                    offset: Offset(0, 12 * scale),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cash Received (₹)',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  _buildInputField(
                    controller: _amountController,
                    hint: '₹ 0000',
                    scale: scale,
                  ),
                  SizedBox(height: 22 * scale),
                  Text(
                    'Note',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  _buildInputField(
                    controller: _noteController,
                    hint: 'Add payment note',
                    scale: scale,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpiCard(double scale) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 364 * scale),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26 * scale),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16 * scale, sigmaY: 16 * scale),
            child: Container(
              padding: EdgeInsets.all(24 * scale),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(26 * scale),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 18 * scale,
                    offset: Offset(0, 12 * scale),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UPI Details',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 14 * scale),
                  _buildInputField(
                    controller: _upiIdController,
                    hint: 'name@bank',
                    scale: scale,
                  ),
                  SizedBox(height: 18 * scale),
                  Text(
                    'Transaction ID',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  _buildInputField(
                    controller: _upiTxnController,
                    hint: 'Enter UPI reference',
                    scale: scale,
                  ),
                  SizedBox(height: 18 * scale),
                  Text(
                    'Note',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  _buildInputField(
                    controller: _noteController,
                    hint: 'Add payment note',
                    scale: scale,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required double scale,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.montserrat(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(color: Colors.white70),
        filled: true,
        fillColor: Colors.black.withOpacity(0.55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18 * scale),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 12 * scale,
        ),
      ),
    );
  }

  Widget _buildConfirmButton(double scale) {
    return Container(
      height: 59 * scale,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6CE800), Color(0xFF4AAE05)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 18 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24 * scale),
          onTap: _onConfirm,
          child: Center(
            child: Text(
              'Confirm Payment',
              style: GoogleFonts.montserrat(
                fontSize: 20 * scale,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onConfirm() {
    String amountText;
    if (_paymentType == 'cash') {
      final amount = _amountController.text.trim();
      if (amount.isEmpty) {
        Get.snackbar(
          'Payment',
          'Please enter the cash received amount',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      amountText = '₹$amount';
    } else {
      final upiId = _upiIdController.text.trim();
      final upiTxn = _upiTxnController.text.trim();
      if (upiId.isEmpty || upiTxn.isEmpty) {
        Get.snackbar(
          'Payment',
          'Please enter UPI ID and Transaction ID',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      amountText = widget.planOption.price;
    }

    Get.to(
      () => PaymentSuccessPage(
        name: widget.name,
        phone: widget.phone,
        amount: amountText,
        planTitle: widget.planOption.title,
      ),
      transition: Transition.downToUp,
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.scale,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected
            ? Colors.white.withOpacity(0.16)
            : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(
          color: selected
              ? Colors.white.withOpacity(0.35)
              : Colors.white.withOpacity(0.14),
          width: selected ? 1.4 : 1.0,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 14 * scale,
                  offset: Offset(0, 8 * scale),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18 * scale),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10 * scale),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
