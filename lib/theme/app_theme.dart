import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Core Palette ──────────────────────────────────────────
  static const Color primary      = Color(0xFF0D3B24);
  static const Color primaryLight = Color(0xFF1A6B41);
  static const Color accent       = Color(0xFF2ECC71);
  static const Color accentDark   = Color(0xFF27AE60);
  static const Color gold         = Color(0xFFF39C12);

  // Light mode
  static const Color bgLight      = Color(0xFFF0F4F2);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight    = Color(0xFFFFFFFF);

  // Dark mode
  static const Color bgDark       = Color(0xFF0A0F0C);
  static const Color surfaceDark  = Color(0xFF111A14);
  static const Color cardDark     = Color(0xFF182219);

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D3B24), Color(0xFF1A6B41)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF0D3B24), Color(0xFF145A32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient pendingGradient = LinearGradient(
    colors: [Colors.orange.shade700, Colors.orange.shade400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows ───────────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF0D3B24).withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.07),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Border Radius ─────────────────────────────────────────
  static final BorderRadius radiusSmall  = BorderRadius.circular(12);
  static final BorderRadius radiusMedium = BorderRadius.circular(18);
  static final BorderRadius radiusLarge  = BorderRadius.circular(24);
  static final BorderRadius radiusXL     = BorderRadius.circular(32);

  // ── Text Styles ───────────────────────────────────────────
  static TextStyle get displayStyle => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      );

  static TextStyle get titleStyle => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      );

  static TextStyle get subtitleStyle => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodyStyle => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get labelStyle => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  // ── Themes ────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: bgLight,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: radiusMedium,
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radiusMedium,
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radiusMedium,
            borderSide: const BorderSide(color: primaryLight, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryLight,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: bgDark,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardDark,
          border: OutlineInputBorder(
            borderRadius: radiusMedium,
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radiusMedium,
            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radiusMedium,
            borderSide: const BorderSide(color: accent, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      );
}
