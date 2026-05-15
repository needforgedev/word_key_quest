import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/theme.dart';
import '../../application/session_provider.dart';
import '../../application/player_provider.dart';
import '../../app/router.dart';
import '../../data/models/models.dart';

class MeaningTapScreen extends ConsumerStatefulWidget {
  const MeaningTapScreen({super.key});

  @override
  ConsumerState<MeaningTapScreen> createState() => _MeaningTapScreenState();
}

class _MeaningTapScreenState extends ConsumerState<MeaningTapScreen> {
  int? _selectedIndex;

  static const List<IconData> _optionIcons = [
    Icons.castle_rounded,
    Icons.cruelty_free_rounded,
    Icons.eco_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    final question = sessionState.currentQuestion;
    final profile = ref.watch(currentProfileProvider);

    // Safety guard: if the current question is for a different mini-game,
    // redirect to the correct screen so we never render word IDs as text.
    if (question != null &&
        question.type != QuestionType.meaningTap &&
        sessionState.isQuizzing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(routeForQuestionType(question.type.name));
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }

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
                    onPressed: () {
                      ref.read(sessionProvider.notifier).abandonSession();
                      context.go('/home');
                    },
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
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Level ${profile?.globalLevel ?? 1}',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.star_rounded,
                      color: AppTheme.secondaryContainer, size: 28),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: ClipRRect(
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
            ),

            SizedBox(height: 16),

            // Label
            Text(
              'FIND THE MEANING',
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondary,
                letterSpacing: 1.2,
              ),
            ),

            SizedBox(height: 8),

            // Word in rotated container
            Transform.rotate(
              angle: -0.02,
              child: Text(
                question?.prompt ?? 'Word',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ),

            SizedBox(height: 24),

            // Option buttons
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 24),
                itemCount: choices.length,
                separatorBuilder: (c, i) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final choiceText = choices[index];
                  final icon = _optionIcons[index % _optionIcons.length];
                  final isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () async {
                      setState(() => _selectedIndex = index);
                      await ref
                          .read(sessionProvider.notifier)
                          .submitAnswer(index);

                      // Brief delay for feedback animation
                      await Future.delayed(const Duration(milliseconds: 600));
                      if (!mounted) return;

                      final session = ref.read(sessionProvider);
                      if (session.isQuizzing &&
                          session.currentQuestion != null) {
                        // More questions -- navigate to the correct mini-game
                        context.go(routeForQuestionType(
                            session.currentQuestion!.type.name));
                      } else {
                        // Quiz done -- go to level complete
                        context.go('/level_complete');
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(18),
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
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(icon,
                              size: 28,
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.secondary),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              choiceText,
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
