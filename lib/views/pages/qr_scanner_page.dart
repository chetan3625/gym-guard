import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isHandlingResult = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Uri? _normalizeUrl(String input) {
    final trimmed = input.trim();
    final parsed = Uri.tryParse(trimmed);

    // Accept valid http/https straight away.
    if (parsed != null &&
        parsed.hasScheme &&
        (parsed.isScheme('http') || parsed.isScheme('https'))) {
      return parsed;
    }

    // If the code is like "example.com" or "www.example.com", prepend https://
    if (parsed != null && !parsed.hasScheme) {
      final withHttps = Uri.tryParse('https://$trimmed');
      if (withHttps != null && withHttps.host.isNotEmpty) {
        return withHttps;
      }
    }

    return null;
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isHandlingResult || capture.barcodes.isEmpty) return;

    final String? rawValue = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .firstWhere(
          (value) => value != null && value.trim().isNotEmpty,
          orElse: () => null,
        );

    if (rawValue == null) return;

    setState(() => _isHandlingResult = true);
    final uri = _normalizeUrl(rawValue);

    if (uri == null) {
      _showMessage(
        'Not a link',
        'Scan a QR code that contains a valid http/https URL.',
      );
      _resumeScanning();
      return;
    }

    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        _showMessage('Unable to open', 'Could not open ${uri.toString()}.');
        _resumeScanning();
        return;
      }
      if (mounted) Get.back();
    } catch (_) {
      _showMessage('Unable to open', 'Could not open ${uri.toString()}.');
      _resumeScanning();
    }
  }

  void _resumeScanning() {
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _isHandlingResult = false);
    });
  }

  void _showMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.85),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final squareSize = MediaQuery.of(context).size.width * 0.75;

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Scan QR',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.white70,
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  fit: BoxFit.cover,
                  onDetect: _handleDetection,
                ),
                _ScannerOverlay(squareSize: squareSize),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Text(
              'Point your camera at a QR code. If it contains a link, we will open it in your browser.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay({required this.squareSize});

  final double squareSize;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: squareSize,
          height: squareSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.brandGreen.withOpacity(0.9),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandGreen.withOpacity(0.25),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
