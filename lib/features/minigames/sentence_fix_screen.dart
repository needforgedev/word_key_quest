import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/theme.dart';
import '../../application/session_provider.dart';
import '../../app/router.dart';

class SentenceFixScreen extends ConsumerStatefulWidget {
  const SentenceFixScreen({super.key});

  @override
  ConsumerState<SentenceFixScreen> createState() => _SentenceFixScreenState();
}

class _SentenceFixScreenState extends ConsumerState<SentenceFixScreen> {
  int? _selectedIndex;

  static const String _palaceImageUrl =
      'assets/images/image_d4adfa39.jpg';

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
                      'Word Key Quest',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(Icons.vpn_key_rounded,
                      color: AppTheme.secondaryContainer, size: 22),
                  SizedBox(width: 6),
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

            SizedBox(height: 8),

            // Quest progress label and bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'QUEST PROGRESS',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '${sessionState.questionNumber}/${sessionState.totalQuestions}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 12,
                      child: Stack(
                        children: [
                          Container(color: AppTheme.surfaceContainerHigh),
                          FractionallySizedBox(
                            widthFactor: sessionState.quizProgress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primary,
                                    AppTheme.primaryContainer,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Image card with sentence overlay
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Image.asset(
                      _palaceImageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, st) => Container(
                        height: 220,
                        width: double.infinity,
                        color: AppTheme.surfaceContainerHigh,
                        child: Icon(Icons.image,
                            size: 48, color: Colors.black26),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.75),
                              Colors.black.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                        child: Text(
                          question?.prompt ?? 'The king lived in a _______ palace.',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 28),

            // Word options
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: List.generate(choices.length, (index) {
                  final isSelected = _selectedIndex == index;
                  // First option is the correct/highlighted one
                  final isCorrectAndSelected = isSelected && index == 0;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 6,
                        right: index == choices.length - 1 ? 0 : 6,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          setState(() => _selectedIndex = index);
                          await ref
                              .read(sessionProvider.notifier)
                              .submitAnswer(index);

                          await Future.delayed(
                              const Duration(milliseconds: 600));
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
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 18, horizontal: 12),
                          decoration: BoxDecoration(
                            color: isCorrectAndSelected
                                ? AppTheme.primary
                                : isSelected
                                    ? AppTheme.surfaceContainerLow
                                    : AppTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? (isCorrectAndSelected
                                      ? AppTheme.primaryDim
                                      : AppTheme.surfaceContainerHigh)
                                  : AppTheme.surfaceContainerHigh,
                              width: isSelected ? 2 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            choices[index],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCorrectAndSelected
                                  ? Colors.white
                                  : AppTheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const Spacer(),

            // Hint
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lightbulb_outline_rounded,
                      size: 20, color: AppTheme.secondary.withValues(alpha: 0.7)),
                  SizedBox(width: 8),
                  Text(
                    'Tap the best word to fix the sentence!',
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      color: AppTheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
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
