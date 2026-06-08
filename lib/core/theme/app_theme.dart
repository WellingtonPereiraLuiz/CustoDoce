import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Shared brand colors
  static const Color primaryColor = Color(0xFF4E342E);
  static const Color primaryDark = Color(0xFF361F1A);
  static const Color errorColor = Color(0xFFCF6679);
  static const Color successColor = Color(0xFF4CAF82);

  // Dark theme colors (Lighter, warmer dark mode - Chocolate/Espresso vibe)
  static const Color backgroundDark = Color(0xFF1E1A18);
  static const Color surfaceDark = Color(0xFF282320);
  static const Color surfaceVariantDark = Color(0xFF352E2B);
  static const Color onSurfaceDark = Color(0xFFF2EAE1);
  static const Color cardGradientStart = Color(0xFF352E2B);
  static const Color cardGradientEnd = Color(0xFF282320);

  // Light theme colors (Better contrast)
  static const Color backgroundLight = Color(0xFFFFF8F6);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F0E6);
  static const Color onSurfaceLight = Color(0xFF2C2420); // Darker brown/black for text

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryDark,
        surface: surfaceDark,
        error: errorColor,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: onSurfaceDark,
      ),
      scaffoldBackgroundColor: Colors.black,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.sourceSerif4(fontWeight: FontWeight.w600, color: onSurfaceDark),
        headlineMedium: GoogleFonts.sourceSerif4(fontWeight: FontWeight.w600, color: onSurfaceDark),
        titleLarge: GoogleFonts.sourceSerif4(color: onSurfaceDark),
        bodyLarge: GoogleFonts.workSans(color: onSurfaceDark),
        bodyMedium: GoogleFonts.workSans(color: onSurfaceDark),
        labelLarge: GoogleFonts.workSans(fontWeight: FontWeight.w500, color: onSurfaceDark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: onSurfaceDark,
        elevation: 0,
        centerTitle: false,
          titleTextStyle: GoogleFonts.sourceSerif4(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: onSurfaceDark,
          ),
      ),
      cardTheme: CardThemeData(
        color: surfaceVariantDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariantDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        hintStyle: const TextStyle(color: Color(0xFF616161)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.workSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerColor: const Color(0xFF2A2A2A),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceVariantDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryDark,
        surface: surfaceLight,
        error: errorColor,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: onSurfaceLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.sourceSerif4(fontWeight: FontWeight.w600, color: onSurfaceLight),
        headlineMedium: GoogleFonts.sourceSerif4(fontWeight: FontWeight.w600, color: onSurfaceLight),
        titleLarge: GoogleFonts.sourceSerif4(color: onSurfaceLight),
        bodyLarge: GoogleFonts.workSans(color: onSurfaceLight),
        bodyMedium: GoogleFonts.workSans(color: onSurfaceLight),
        labelLarge: GoogleFonts.workSans(fontWeight: FontWeight.w500, color: onSurfaceLight),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        foregroundColor: onSurfaceLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.sourceSerif4(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: onSurfaceLight,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2DCD3), width: 1),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: onSurfaceLight.withValues(alpha: 0.6)),
        hintStyle: TextStyle(color: onSurfaceLight.withValues(alpha: 0.4)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.workSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerColor: const Color(0xFFE0D8CE),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
