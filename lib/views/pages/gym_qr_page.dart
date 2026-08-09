import 'package:azanto/Services/gym_qr_service.dart';
import 'package:azanto/controllers/home_controller.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GymQrPage extends StatefulWidget {
  const GymQrPage({super.key});
  @override
  State<GymQrPage> createState() => _GymQrPageState();
}

class _GymQrPageState extends State<GymQrPage> {
  final _service = GymQrService();
  GymQrData? _data;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final c = Get.find<HomeController>();
      final gym = c.session.gymId ?? '';
      final branch = c.session.branchId ?? '';
      if (gym.isEmpty || branch.isEmpty) {
        throw Exception('Set up a gym branch before displaying its QR code.');
      }
      final data = await _service.getOwnerQr(gymId: gym, branchId: branch);
      if (mounted) {
        setState(() => _data = data);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: AppColors.mobileScaffold,
      appBar: AppBar(
          backgroundColor: AppColors.mobileScaffold,
          elevation: 0,
          title: Text('Your gym QR',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: _error != null
                  ? Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(_error!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.white70)),
                      TextButton(onPressed: _load, child: const Text('Retry'))
                    ])
                  : _data == null
                      ? const CircularProgressIndicator(
                          color: AppColors.brandGreen)
                      : Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(_data!.gymName,
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700)),
                          Text(_data!.branchName,
                              style: GoogleFonts.poppins(
                                  color: AppColors.textMuted)),
                          const SizedBox(height: 24),
                          Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24)),
                              child: QrImageView(
                                  data: _data!.payload,
                                  version: QrVersions.auto,
                                  size: 240,
                                  eyeStyle: const QrEyeStyle(
                                      eyeShape: QrEyeShape.square,
                                      color: Colors.black),
                                  dataModuleStyle: const QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.square,
                                      color: Colors.black))),
                          const SizedBox(height: 22),
                          Text(
                              'New members scan to join ${_data!.gymName} and start their ${_data!.trialDays}-day free trial.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: Colors.white70, height: 1.5)),
                          const SizedBox(height: 10),
                          Text(
                              'Place this at reception. Members must be signed in to scan.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: AppColors.brandGreen, fontSize: 12))
                        ]))));
}
