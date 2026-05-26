import 'package:azanto/views/widgets/azanto_mobile_shell.dart';
import 'package:flutter/material.dart';

/// Member tab bar — matches Figma `gym member persona app` bottom nav.
class MemberBottomNavBar extends StatelessWidget {
  const MemberBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return AzantoBottomNavBar(
      items: AzantoBottomNavBar.memberItems,
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
