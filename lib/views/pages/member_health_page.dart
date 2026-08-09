import 'package:azanto/Services/member_health_service.dart';
import 'package:azanto/controllers/home_controller.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/models/member_health_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberHealthPage extends StatefulWidget {
  const MemberHealthPage({super.key});
  @override
  State<MemberHealthPage> createState() => _MemberHealthPageState();
}

class _MemberHealthPageState extends State<MemberHealthPage> {
  final _service = MemberHealthService();
  String _filter = 'all';
  int _threshold = 7;
  bool _loading = true;
  String? _error;
  List<MemberHealthModel> _members = const [];
  Map<String, dynamic> _summary = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final controller = Get.find<HomeController>();
    final gymId = controller.session.gymId?.trim() ?? '';
    final branchId = controller.session.branchId?.trim() ?? '';
    if (gymId.isEmpty || branchId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Choose a gym branch before viewing member health.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _service.load(
          gymId: gymId,
          branchId: branchId,
          inactiveDays: _threshold,
          filter: _filter);
      if (mounted) {
        setState(() {
          _members = result.members;
          _summary = result.summary;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _contact(MemberHealthModel member, String channel) async {
    final phone = member.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (phone.isEmpty) {
      Get.snackbar(
          'No phone number', 'This member has no phone number on record.');
      return;
    }
    final message = Uri.encodeComponent(
        'Hi ${member.name}, we miss seeing you at the gym. Want help getting back into your routine?');
    final uri = switch (channel) {
      'call' => Uri.parse('tel:$phone'),
      'sms' => Uri.parse('sms:$phone?body=$message'),
      _ => Uri.parse('https://wa.me/$phone?text=$message'),
    };
    final controller = Get.find<HomeController>();
    await _service.recordOutreach(
        gymId: controller.session.gymId ?? '',
        branchId: controller.session.branchId ?? '',
        memberId: member.memberId,
        channel: channel);
    if (!await launchUrl(uri,
        mode: channel == 'whatsapp'
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault)) {
      if (mounted) {
        Get.snackbar('Unable to open', 'No app could handle this action.');
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.mobileScaffold,
        appBar: AppBar(
            backgroundColor: AppColors.mobileScaffold,
            elevation: 0,
            title: Text('Member health',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            actions: [
              IconButton(
                  onPressed: _load, icon: const Icon(Icons.refresh_rounded))
            ]),
        body: RefreshIndicator(
          color: AppColors.brandGreen,
          onRefresh: _load,
          child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                Text('Keep members coming back',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Reach out before a missed week becomes a lost member.',
                    style: GoogleFonts.poppins(
                        color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 18),
                _Summary(summary: _summary),
                const SizedBox(height: 18),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final item in const [
                    ('all', 'All'),
                    ('inactive', 'Inactive'),
                    ('red', '10+ days'),
                    ('expiring', 'Expiring')
                  ])
                    ChoiceChip(
                        label: Text(item.$2),
                        selected: _filter == item.$1,
                        selectedColor: AppColors.brandGreen,
                        labelStyle: GoogleFonts.poppins(
                            color: _filter == item.$1
                                ? Colors.black
                                : Colors.white),
                        onSelected: (_) {
                          setState(() => _filter = item.$1);
                          _load();
                        }),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Text('Inactive after $_threshold days',
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 12)),
                  const Spacer(),
                  DropdownButton<int>(
                      value: _threshold,
                      dropdownColor: AppColors.cardSurface,
                      style: GoogleFonts.poppins(color: AppColors.brandGreen),
                      underline: const SizedBox(),
                      items: const [5, 7, 10, 14]
                          .map((d) => DropdownMenuItem(
                              value: d, child: Text('$d days')))
                          .toList(),
                      onChanged: (d) {
                        if (d != null) {
                          setState(() => _threshold = d);
                          _load();
                        }
                      })
                ]),
                const SizedBox(height: 8),
                if (_loading)
                  const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.brandGreen)))
                else if (_error != null)
                  _EmptyState(message: _error!, onRetry: _load)
                else if (_members.isEmpty)
                  _EmptyState(
                      message: 'No members need attention in this view.',
                      onRetry: _load)
                else
                  ..._members
                      .map((m) => _MemberCard(member: m, onContact: _contact)),
              ]),
        ),
      );
}

class _Summary extends StatelessWidget {
  const _Summary({required this.summary});
  final Map<String, dynamic> summary;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF252028),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF4F3438))),
      child: Row(children: [
        _Stat(
            label: 'At risk',
            value: '${summary['red'] ?? 0}',
            color: AppColors.accentRed),
        _Stat(
            label: 'Inactive',
            value: '${summary['inactive'] ?? 0}',
            color: const Color(0xFFFFB547)),
        _Stat(
            label: 'Renew soon',
            value: '${summary['expiring'] ?? 0}',
            color: AppColors.brandGreen)
      ]));
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) => Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: GoogleFonts.poppins(
                color: color, fontSize: 24, fontWeight: FontWeight.w700)),
        Text(label,
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11))
      ]));
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, required this.onContact});
  final MemberHealthModel member;
  final Future<void> Function(MemberHealthModel, String) onContact;
  @override
  Widget build(BuildContext context) {
    final red = member.isRed;
    return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: red ? AppColors.accentRed : const Color(0xFF343741))),
        child: Column(children: [
          Row(children: [
            CircleAvatar(
                backgroundColor:
                    red ? const Color(0xFF46282A) : const Color(0xFF273721),
                child: Text(
                    member.name.isEmpty ? '?' : member.name[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                        color: red ? AppColors.accentRed : AppColors.brandGreen,
                        fontWeight: FontWeight.w700))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(member.name,
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  Text('${member.planName} · ${member.inactiveDays} days away',
                      style: GoogleFonts.poppins(
                          color: red
                              ? const Color(0xFFFF9D96)
                              : AppColors.textMuted,
                          fontSize: 12))
                ])),
            if (member.daysToEnd != null)
              Text('${member.daysToEnd}d left',
                  style: GoogleFonts.poppins(
                      color: const Color(0xFFFFB547), fontSize: 11))
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _Action(
                icon: Icons.call_outlined,
                label: 'Call',
                onTap: () => onContact(member, 'call')),
            const SizedBox(width: 8),
            _Action(
                icon: Icons.sms_outlined,
                label: 'SMS',
                onTap: () => onContact(member, 'sms')),
            const SizedBox(width: 8),
            _Action(
                icon: Icons.chat_outlined,
                label: 'WhatsApp',
                onTap: () => onContact(member, 'whatsapp'))
          ])
        ]));
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
      child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandGreen,
              side: BorderSide(
                  color: AppColors.brandGreen.withValues(alpha: .45)),
              padding: const EdgeInsets.symmetric(vertical: 9),
              textStyle: GoogleFonts.poppins(
                  fontSize: 11, fontWeight: FontWeight.w600))));
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 52),
      child: Column(children: [
        const Icon(Icons.favorite_outline_rounded,
            color: AppColors.brandGreen, size: 40),
        const SizedBox(height: 10),
        Text(message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white70)),
        TextButton(onPressed: onRetry, child: const Text('Try again'))
      ]));
}
