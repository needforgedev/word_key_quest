import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/theme.dart';
import '../../application/session_provider.dart';
import '../../application/service_providers.dart';
import '../../app/router.dart';
import '../../core/word_image_helper.dart';

class ImageMatchScreen extends ConsumerStatefulWidget {
  const ImageMatchScreen({super.key});

  @override
  ConsumerState<ImageMatchScreen> createState() => _ImageMatchScreenState();
}

class _ImageMatchScreenState extends ConsumerState<ImageMatchScreen> {
  int? _selectedIndex;

  /// Random fallback images from our available word images.
  /// Used when a distractor word doesn't have its own image.
  List<String> _fallbackImages = [];

  @override
  void initState() {
    super.initState();
    _generateFallbackImages();
  }

  void _generateFallbackImages() {
    // Pick random images from available word images for fallback
    final allPaths = WordImageHelper.allAvailablePaths;
    final rng = Random();
    final shuffled = [...allPaths]..shuffle(rng);
    _fallbackImages = shuffled.take(4).toList();
  }

  /// Get image path for a choice, with random fallback from available images.
  String _getImageForChoice(String wordId, int index) {
    final realPath = WordImageHelper.getImagePath(wordId);
    if (realPath != null) return realPath;
    // Use a random available image as fallback
    return _fallbackImages[index % _fallbackImages.length];
  }

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

            SizedBox(height: 12),

            // Label
            Text(
              'FIND THE IMAGE THAT IS',
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondary,
                letterSpacing: 1.2,
              ),
            ),

            SizedBox(height: 4),

            // Word
            Text(
              question?.prompt ?? 'Word',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),

            SizedBox(height: 8),

            // Hear Word button
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.surfaceContainerHigh),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up_rounded,
                      size: 20, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Text(
                    'Hear Word',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // 2x2 Image grid
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: choices.length > 4 ? 4 : choices.length,
                  itemBuilder: (context, index) {
                    final wordId = choices[index];
                    final isSelected = _selectedIndex == index;
                    final imagePath = _getImageForChoice(wordId, index);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.surfaceContainerHigh,
                            width: isSelected ? 3 : 1.5,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color:
                                    AppTheme.primary.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              )
                            else
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Square word image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox.expand(
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppTheme.surfaceContainerHigh,
                                    child: Icon(Icons.image_rounded,
                                        size: 40,
                                        color: AppTheme.primaryDim),
                                  ),
                                ),
                              ),
                            ),
                            // Selection indicator (top-right)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppTheme.primary
                                      : Colors.white.withValues(alpha: 0.85),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : AppTheme.surfaceContainerHigh,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: isSelected
                                    ? Icon(Icons.check,
                                        size: 16, color: Colors.white)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Check Answer button
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedIndex != null
                      ? () async {
                          final selectedIdx = _selectedIndex!;
                          await ref
                              .read(sessionProvider.notifier)
                              .submitAnswer(selectedIdx);

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
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.surfaceContainerHigh,
                    disabledForegroundColor:
                        AppTheme.onSurface.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'CHECK ANSWER',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
