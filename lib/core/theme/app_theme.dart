import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgObsidian = Color(0xFF0E0D13);
  static const Color surfaceDark = Color(0xFF1A1726);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color textPrimary = Color(0xFFF3EFE6);
  static const Color textMuted = Color(0xFFA09CB0);
  static const Color borderSubtle = Color(0xFF2E2942);

  static ThemeData get darkTheme {
    final interFont = GoogleFonts.inter().fontFamily;
    final cinzelFont = GoogleFonts.cinzel().fontFamily;

    final baseTextTheme = ThemeData.dark().textTheme.apply(
      fontFamily: interFont,
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgObsidian,
      colorScheme: const ColorScheme.dark(
        primary: accentGold,
        secondary: Color(0xFF7B61FF),
        surface: surfaceDark,
        onPrimary: bgObsidian,
        onSurface: textPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: TextStyle(
          fontFamily: cinzelFont,
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontFamily: cinzelFont,
          color: accentGold,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          fontFamily: cinzelFont,
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgObsidian,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: cinzelFont,
          color: accentGold,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: accentGold),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        hintStyle: const TextStyle(color: textMuted),
        prefixIconColor: accentGold,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentGold, width: 1.5),
        ),
      ),
    );
  }
}
