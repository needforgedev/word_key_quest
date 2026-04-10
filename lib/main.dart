import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme/theme.dart';
import 'application/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VocoroApp()));
}

class VocoroApp extends ConsumerWidget {
  const VocoroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the active palette and apply to static AppTheme fields
    final palette = ref.watch(themePaletteProvider);
    AppTheme.applyPalette(palette);

    // Build ThemeData from the same palette
    final themeData = ref.watch(themeDataProvider);

    return MaterialApp.router(
      title: 'Vocoro',
      theme: themeData,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
