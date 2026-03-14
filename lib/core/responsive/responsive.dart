import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveBreakpoints {
  const ResponsiveBreakpoints._();

  static const double phoneSmall = 360;
  static const double phone = 600;
  static const double tablet = 1024;
  static const double large = 1280;
}

bool isTablet(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= ResponsiveBreakpoints.tablet;

double maxContentWidth(
  BuildContext context, {
  double tablet = 720,
  double large = 900,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= ResponsiveBreakpoints.large) return large.w;
  if (width >= ResponsiveBreakpoints.tablet) return tablet.w;
  return width;
}

double padH(double value) => value.w;
double padV(double value) => value.h;
double gap(double value) => value.h;

class MaxWidthContainer extends StatelessWidget {
  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.alignment = Alignment.topCenter,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final Alignment alignment;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final resolvedMaxWidth =
        maxWidth ?? maxContentWidth(context, tablet: 720, large: 900);
    final resolvedPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: width >= ResponsiveBreakpoints.tablet ? 24.w : 16.w,
        );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: resolvedMaxWidth),
        child: Padding(
          padding: resolvedPadding,
          child: child,
        ),
      ),
    );
  }
}
