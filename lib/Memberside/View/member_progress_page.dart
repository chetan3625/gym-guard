import 'package:azanto/Memberside/View/member_update_measurement_page.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:azanto/views/widgets/azanto_mobile_shell.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MemberProgressPage extends StatelessWidget {
  const MemberProgressPage({super.key});

  static const List<_MilestoneData> _milestones = [
    _MilestoneData(
      title: 'First 5K Run',
      icon: LucideIcons.personStanding,
      isActive: true,
    ),
    _MilestoneData(
      title: '10KG Lost',
      icon: LucideIcons.badgeCheck,
    ),
    _MilestoneData(
      title: 'Gym ID',
      icon: LucideIcons.dumbbell,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: azantoContentPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProgressTitleSection(
            onUpgradeTap: () =>
                Get.to<void>(() => const MemberUpdateMeasurementPage()),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                  child: _StatCard(label: 'Weight', value: '70', unit: 'kg')),
              SizedBox(width: 10),
              Expanded(
                  child: _StatCard(label: 'Body Fat', value: '12', unit: '%')),
            ],
          ),
          const SizedBox(height: 10),
          const _BmiStatusCard(),
          const SizedBox(height: 10),
          const _WeightAnalysisCard(),
          const SizedBox(height: 16),
          Text(
            'Milestones',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _milestones
                .map(
                  (milestone) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: milestone == _milestones.last ? 0 : 10,
                      ),
                      child: _MilestoneCard(data: milestone),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          const _MetricSummaryCard(
            title: 'MUSCLE MASS',
            subtitle: 'SINCE DEC 20TH',
            leadingIcon: LucideIcons.zap,
            accentColor: AppColors.brandGreen,
            valueText: '+2kg',
          ),
          const SizedBox(height: 10),
          const _MetricSummaryCard(
            title: 'WATER RETENTION',
            subtitle: 'CURRENT LEVELS',
            leadingIcon: LucideIcons.droplets,
            accentColor: Color(0xFFFF8A1F),
            valueText: '-1.5%',
          ),
        ],
      ),
    );
  }
}

class _ProgressTitleSection extends StatelessWidget {
  const _ProgressTitleSection({required this.onUpgradeTap});

  final VoidCallback onUpgradeTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR PROGRESS',
                style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'PERFORMANCE',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: AppColors.brandGreen,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: onUpgradeTap,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandGreen.withValues(alpha: 0.16),
                    blurRadius: 12,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Text(
                'Upgrade',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 11),
      decoration: BoxDecoration(
        color: const Color(0xFF353535),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: GoogleFonts.poppins(
                    color: AppColors.brandGreen,
                    fontSize: 29,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                LucideIcons.trendingDown,
                color: AppColors.brandGreen,
                size: 11,
              ),
              const SizedBox(width: 4),
              Text(
                '-0.8 kg vs last week',
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BmiStatusCard extends StatelessWidget {
  const _BmiStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF353535),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BMI Status',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '22.5',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandGreen.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'NORMAL',
                  style: GoogleFonts.poppins(
                    color: AppColors.brandGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(
                      flex: 36, child: ColoredBox(color: Color(0xFF4C71FF))),
                  Expanded(
                      flex: 28, child: ColoredBox(color: AppColors.brandGreen)),
                  Expanded(
                      flex: 20, child: ColoredBox(color: Color(0xFFAD5F28))),
                  Expanded(
                      flex: 16, child: ColoredBox(color: Color(0xFFB74C4C))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Healthy Range',
            style: GoogleFonts.poppins(
              color: Colors.white38,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightAnalysisCard extends StatelessWidget {
  const _WeightAnalysisCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF353535),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'WEIGHT ANALYSIS',
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const _RangeChip(label: '1W', isActive: true),
              const SizedBox(width: 8),
              const _RangeChip(label: '1M'),
              const SizedBox(width: 8),
              const _RangeChip(label: '6M'),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 240,
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _axisLabel('78kg'),
                      _axisLabel('76kg'),
                      _axisLabel('74kg'),
                      _axisLabel('72kg'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(child: _WeightLineChart()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _axisLabel(String value) {
    return Text(
      value,
      style: GoogleFonts.poppins(
        color: Colors.white24,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    this.isActive = false,
  });

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.brandGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: isActive ? Colors.black : Colors.white24,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WeightLineChart extends StatelessWidget {
  const _WeightLineChart();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(
          child: CustomPaint(
            painter: _WeightChartPainter(),
            child: SizedBox.expand(),
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ChartDayLabel(label: 'MON'),
            _ChartDayLabel(label: 'TUE'),
            _ChartDayLabel(label: 'WED'),
            _ChartDayLabel(label: 'THU'),
            _ChartDayLabel(label: 'FRI'),
            _ChartDayLabel(label: 'SAT'),
            _ChartDayLabel(label: 'SUN', isActive: true),
          ],
        ),
      ],
    );
  }
}

class _ChartDayLabel extends StatelessWidget {
  const _ChartDayLabel({
    required this.label,
    this.isActive = false,
  });

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        color: isActive ? AppColors.brandGreen : Colors.white24,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  const _WeightChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    final chartRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rowGap = chartRect.height / 4;

    for (int i = 0; i < 4; i++) {
      final y = rowGap * i;
      canvas.drawLine(Offset(0, y), Offset(chartRect.width, y), gridPaint);
    }

    final points = <Offset>[
      Offset(chartRect.width * 0.02, chartRect.height * 0.70),
      Offset(chartRect.width * 0.18, chartRect.height * 0.69),
      Offset(chartRect.width * 0.34, chartRect.height * 0.73),
      Offset(chartRect.width * 0.50, chartRect.height * 0.68),
      Offset(chartRect.width * 0.70, chartRect.height * 0.45),
      Offset(chartRect.width * 0.84, chartRect.height * 0.28),
      Offset(chartRect.width * 0.98, chartRect.height * 0.18),
    ];

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlX = (current.dx + next.dx) / 2;
      linePath.cubicTo(
          controlX, current.dy, controlX, next.dy, next.dx, next.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, chartRect.height)
      ..lineTo(points.first.dx, chartRect.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.brandGreen.withValues(alpha: 0.35),
          AppColors.brandGreen.withValues(alpha: 0.05),
        ],
      ).createShader(chartRect);

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF5AD91E), AppColors.brandGreen],
      ).createShader(chartRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    final markerPaint = Paint()..color = Colors.black;
    final markerStroke = Paint()
      ..color = AppColors.brandGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (final point in [points[2], points[3]]) {
      canvas.drawCircle(point, 4.5, markerPaint);
      canvas.drawCircle(point, 4.5, markerStroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({required this.data});

  final _MilestoneData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF474747),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: data.isActive ? AppColors.brandGreen : Colors.transparent,
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              data.icon,
              color: data.isActive ? AppColors.brandGreen : Colors.white38,
              size: 18,
            ),
          ),
          const Spacer(),
          Text(
            data.title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricSummaryCard extends StatelessWidget {
  const _MetricSummaryCard({
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.accentColor,
    required this.valueText,
  });

  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final Color accentColor;
  final String valueText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF353535),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(leadingIcon, color: accentColor, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.white24,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            valueText,
            style: GoogleFonts.poppins(
              color: accentColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneData {
  const _MilestoneData({
    required this.title,
    required this.icon,
    this.isActive = false,
  });

  final String title;
  final IconData icon;
  final bool isActive;
}
