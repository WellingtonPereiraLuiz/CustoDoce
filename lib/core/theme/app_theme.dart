import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors from Artisanal Ledger Design System
  static const Color primaryColor = Color(0xFF1E0A07);
  static const Color primaryContainer = Color(0xFF361F1A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFA7847D);

  static const Color secondaryColor = Color(0xFF6B5A60);
  static const Color secondaryContainer = Color(0xFFF1DAE1);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF6F5E64);

  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color background = Color(0xFFFFF8F6);
  static const Color onBackground = Color(0xFF1E1B1A);

  static const Color surface = Color(0xFFFFF8F6);
  static const Color surfaceVariant = Color(0xFFE9E1DF);
  static const Color onSurface = Color(0xFF1E1B1A);
  static const Color onSurfaceVariant = Color(0xFF504442);

  static const Color outline = Color(0xFF827471);
  static const Color outlineVariant = Color(0xFFD4C3BF);

  static const Color successColor = Color(0xFF4CAF82);

  /// Cor de acento usada em dark mode onde primaryColor seria invisível
  static const Color accentWarm = Color(0xFFE5BEB6);

  // Fallbacks for direct access where theme is not easily accessible
  static const Color surfaceLight = surface;
  static const Color surfaceDark = Color(0xFF1E1B1A);
  static const Color surfaceVariantLight = surfaceVariant;
  static const Color surfaceVariantDark = Color(0xFF33302F);

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondaryColor,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      error: errorColor,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      tertiary: Color(0xFF4A7B6F),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF132924),
      onTertiaryContainer: Color(0xFF7A918A),
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFFE5BEB6),
      onPrimary: Color(0xFF1E0A07),
      primaryContainer: Color(0xFF361F1A),
      onPrimaryContainer: Color(0xFFA7847D),
      secondary: Color(0xFFD7C1C8),
      onSecondary: Color(0xFF24181D),
      secondaryContainer: Color(0xFF524348),
      onSecondaryContainer: Color(0xFFF1DAE1),
      surface: Color(0xFF1E1B1A),
      onSurface: Color(0xFFFFF8F6),
      surfaceContainerHighest: Color(0xFF33302F),
      onSurfaceVariant: Color(0xFFE9E1DF),
      outline: Color(0xFF827471),
      outlineVariant: Color(0xFF504442),
      tertiary: Color(0xFFB3CCC4),
      onTertiary: Color(0xFF091F1B),
      tertiaryContainer: Color(0xFF354B45),
      onTertiaryContainer: Color(0xFFCFE8E0),
    );
    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.sourceSerif4(
            fontSize: 57,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.02,
            color: colorScheme.onSurface),
        headlineLarge: GoogleFonts.sourceSerif4(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface),
        headlineMedium: GoogleFonts.sourceSerif4(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface),
        headlineSmall: GoogleFonts.sourceSerif4(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface),
        titleLarge: GoogleFonts.workSans(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface),
        bodyLarge: GoogleFonts.workSans(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface),
        bodyMedium: GoogleFonts.workSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface),
        labelLarge: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: colorScheme.onSurface),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.sourceSerif4(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primaryContainer, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
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
      dividerColor: colorScheme.outlineVariant,
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
