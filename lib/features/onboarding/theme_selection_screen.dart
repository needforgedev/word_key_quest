import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/theme.dart';
import '../../application/player_provider.dart';

class _ThemeOption {
  final String name;
  final String description;
  final String imageUrl;
  final Color accentColor;

  const _ThemeOption({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.accentColor,
  });
}

final _themes = [
  _ThemeOption(
    name: 'Sky Heroes',
    description:
        'Soar through the clouds and discover words among floating islands.',
    imageUrl:
        'assets/images/image_4190f288.jpg',
    accentColor: const Color(0xFF2196F3),
  ),
  _ThemeOption(
    name: 'Enchanted Kingdom',
    description:
        'Enter a realm of magic, forests and talking beasts to discover hidden keys.',
    imageUrl:
        'assets/images/image_1ccc74d5.jpg',
    accentColor: const Color(0xFF9C27B0),
  ),
  _ThemeOption(
    name: 'Explorer Quest',
    description:
        'Chart your course through uncharted lands and find hidden word keys.',
    imageUrl:
        'assets/images/image_252fd04b.jpg',
    accentColor: const Color(0xFFFF9800),
  ),
];

class ThemeSelectionScreen extends ConsumerStatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  ConsumerState<ThemeSelectionScreen> createState() =>
      _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends ConsumerState<ThemeSelectionScreen> {
  int _selectedIndex = 1; // Enchanted Kingdom default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Choose Your\nAdventure Theme!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onSurface,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pick a world to begin your word quest. Each theme unlocks unique treasures and hidden word keys.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        color: const Color(0xFF5F5B4D),
                      ),
                    ),
                    SizedBox(height: 24),
                    ...List.generate(_themes.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: _buildThemeCard(index),
                      );
                    }),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: AppTheme.primary),
          ),
          Text(
            'Word Key Quest',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(int index) {
    final theme = _themes[index];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppTheme.primary, width: 3)
              : Border.all(color: AppTheme.surfaceContainerHigh, width: 2),
          color: AppTheme.surfaceContainerLowest,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF322F22).withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      theme.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: theme.accentColor.withValues(alpha: 0.2),
                        child: Icon(Icons.landscape,
                            size: 48, color: theme.accentColor),
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'SELECTED',
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Text content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    theme.description,
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      color: const Color(0xFF5F5B4D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: GestureDetector(
        onTap: () async {
          // Map index to theme key
          const themeKeys = [
            'sky_heroes',
            'enchanted_kingdom',
            'explorer_quest',
          ];
          await ref
              .read(playerProvider.notifier)
              .updateTheme(themeKeys[_selectedIndex]);
          if (mounted) context.go('/home');
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryDim,
                blurRadius: 0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose Theme',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.check_circle, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
