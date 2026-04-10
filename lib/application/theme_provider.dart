import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/theme.dart';
import '../core/theme_world_names.dart';
import 'player_provider.dart';

/// The currently selected theme key (e.g., 'sky_heroes').
final selectedThemeProvider = Provider<String>((ref) {
  final profile = ref.watch(currentProfileProvider);
  return profile?.selectedTheme ?? 'enchanted_kingdom';
});

/// The active color palette based on selected theme.
final themePaletteProvider = Provider<ThemePalette>((ref) {
  final themeKey = ref.watch(selectedThemeProvider);
  return AppTheme.paletteFor(themeKey);
});

/// The active ThemeData based on selected theme.
final themeDataProvider = Provider<ThemeData>((ref) {
  final palette = ref.watch(themePaletteProvider);
  return AppTheme.themeFromPalette(palette);
});

/// Get the themed world name for a world index.
final themedWorldNameProvider =
    Provider.family<String, int>((ref, worldIndex) {
  final themeKey = ref.watch(selectedThemeProvider);
  return getThemedWorldName(themeKey, worldIndex);
});

/// Theme display names for the UI.
const themeDisplayNames = {
  'sky_heroes': 'Sky Heroes',
  'enchanted_kingdom': 'Enchanted Kingdom',
  'explorer_quest': 'Explorer Quest',
};

/// Get display name for a theme key.
String themeDisplayName(String themeKey) {
  return themeDisplayNames[themeKey] ?? 'Enchanted Kingdom';
}
