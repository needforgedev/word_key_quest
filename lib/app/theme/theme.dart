import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color palette for a single theme pack.
class ThemePalette {
  final Color primary;
  final Color primaryDim;
  final Color primaryContainer;
  final Color secondary;
  final Color secondaryContainer;
  final Color surface;
  final Color surfaceContainerLow;
  final Color surfaceContainerHigh;
  final Color surfaceContainerLowest;
  final Color onSurface;
  final Color errorContainer;
  final Color heroGradientTop;

  const ThemePalette({
    required this.primary,
    required this.primaryDim,
    required this.primaryContainer,
    required this.secondary,
    required this.secondaryContainer,
    required this.surface,
    required this.surfaceContainerLow,
    required this.surfaceContainerHigh,
    required this.surfaceContainerLowest,
    required this.onSurface,
    required this.errorContainer,
    required this.heroGradientTop,
  });
}

class AppTheme {
  // ═══════════════════════════════════════════════════════
  // Active palette — mutable, updated via applyPalette()
  // All existing AppTheme.primary etc. references read from here.
  // ═══════════════════════════════════════════════════════
  static Color surface = const Color(0xFFFDF6E3);
  static Color surfaceContainerLow = const Color(0xFFF8F0DC);
  static Color surfaceContainerHigh = const Color(0xFFEAE2CB);
  static Color surfaceContainerLowest = const Color(0xFFFFFFFF);
  static Color onSurface = const Color(0xFF322F22);

  static Color primary = const Color(0xFF2A6900);
  static Color primaryDim = const Color(0xFF235B00);
  static Color primaryContainer = const Color(0xFF84FB42);

  static Color secondary = const Color(0xFF755700);
  static Color secondaryContainer = const Color(0xFFFFCA4D);
  static Color errorContainer = const Color(0xFFF95630);

  /// Apply a palette to the global static colors.
  /// Call this when the player's theme changes.
  static void applyPalette(ThemePalette p) {
    primary = p.primary;
    primaryDim = p.primaryDim;
    primaryContainer = p.primaryContainer;
    secondary = p.secondary;
    secondaryContainer = p.secondaryContainer;
    surface = p.surface;
    surfaceContainerLow = p.surfaceContainerLow;
    surfaceContainerHigh = p.surfaceContainerHigh;
    surfaceContainerLowest = p.surfaceContainerLowest;
    onSurface = p.onSurface;
    errorContainer = p.errorContainer;
  }

  // ═══════════════════════════════════════════════════════
  // Three Theme Palettes
  // ═══════════════════════════════════════════════════════

  static const enchantedKingdom = ThemePalette(
    primary: Color(0xFF2A6900),
    primaryDim: Color(0xFF235B00),
    primaryContainer: Color(0xFF84FB42),
    secondary: Color(0xFF755700),
    secondaryContainer: Color(0xFFFFCA4D),
    surface: Color(0xFFFDF6E3),
    surfaceContainerLow: Color(0xFFF8F0DC),
    surfaceContainerHigh: Color(0xFFEAE2CB),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    onSurface: Color(0xFF322F22),
    errorContainer: Color(0xFFF95630),
    heroGradientTop: Color(0xFF66B6FF),
  );

  static const skyHeroes = ThemePalette(
    primary: Color(0xFF1565C0),
    primaryDim: Color(0xFF0D47A1),
    primaryContainer: Color(0xFF90CAF9),
    secondary: Color(0xFFF9A825),
    secondaryContainer: Color(0xFFFFD54F),
    surface: Color(0xFFF0F4FA),
    surfaceContainerLow: Color(0xFFE3EAF5),
    surfaceContainerHigh: Color(0xFFCDD8E8),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A2233),
    errorContainer: Color(0xFFE53935),
    heroGradientTop: Color(0xFF42A5F5),
  );

  static const explorerQuest = ThemePalette(
    primary: Color(0xFFE65100),
    primaryDim: Color(0xFFBF360C),
    primaryContainer: Color(0xFFFFAB91),
    secondary: Color(0xFF00695C),
    secondaryContainer: Color(0xFF80CBC4),
    surface: Color(0xFFFFF8E1),
    surfaceContainerLow: Color(0xFFFFF0C2),
    surfaceContainerHigh: Color(0xFFEDE0B8),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    onSurface: Color(0xFF33261A),
    errorContainer: Color(0xFFD32F2F),
    heroGradientTop: Color(0xFFFFB74D),
  );

  /// Get palette by theme key.
  static ThemePalette paletteFor(String themeKey) {
    switch (themeKey) {
      case 'sky_heroes':
        return skyHeroes;
      case 'explorer_quest':
        return explorerQuest;
      case 'enchanted_kingdom':
      default:
        return enchantedKingdom;
    }
  }

  // ═══════════════════════════════════════════════════════
  // Theme builders
  // ═══════════════════════════════════════════════════════

  /// Default theme (Enchanted Kingdom).
  static ThemeData get lightTheme => themeFromPalette(enchantedKingdom);

  /// Build a ThemeData from a palette.
  static ThemeData themeFromPalette(ThemePalette p) {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: p.primary,
        secondary: p.secondary,
        surface: p.surface,
        onSurface: p.onSurface,
        error: p.errorContainer,
        primaryContainer: p.primaryContainer,
        secondaryContainer: p.secondaryContainer,
      ),
      scaffoldBackgroundColor: p.surface,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 56,
          letterSpacing: -0.02,
          fontWeight: FontWeight.bold,
          color: p.onSurface,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          letterSpacing: -0.02,
          fontWeight: FontWeight.bold,
          color: p.onSurface,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          letterSpacing: -0.02,
          fontWeight: FontWeight.bold,
          color: p.onSurface,
        ),
        bodyLarge: GoogleFonts.lexend(fontSize: 16, color: p.onSurface),
        bodyMedium: GoogleFonts.lexend(fontSize: 14, color: p.onSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          minimumSize: const Size(double.infinity, 64),
          elevation: 0,
        ),
      ),
      useMaterial3: true,
    );
  }
}
