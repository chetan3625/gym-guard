import 'package:azanto/Memberside/constants/Common_widgets/member_figma_page_shell.dart';
import 'package:azanto/Memberside/constants/member_figma_layout.dart';
import 'package:azanto/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Figma: `update Measurement Page` (447:1017).
class MemberUpdateMeasurementPage extends StatefulWidget {
  const MemberUpdateMeasurementPage({super.key});

  @override
  State<MemberUpdateMeasurementPage> createState() =>
      _MemberUpdateMeasurementPageState();
}

class _MemberUpdateMeasurementPageState extends State<MemberUpdateMeasurementPage> {
  double _weight = 78.5;
  double _heightCm = 150;
  final TextEditingController _muscleController =
      TextEditingController(text: '38.2');

  @override
  void dispose() {
    _muscleController.dispose();
    super.dispose();
  }

  void _save() {
    Get.back<void>();
    Get.snackbar(
      'Saved',
      'Your measurements were updated.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.brandGreen.withValues(alpha: 0.92),
      colorText: Colors.black,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = MemberFigmaLayout(context);

    return MemberFigmaPageShell(
      bottomNavIndex: 2,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: layout.padLTRB(26, 8, 26, 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const MemberFigmaBackButton(),
                  SizedBox(height: layout.s(12)),
                  Center(child: _WeighingHero(layout: layout)),
                  SizedBox(height: layout.s(22)),
                  _FormCard(
                    layout: layout,
                    weight: _weight,
                    heightCm: _heightCm,
                    muscleController: _muscleController,
                    onWeightChanged: (v) => setState(() => _weight = v),
                    onHeightChanged: (v) => setState(() => _heightCm = v),
                  ),
                  SizedBox(height: layout.s(36)),
                  _SaveButton(layout: layout, onPressed: _save),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WeighingHero extends StatelessWidget {
  const _WeighingHero({required this.layout});

  final MemberFigmaLayout layout;

  @override
  Widget build(BuildContext context) {
    final outer = layout.s(83);
    final inner = layout.s(75);
    final icon = layout.s(42);

    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: outer,
            height: outer,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MemberFigmaColors.accent.withValues(alpha: 0.08),
            ),
          ),
          Container(
            width: inner,
            height: inner,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF353535),
            ),
            child: Icon(
              LucideIcons.scale,
              color: MemberFigmaColors.accent,
              size: icon,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.layout,
    required this.weight,
    required this.heightCm,
    required this.muscleController,
    required this.onWeightChanged,
    required this.onHeightChanged,
  });

  final MemberFigmaLayout layout;
  final double weight;
  final double heightCm;
  final TextEditingController muscleController;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<double> onHeightChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: layout.s(342),
      padding: layout.padLTRB(25, 25, 25, 25),
      decoration: BoxDecoration(
        color: MemberFigmaColors.formBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MemberFigmaColors.cardIconCircle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: layout.s(50),
            offset: Offset(0, layout.s(25)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WeightSection(
            layout: layout,
            value: weight,
            onChanged: onWeightChanged,
          ),
          SizedBox(height: layout.s(32)),
          _HeightSection(
            layout: layout,
            value: heightCm,
            onChanged: onHeightChanged,
          ),
          SizedBox(height: layout.s(32)),
          _MuscleMassSection(layout: layout, controller: muscleController),
        ],
      ),
    );
  }
}

class _WeightSection extends StatelessWidget {
  const _WeightSection({
    required this.layout,
    required this.value,
    required this.onChanged,
  });

  final MemberFigmaLayout layout;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weight (kg)',
              style: layout.montserrat(
                size: 14,
                weight: FontWeight.w500,
                color: MemberFigmaColors.label,
                letterSpacing: 0.35,
                height: 20 / 14,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: layout.montserrat(
                size: 24,
                weight: FontWeight.w700,
                color: MemberFigmaColors.accent,
                height: 32 / 24,
              ),
            ),
          ],
        ),
        SizedBox(height: layout.s(16)),
        Row(
          children: [
            _SquareControl(
              layout: layout,
              child: Container(
                width: layout.s(14),
                height: layout.s(2),
                color: Colors.white70,
              ),
              onTap: () => onChanged((value - 0.5).clamp(30.0, 200.0)),
            ),
            SizedBox(width: layout.s(12)),
            Expanded(
              child: Container(
                height: layout.s(48),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MemberFigmaColors.fieldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MemberFigmaColors.cardIconCircle),
                ),
                child: Text(
                  value.toStringAsFixed(1),
                  style: layout.montserrat(
                    size: 20,
                    weight: FontWeight.w700,
                    color: MemberFigmaColors.textPrimary,
                    height: 28 / 20,
                  ),
                ),
              ),
            ),
            SizedBox(width: layout.s(12)),
            _SquareControl(
              layout: layout,
              child: Icon(Icons.add, color: Colors.white70, size: layout.s(14)),
              onTap: () => onChanged((value + 0.5).clamp(30.0, 200.0)),
            ),
          ],
        ),
      ],
    );
  }
}

class _SquareControl extends StatelessWidget {
  const _SquareControl({
    required this.layout,
    required this.child,
    required this.onTap,
  });

  final MemberFigmaLayout layout;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MemberFigmaColors.inputBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: layout.s(48),
          height: layout.s(48),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MemberFigmaColors.cardIconCircle),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _HeightSection extends StatelessWidget {
  const _HeightSection({
    required this.layout,
    required this.value,
    required this.onChanged,
  });

  final MemberFigmaLayout layout;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'height',
              style: layout.montserrat(
                size: 14,
                weight: FontWeight.w500,
                color: MemberFigmaColors.label,
                letterSpacing: 0.35,
                height: 20 / 14,
              ),
            ),
            Text(
              '${value.round()} cm',
              style: layout.montserrat(
                size: 24,
                weight: FontWeight.w700,
                color: MemberFigmaColors.accent,
                height: 32 / 24,
              ),
            ),
          ],
        ),
        SizedBox(height: layout.s(16)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: layout.s(6),
            trackShape: const RoundedRectSliderTrackShape(),
            activeTrackColor: MemberFigmaColors.inputBg,
            inactiveTrackColor: MemberFigmaColors.inputBg,
            overlayShape: SliderComponentShape.noOverlay,
            thumbShape: _FigmaSliderThumb(layout: layout),
          ),
          child: Slider(
            min: 120,
            max: 220,
            value: value,
            onChanged: onChanged,
          ),
        ),
        SizedBox(height: layout.s(8)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: layout.s(4)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SliderTag(layout: layout, text: 'Athletic', align: Alignment.centerLeft),
              _SliderTag(layout: layout, text: 'Average', align: Alignment.center),
              _SliderTag(layout: layout, text: 'High', align: Alignment.centerRight),
            ],
          ),
        ),
      ],
    );
  }
}

class _SliderTag extends StatelessWidget {
  const _SliderTag({
    required this.layout,
    required this.text,
    required this.align,
  });

  final MemberFigmaLayout layout;
  final String text;
  final Alignment align;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: align,
      child: Text(
        text,
        style: layout.montserrat(
          size: 10,
          weight: FontWeight.w700,
          color: MemberFigmaColors.labelMuted,
          letterSpacing: 1,
          height: 15 / 10,
        ),
      ),
    );
  }
}

class _FigmaSliderThumb extends SliderComponentShape {
  const _FigmaSliderThumb({required this.layout});

  final MemberFigmaLayout layout;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(layout.s(18), layout.s(18));

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final radius = layout.s(9);
    final fill = Paint()..color = MemberFigmaColors.accent;
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = layout.s(3);

    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(center, radius, stroke);
  }
}

class _MuscleMassSection extends StatelessWidget {
  const _MuscleMassSection({
    required this.layout,
    required this.controller,
  });

  final MemberFigmaLayout layout;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Muscle Mass (kg)',
          style: layout.montserrat(
            size: 14,
            weight: FontWeight.w500,
            color: MemberFigmaColors.label,
            letterSpacing: 0.35,
            height: 20 / 14,
          ),
        ),
        SizedBox(height: layout.s(12)),
        Container(
          height: layout.s(56),
          decoration: BoxDecoration(
            color: MemberFigmaColors.fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MemberFigmaColors.cardIconCircle),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: layout.s(16),
                  right: layout.s(12),
                ),
                child: Icon(
                  LucideIcons.dumbbell,
                  color: MemberFigmaColors.accent,
                  size: layout.s(20),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: layout.montserrat(
                    size: 18,
                    weight: FontWeight.w600,
                    color: MemberFigmaColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              SizedBox(width: layout.s(12)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.layout, required this.onPressed});

  final MemberFigmaLayout layout;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: layout.s(342),
        height: layout.s(60),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF43890D), MemberFigmaColors.accent],
              stops: [0.0, 0.99038],
            ),
            boxShadow: [
              BoxShadow(
                color: MemberFigmaColors.accent.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: Offset(0, layout.s(8)),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: layout.s(20),
                  ),
                  SizedBox(width: layout.s(8)),
                  Text(
                    'SAVE CHANGES',
                    style: layout.montserrat(
                      size: 16,
                      weight: FontWeight.w700,
                      color: Colors.white,
                      height: 28 / 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
