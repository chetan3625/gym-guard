import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Scales Figma artboard (393×852) dimensions to the current screen width.
class MemberFigmaLayout {
  MemberFigmaLayout(this.context, {double? designWidth})
      : designWidth = designWidth ?? MemberFigmaLayout.defaultDesignWidth;

  final BuildContext context;
  final double designWidth;

  static const double defaultDesignWidth = 393;
  static const double personalInfoDesignWidth = 440;
  static const double designHeight = 852;

  double get scale => MediaQuery.sizeOf(context).width / designWidth;

  double s(double value) => value * scale;

  EdgeInsets padLTRB(double l, double t, double r, double b) =>
      EdgeInsets.fromLTRB(s(l), s(t), s(r), s(b));

  TextStyle montserrat({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = Colors.white,
    double? height,
    double letterSpacing = 0,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.montserrat(
      fontSize: s(size),
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing == 0 ? null : s(letterSpacing),
      decoration: decoration,
    );
  }
}

/// Figma accent used on upgrade / measurement flows (#84FE56).
class MemberFigmaColors {
  static const Color accent = Color(0xFF84FE56);
  static const Color accentDarkText = Color(0xFF1B5F00);
  static const Color label = Color(0xFFACABAA);
  static const Color labelMuted = Color(0xFF767575);
  static const Color cardBg = Color(0xFF313131);
  static const Color cardBorder = Color(0xFF262626);
  static const Color formBg = Color(0xFF272727);
  static const Color inputBg = Color(0xFF393A38);
  static const Color fieldBg = Color(0x66000000);
  static const Color textPrimary = Color(0xFFFAF9F6);
  static const Color textDim = Color(0xFF737373);
  static const Color textLegal = Color(0xFF525252);
  static const Color cardIconCircle = Color(0xFF484848);
}
