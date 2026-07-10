import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design system "Stitch v2" — paleta quente (chocolate/laranja) sobre
/// fundo creme, tipografia Manrope (títulos/labels) + Be Vietnam Pro (corpo).
class AppTheme {
  // Brand colors — Stitch v2 Design System
  static const Color primaryColor = Color(0xFF0B0301);
  static const Color primaryContainer = Color(0xFF2A1A15);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF998079);

  static const Color secondaryColor = Color(0xFFA04100);
  static const Color secondaryContainer = Color(0xFFFE6B00);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF572000);

  static const Color tertiaryColor = Color(0xFF040505);
  static const Color tertiaryContainer = Color(0xFF1E1E1E);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF878685);

  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color background = Color(0xFFFFF8F6);
  static const Color onBackground = Color(0xFF1E1B1A);

  static const Color surface = Color(0xFFFFF8F6);
  static const Color surfaceDim = Color(0xFFDFD9D7);
  static const Color surfaceBright = Color(0xFFFFF8F6);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF9F2F0);
  static const Color surfaceContainer = Color(0xFFF4ECEA);
  static const Color surfaceContainerHigh = Color(0xFFEEE7E5);
  static const Color surfaceContainerHighest = Color(0xFFE8E1DF);
  static const Color surfaceVariant = Color(0xFFE8E1DF);
  static const Color onSurface = Color(0xFF1E1B1A);
  static const Color onSurfaceVariant = Color(0xFF4F4441);

  static const Color outline = Color(0xFF817471);
  static const Color outlineVariant = Color(0xFFD3C3BF);
  static const Color inverseSurface = Color(0xFF33302F);
  static const Color inverseOnSurface = Color(0xFFF6EFED);
  static const Color inversePrimary = Color(0xFFDDC0B8);
  static const Color surfaceTint = Color(0xFF705953);

  /// Verde semântico para lucro/sucesso (não faz parte da paleta Stitch,
  /// mantido como acento funcional sobre o fundo creme).
  static const Color successColor = Color(0xFF2E7D4F);

  /// Acento usado em dark mode onde o marrom quase-preto do primary
  /// ficaria pouco visível — deriva do secondary_container (laranja).
  static const Color accentWarm = Color(0xFFFFB784);

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
      tertiary: tertiaryColor,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: errorColor,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceDim: surfaceDim,
      surfaceBright: surfaceBright,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
      surfaceTint: surfaceTint,
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData get darkTheme {
    // Esquema escuro derivado dos tokens "fixed"/"inverse" da paleta Stitch v2,
    // mantendo a mesma identidade de marca em telas com brilho reduzido.
    const colorScheme = ColorScheme.dark(
      primary: inversePrimary,
      onPrimary: Color(0xFF2A1A15),
      primaryContainer: Color(0xFF3D2B25),
      onPrimaryContainer: Color(0xFFFADCD3),
      secondary: Color(0xFFFFB693),
      onSecondary: Color(0xFF351000),
      secondaryContainer: Color(0xFF7A3000),
      onSecondaryContainer: Color(0xFFFFDBCC),
      tertiary: Color(0xFFC8C6C5),
      onTertiary: Color(0xFF1B1C1B),
      tertiaryContainer: Color(0xFF474746),
      onTertiaryContainer: Color(0xFFE4E2E1),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: errorContainer,
      surface: onSurface,
      onSurface: surfaceContainerHighest,
      surfaceContainerHighest: inverseSurface,
      onSurfaceVariant: outlineVariant,
      outline: Color(0xFF9C8F8C),
      outlineVariant: onSurfaceVariant,
      inverseSurface: surfaceContainerHighest,
      onInverseSurface: onSurface,
      inversePrimary: primaryColor,
      surfaceTint: inversePrimary,
    );
    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final onSurfaceColor = colorScheme.onSurface;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: TextTheme(
        // display-lg
        displayLarge: GoogleFonts.manrope(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            height: 1.2,
            color: onSurfaceColor),
        // headline-md
        headlineLarge: GoogleFonts.manrope(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: onSurfaceColor),
        headlineMedium: GoogleFonts.manrope(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: onSurfaceColor),
        // headline-sm
        headlineSmall: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: onSurfaceColor),
        titleLarge: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: onSurfaceColor),
        titleMedium: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: onSurfaceColor),
        // body-lg
        bodyLarge: GoogleFonts.beVietnamPro(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.6,
            color: onSurfaceColor),
        // body-md
        bodyMedium: GoogleFonts.beVietnamPro(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: onSurfaceColor),
        bodySmall: GoogleFonts.beVietnamPro(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: colorScheme.onSurfaceVariant),
        // label-bold
        labelLarge: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: onSurfaceColor),
        // label-sm
        labelMedium: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: colorScheme.onSurfaceVariant),
        labelSmall: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: colorScheme.onSurfaceVariant),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        side: BorderSide(color: colorScheme.outlineVariant),
        labelStyle: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        shape: const StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.surfaceContainerHighest,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        elevation: 2,
        extendedTextStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: GoogleFonts.beVietnamPro(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.outlineVariant,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerColor: colorScheme.outlineVariant,
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? colorScheme.secondaryContainer
              : colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? colorScheme.secondaryContainer.withValues(alpha: 0.4)
              : colorScheme.surfaceContainerHighest;
        }),
      ),
    );
  }
}
