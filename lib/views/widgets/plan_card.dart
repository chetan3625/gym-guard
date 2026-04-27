import 'dart:ui';

import 'package:azanto/views/models/plan_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.option,
    this.scale = 1.0,
    this.onButtonTap,
    this.showButton = true,
    this.buttonLabel = 'Select Plan',
    this.isSelected = false,
    this.showAccentBar = false,
    this.forcedWidth,
    this.forcedHeight,
    this.customContentPadding,
    this.titleFontSize,
    this.titleFontWeight,
  });

  final PlanOption option;
  final double scale;
  final VoidCallback? onButtonTap;
  final bool showButton;
  final String buttonLabel;
  final bool isSelected;
  final bool showAccentBar;
  final double? forcedWidth;
  final double? forcedHeight;
  final EdgeInsets? customContentPadding;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = forcedWidth ?? 364.w * scale;
    final effectiveHeight = forcedHeight;
    final radius = 26.r * scale;

    return Center(
      child: SizedBox(
        width: effectiveWidth,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12.r * scale,
              sigmaY: 12.r * scale,
            ),
            child: Container(
              constraints: BoxConstraints(
                minHeight: effectiveHeight ?? 210.h * scale,
              ),
              padding: customContentPadding ??
                  EdgeInsets.fromLTRB(
                    18.w * scale,
                    22.h * scale,
                    18.w * scale,
                    20.h * scale,
                  ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.62),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: isSelected
                      ? option.borderColor
                      : option.borderColor.withValues(alpha: 0.45),
                  width: isSelected ? 2.4.w * scale : 1.2.w * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 18.r * scale,
                    offset: Offset(0, 12.h * scale),
                  ),
                  if (isSelected)
                    BoxShadow(
                      color: option.borderColor.withValues(alpha: 0.35),
                      blurRadius: 24.r * scale,
                      spreadRadius: 1.2.w * scale,
                      offset: Offset(0, 6.h * scale),
                    ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showAccentBar)
                    SizedBox(
                      width: 62.w * scale,
                      height: 4.h * scale,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFDE141), Color(0xFFE1C03D)],
                          ),
                          borderRadius: BorderRadius.circular(8.r * scale),
                        ),
                      ),
                    )
                  else
                    SizedBox(height: 2.h * scale),
                  SizedBox(height: 12.h * scale),
                  Text(
                    option.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      color: option.titleColor,
                      fontSize: (titleFontSize ?? 30.sp) * scale,
                      fontWeight: titleFontWeight ?? FontWeight.w600,
                    ),
                  ),
                  Text(
                    option.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      color: Colors.white70,
                      fontSize: 14.5.sp * scale,
                    ),
                  ),
                  SizedBox(height: 16.h * scale),
                  Text(
                    option.price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      color: option.priceColor,
                      fontSize: 24.sp * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 18.h * scale),
                  if (showButton)
                    ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 48.h * scale),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: option.buttonGradient,
                          borderRadius: BorderRadius.circular(18.r * scale),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 12.r * scale,
                              offset: Offset(0, 6.h * scale),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18.r * scale),
                            onTap: onButtonTap,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 12.h * scale,
                              ),
                              child: Center(
                                child: Text(
                                  buttonLabel,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16.sp * scale,
                                    fontWeight: FontWeight.w600,
                                    color: option.buttonTextColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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
