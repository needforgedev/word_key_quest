import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/theme.dart';
import '../../application/session_provider.dart';
import '../../application/service_providers.dart';
import '../../app/router.dart';
import '../../core/word_image_helper.dart';
import '../../data/models/models.dart';

class MemoryKeyFocusScreen extends ConsumerWidget {
  const MemoryKeyFocusScreen({super.key});

  static const String _fallbackImageUrl =
      'assets/images/image_6bdcae67.jpg';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);
    final word = sessionState.currentLearnWord;
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            _buildProgressBar(context),
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey('mkf_${word?.id ?? ''}'),
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 20),
                    _buildMemoryKeyBadge(),
                    SizedBox(height: 12),
                    _buildWordTitle(context, word),
                    // Pronunciation + cue type
                    if (word != null)
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            if (word.pronunciation.isNotEmpty)
                              Text(
                                '/${word.pronunciation}/',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            if (word.pronunciation.isNotEmpty && word.cueType.isNotEmpty)
                              SizedBox(width: 10),
                            if (word.cueType.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryContainer.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Cue: ${word.cueType}',
                                  style: GoogleFonts.lexend(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.secondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    SizedBox(height: 20),
                    _buildImageWithOverlay(word),
                    SizedBox(height: 24),
                    _buildStoryCard(context, ref, word),
                    SizedBox(height: 24),
                    _buildDidYouNoticeSection(context, word),
                    SizedBox(height: 32),
                    _buildGotItButton(context, ref),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            color: AppTheme.onSurface,
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Text(
              'Vocoro',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Icon(Icons.star_rounded, color: AppTheme.secondaryContainer, size: 28),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(5),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: 0.75,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: LinearGradient(
                colors: [AppTheme.secondary, AppTheme.secondaryContainer],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemoryKeyBadge() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'MEMORY KEY',
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildWordTitle(BuildContext context, WordEntry? word) {
    return Text(
      word?.word ?? 'Word',
      style: GoogleFonts.plusJakartaSans(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: AppTheme.onSurface,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildImageWithOverlay(WordEntry? word) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              (word != null && WordImageHelper.hasImage(word.id))
                  ? WordImageHelper.getImagePath(word.id)!
                  : _fallbackImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.surfaceContainerHigh,
                  child: Center(
                    child: Icon(Icons.castle_rounded, size: 64, color: AppTheme.primaryDim),
                  ),
                );
              },
            ),
            Container(
              color: Colors.black.withValues(alpha:0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, WidgetRef ref, WordEntry? word) {
    return Transform.rotate(
      angle: -1 * math.pi / 180,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.volume_up_rounded,
                    size: 22,
                    color: AppTheme.primary,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    word?.memoryKey ?? 'Loading memory key...',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.onSurface,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: AppTheme.secondaryContainer,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    if (word != null) {
                      ref.read(ttsServiceProvider).speakMemoryKey(word.memoryKey);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.replay_rounded, size: 18, color: AppTheme.secondary),
                        SizedBox(width: 6),
                        Text(
                          'Replay Audio',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ],
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

  Widget _buildDidYouNoticeSection(BuildContext context, WordEntry? word) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceContainerHigh, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer.withValues(alpha:0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              size: 24,
              color: AppTheme.secondary,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Did you notice?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  word != null
                      ? 'The cue "${word.cue}" helps you remember "${word.word}". ${word.kidsMeaning}.'
                      : 'Think about the cue to remember the word!',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.onSurface.withValues(alpha:0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGotItButton(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDim,
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
        onPressed: () async {
          // Advance to next learn card (marks current word as introduced)
          await ref.read(sessionProvider.notifier).advanceLearnCard();
          if (!context.mounted) return;

          final session = ref.read(sessionProvider);
          if (session.isLearning) {
            // More words to learn — go back to learn card
            context.go('/learn_card');
          } else if (session.isQuizzing) {
            // Learn phase done — navigate to first mini-game
            final question = session.currentQuestion;
            if (question != null) {
              context.go(routeForQuestionType(question.type.name));
            } else {
              context.go('/level_complete');
            }
          } else {
            context.go('/home');
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_rounded, size: 22),
            SizedBox(width: 8),
            Text(
              'Got It!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
