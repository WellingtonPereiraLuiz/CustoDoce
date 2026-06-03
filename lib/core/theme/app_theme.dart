import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Shared brand colors
  static const Color primaryColor = Color(0xFFE8A020);
  static const Color primaryDark = Color(0xFFC47C0A);
  static const Color errorColor = Color(0xFFCF6679);
  static const Color successColor = Color(0xFF4CAF82);

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2A2A2A);
  static const Color onSurfaceDark = Color(0xFFE8E0D5);
  static const Color cardGradientStart = Color(0xFF2A2218);
  static const Color cardGradientEnd = Color(0xFF1E1E1E);

  // Light theme colors
  static const Color backgroundLight = Color(0xFFF7F3EE);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF0EBE3);
  static const Color onSurfaceLight = Color(0xFF1A1512);

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
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: onSurfaceDark,
        displayColor: onSurfaceDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: onSurfaceDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
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
          textStyle: GoogleFonts.outfit(
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
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: onSurfaceLight,
        displayColor: onSurfaceLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        foregroundColor: onSurfaceLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: onSurfaceLight,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceVariantLight,
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
        fillColor: surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: onSurfaceLight.withAlpha(150)),
        hintStyle: TextStyle(color: onSurfaceLight.withAlpha(100)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
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
