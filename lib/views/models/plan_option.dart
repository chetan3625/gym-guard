import 'package:flutter/material.dart';

class PlanOption {
  const PlanOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.titleColor,
    required this.borderColor,
    required this.buttonGradient,
    required this.buttonTextColor,
    this.priceColor = Colors.white,
  });

  final String id;
  final String title;
  final String subtitle;
  final String price;
  final Color titleColor;
  final Color borderColor;
  final Gradient buttonGradient;
  final Color buttonTextColor;
  final Color priceColor;
}
