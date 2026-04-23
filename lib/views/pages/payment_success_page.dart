import 'dart:math' as math;
import 'dart:ui';
import 'dart:convert';

import 'package:azanto/Services/login_services.dart';
import 'package:azanto/views/widgets/corner_back_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:azanto/Services/session_service.dart';
import 'package:pdf/pdf.dart';

class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({
    super.key,
    required this.name,
    required this.phone,
    required this.amount,
    required this.planTitle,
    required this.gymId,
    required this.planId,
    required this.userId,
    required this.paymentMode,
    required this.activationAmount,
  });

  final String name;
  final String phone;
  final String amount;
  final String planTitle;
  final String gymId;
  final String planId;
  final String userId;
  final String paymentMode;
  final double activationAmount;

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  final ApiServices _apiServices = ApiServices();
  bool _isActivating = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final widthScale = size.width / 393.0;
    final heightScale = size.height / 852.0;
    final scale = math.min(widthScale, heightScale).clamp(0.9, 1.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/payment_successfull_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.45),
                    Colors.black.withOpacity(0.75),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16 * scale,
                82 * scale,
                16 * scale,
                24 * scale,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: ResponsiveCornerBackButton(
                      onTap: () => Get.back(),
                      baseWidth: 393,
                      baseHeight: 852,
                      x: 0,
                      y: 0,
                      baseSize: 36,
                    ),
                  ),
                  const Spacer(),
                  _SuccessCard(
                    scale: scale,
                    name: widget.name,
                    phone: widget.phone,
                    amount: widget.amount,
                    planTitle: widget.planTitle,
                  ),
                  SizedBox(height: 28 * scale),
                  _SlideToActivate(
                    scale: scale,
                    isLoading: _isActivating,
                    onCompleted: _activateMembership,
                  ),
                  SizedBox(height: 14 * scale),
                  _SecondaryButton(
                    label: 'Share Receipt',
                    scale: scale,
                    onTap: () => _shareReceipt(
                      context: context,
                      memberName: widget.name,
                      phone: widget.phone,
                      amount: widget.amount,
                      planTitle: widget.planTitle,
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _activateMembership() async {
    if (_isActivating) return;

    setState(() => _isActivating = true);

    try {
      final response = await _apiServices.purchaseMembership(
        gymId: widget.gymId,
        planId: widget.planId,
        userId: widget.userId,
        amount: widget.activationAmount,
        paymentMode: widget.paymentMode,
      );

      debugPrint('=== MEMBERSHIP ACTIVATED RESPONSE ===');
      debugPrint(const JsonEncoder.withIndent('  ').convert(response));
      debugPrint('=====================================');

      if (!mounted) return;

      Get.snackbar(
        'Membership activated',
        response['message']?.toString() ?? 'Membership activated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed('/dashboard');
    } on ApiException catch (e) {
      debugPrint('Membership activation failed: ${e.detailMessage}');
      if (!mounted) return;
      Get.snackbar(
        'Activation failed',
        e.detailMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Membership activation unexpected error: $e');
      if (!mounted) return;
      Get.snackbar(
        'Activation failed',
        'Something went wrong while activating membership',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => _isActivating = false);
      }
    }
  }
}

Future<void> _shareReceipt({
  required BuildContext context,
  required String memberName,
  required String phone,
  required String amount,
  required String planTitle,
}) async {
  final owner = _decodeOwnerFromToken();
  final logoPng = await rootBundle.load('assets/icons/password_reset_icon.png');

  final doc = pw.Document();
  final now = DateTime.now();
  doc.addPage(
    pw.Page(
      pageTheme: pw.PageTheme(
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
      ),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Payment Receipt',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Date: ${now.toLocal()}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                pw.Container(
                  width: 46,
                  height: 46,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFB8F9C4),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Image(
                      pw.MemoryImage(logoPng.buffer.asUint8List()),
                      width: 28,
                      height: 28,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 18),
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0x0DFFFFFF),
                border: pw.Border.all(color: PdfColor.fromInt(0xFF66D122)),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Member Details',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  _detailRow('Name', memberName),
                  _detailRow('Phone', phone),
                  _detailRow('Plan', planTitle),
                  _detailRow('Amount', amount),
                ],
              ),
            ),
            pw.SizedBox(height: 14),
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0x0DFFFFFF),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Issued By',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  _detailRow('Owner', owner['name'] ?? 'Gym Owner'),
                  if (owner['email'] != null)
                    _detailRow('Email', owner['email']!),
                  if (owner['phone'] != null)
                    _detailRow('Phone', owner['phone']!),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  final bytes = await doc.save();
  final filename =
      'receipt_${now.toIso8601String().replaceAll(":", "-").replaceAll(".", "_")}.pdf';
  try {
    await Printing.sharePdf(bytes: bytes, filename: filename);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  } catch (_) {
    Get.snackbar(
      'Share failed',
      'Unable to open share/print sheet on this device.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

pw.Widget _detailRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          '$label:',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

Map<String, String?> _decodeOwnerFromToken() {
  try {
    final session = SessionService();
    final token = session.normalizedToken;
    if (token == null || token.isEmpty) return {};
    final parts = token.split('.');
    if (parts.length < 2) return {};
    final normalized = base64.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    final data = jsonDecode(payload) as Map<String, dynamic>;
    return {
      'name': data['name']?.toString(),
      'email': data['email']?.toString(),
      'phone': data['phone']?.toString(),
    };
  } catch (_) {
    return {};
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({
    required this.scale,
    required this.name,
    required this.phone,
    required this.amount,
    required this.planTitle,
  });

  final double scale;
  final String name;
  final String phone;
  final String amount;
  final String planTitle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28 * scale),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12 * scale, sigmaY: 12 * scale),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            26 * scale,
            32 * scale,
            26 * scale,
            30 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(28 * scale),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 22 * scale,
                offset: Offset(0, 12 * scale),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 78 * scale,
                height: 78 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFB8F9C4),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/password_reset_icon.svg',
                    width: 38 * scale,
                    height: 38 * scale,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF0E6E29),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 22 * scale),
              Text(
                'Payment\nSuccessful!',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 28 * scale,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 26 * scale),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  18 * scale,
                  18 * scale,
                  18 * scale,
                  16 * scale,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16 * scale),
                  border: Border.all(
                    color: const Color(0xFF66D122),
                    width: 1.1 * scale,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Member Details',
                        style: GoogleFonts.montserrat(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 14 * scale),
                    _DetailRow(label: 'Name :', value: name, scale: scale),
                    SizedBox(height: 10 * scale),
                    _DetailRow(
                      label: 'Phone Number :',
                      value: phone,
                      scale: scale,
                    ),
                    SizedBox(height: 10 * scale),
                    _DetailRow(
                      label: 'Amount Received :',
                      value: amount,
                      scale: scale,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.scale,
  });

  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14.5 * scale,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(
              fontSize: 14.5 * scale,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 59 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C).withOpacity(0.9),
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 14 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24 * scale),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 17 * scale,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SlideToActivate extends StatelessWidget {
  const _SlideToActivate({
    required this.scale,
    required this.onCompleted,
    required this.isLoading,
  });

  final double scale;
  final Future<void> Function() onCompleted;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SlideAction(
      height: 59 * scale,
      innerColor: const Color(0xFF6CE800),
      outerColor: const Color(0xFF1C1C1C),
      sliderButtonIcon: Icon(
        Icons.chevron_right,
        color: Colors.white,
        size: 28 * scale,
      ),
      text: isLoading ? 'Activating Membership...' : 'Slide to Activate',
      textStyle: GoogleFonts.montserrat(
        fontSize: 17 * scale,
        fontWeight: FontWeight.w600,
        color: Colors.white70,
      ),
      borderRadius: 24 * scale,
      onSubmit: () async {
        await onCompleted();
      },
    );
  }
}
