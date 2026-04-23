import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MemberProfilePage extends StatelessWidget {
  const MemberProfilePage({
    super.key,
    required this.memberName,
    required this.memberInitial,
    required this.onLogout,
  });

  final String memberName;
  final String memberInitial;
  final Future<void> Function() onLogout;

  static const List<_ManagementItem> _items = [
    _ManagementItem(
      icon: LucideIcons.clipboardCheck,
      title: 'Personal Information',
      subtitle: 'Name, email, photo',
    ),
    _ManagementItem(
      icon: LucideIcons.dumbbell,
      title: 'Gym Details',
      subtitle: 'Location, equipment, staff',
    ),
    _ManagementItem(
      icon: LucideIcons.shieldCheck,
      title: 'Security',
      subtitle: 'Change Password, Login Activity',
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
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHero(
              memberName: memberName,
              memberInitial: memberInitial,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Management',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ManagementCard(item: item),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await onLogout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandGreen,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Azanto',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.memberName,
    required this.memberInitial,
  });

  final String memberName;
  final String memberInitial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 26),
      decoration: const BoxDecoration(
        color: Color(0xFF427A18),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(58),
          bottomRight: Radius.circular(58),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 11,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Back',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Subscribed',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 92,
            width: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.brandGreen, width: 4),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF6F6F6), Color(0xFFDBDBDB)],
              ),
            ),
            child: Center(
              child: Text(
                memberInitial,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF2D2D2D),
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            memberName,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Gym Member',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Getfit Studio',
            style: GoogleFonts.poppins(
              color: AppColors.brandGreen,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 2,
            width: double.infinity,
            color: Colors.white.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _HeroStat(
                  value: '24',
                  unit: '',
                  label: 'BMI',
                ),
              ),
              _HeroDivider(),
              Expanded(
                child: _HeroStat(
                  value: '75',
                  unit: 'Kg',
                  label: 'Weight',
                ),
              ),
              _HeroDivider(),
              Expanded(
                child: _HeroStat(
                  value: '189',
                  unit: 'cm',
                  label: 'Height',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.55),
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              'Edit Profile',
              style: GoogleFonts.poppins(
                color: Colors.black87,
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

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.value,
    required this.unit,
    required this.label,
  });

  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white54,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HeroDivider extends StatelessWidget {
  const _HeroDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: 1.5,
      color: AppColors.brandGreen.withValues(alpha: 0.70),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  const _ManagementCard({required this.item});

  final _ManagementItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF565656),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white70,
            size: 28,
          ),
        ],
      ),
    );
  }
}

class _ManagementItem {
  const _ManagementItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
