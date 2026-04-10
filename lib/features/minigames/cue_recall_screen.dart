import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/theme.dart';
import '../../application/session_provider.dart';
import '../../app/router.dart';

class CueRecallScreen extends ConsumerStatefulWidget {
  const CueRecallScreen({super.key});

  @override
  ConsumerState<CueRecallScreen> createState() => _CueRecallScreenState();
}

class _CueRecallScreenState extends ConsumerState<CueRecallScreen> {
  int? _selectedIndex;

  static const List<double> _rotations = [-0.015, 0.02, -0.01];

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    final question = sessionState.currentQuestion;
    final choices = question?.choices ?? [];

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back_rounded,
                        color: AppTheme.onSurface),
                  ),
                  Expanded(
                    child: Text(
                      'Vocoro',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(Icons.star_rounded,
                      color: AppTheme.secondaryContainer, size: 22),
                  SizedBox(width: 4),
                  Text(
                    '1,240',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Label
            Text(
              'RECALL CHALLENGE',
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondary,
                letterSpacing: 1.2,
              ),
            ),

            SizedBox(height: 12),

            // Heading
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Which word fits the cue?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 24),

            // Cue card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EDF2),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          size: 48, color: AppTheme.secondary),
                      SizedBox(height: 16),
                      // Cue prompt text
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          question?.prompt ?? 'Word',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Soundwave bars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(7, (index) {
                          final heights = [12.0, 20.0, 32.0, 40.0, 32.0, 20.0, 12.0];
                          return Container(
                            width: 6,
                            height: heights[index],
                            margin: EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 28),

            // Word options
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 24),
                itemCount: choices.length,
                separatorBuilder: (c, i) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () async {
                      setState(() => _selectedIndex = index);
                      await ref
                          .read(sessionProvider.notifier)
                          .submitAnswer(index);

                      await Future.delayed(const Duration(milliseconds: 600));
                      if (!mounted) return;

                      final session = ref.read(sessionProvider);
                      if (session.isQuizzing &&
                          session.currentQuestion != null) {
                        context.go(routeForQuestionType(
                            session.currentQuestion!.type.name));
                      } else {
                        context.go('/level_complete');
                      }
                    },
                    child: Transform.rotate(
                      angle: index < _rotations.length
                          ? _rotations[index]
                          : 0.0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.surfaceContainerHigh,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                choices[index],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppTheme.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.surfaceContainerHigh,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(Icons.check,
                                      size: 16, color: Colors.white)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom nav bar
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 'Home'),
          _navItem(Icons.map_rounded, 'Map'),
          _navItem(Icons.emoji_events_rounded, 'Vault'),
          _navItem(Icons.settings_rounded, 'Settings'),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.onSurface.withValues(alpha: 0.5), size: 24),
        SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 11,
            color: AppTheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
