import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AzantoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AzantoAppBar({super.key, this.showLogout = false, this.onLogout});

  final bool showLogout;
  final VoidCallback? onLogout;

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2F3136), // 0%
              Color(0xFF1E1F23), // 62%
              Color(0xFF0F1014), // 100%
            ],
            stops: [0.0, 0.62, 1.0],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
      ),
      title: Text(
        'Azanto',
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.6,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings, color: Colors.white70, size: 22),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none,
            color: Colors.white70,
            size: 22,
          ),
        ),
        if (showLogout)
          IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout, color: Colors.white70, size: 22),
            tooltip: 'Logout',
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}
