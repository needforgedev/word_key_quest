import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/theme.dart';
import '../../application/session_provider.dart';
import '../../application/service_providers.dart';
import '../../core/word_image_helper.dart';
import '../../data/models/models.dart';

class LearnCardScreen extends ConsumerWidget {
  const LearnCardScreen({super.key});

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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8),
                    _buildWordHeader(context, ref, word),
                    // Pronunciation + Part of speech
                    if (word != null && (word.pronunciation.isNotEmpty || word.partOfSpeech.isNotEmpty))
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            if (word.pronunciation.isNotEmpty)
                              Text(
                                '/${word.pronunciation}/',
                                style: GoogleFonts.lexend(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            if (word.pronunciation.isNotEmpty && word.partOfSpeech.isNotEmpty)
                              SizedBox(width: 12),
                            if (word.partOfSpeech.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  word.partOfSpeech,
                                  style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    SizedBox(height: 12),
                    _buildNewWordKeyBadge(context),
                    SizedBox(height: 16),
                    _buildImageCard(word),
                    SizedBox(height: 16),
                    // Kids meaning
                    _buildMeaningText(context, word),
                    SizedBox(height: 8),
                    // Barron's meaning (formal)
                    if (word != null && word.barronsMeaning.isNotEmpty)
                      Text(
                        word.barronsMeaning,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: AppTheme.onSurface.withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    SizedBox(height: 16),
                    _buildDashedDivider(),
                    SizedBox(height: 16),
                    // Cue label
                    if (word != null && word.cue.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_rounded, size: 18, color: AppTheme.secondaryContainer),
                            SizedBox(width: 6),
                            Text(
                              'Cue: ',
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.secondary,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '"${word.cue}"',
                                style: GoogleFonts.lexend(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildMemoryKeySection(context),
                    SizedBox(height: 12),
                    _buildMemoryKeyText(context, word),
                    SizedBox(height: 16),
                    _buildHearMemoryKeyButton(context, ref, word),
                    SizedBox(height: 16),
                    // Synonyms & Antonyms
                    if (word != null && (word.synonyms.isNotEmpty || word.antonyms.isNotEmpty))
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            if (word.synonyms.isNotEmpty)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Synonyms',
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.onSurface.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: word.synonyms.map((s) => Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          s,
                                          style: GoogleFonts.lexend(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                      )).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            if (word.synonyms.isNotEmpty && word.antonyms.isNotEmpty)
                              SizedBox(width: 16),
                            if (word.antonyms.isNotEmpty)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Antonyms',
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.onSurface.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: word.antonyms.map((a) => Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.errorContainer.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          a,
                                          style: GoogleFonts.lexend(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.errorContainer,
                                          ),
                                        ),
                                      )).toList(),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    // Usage examples
                    if (word != null && (word.usage1Simple.isNotEmpty || word.usage2Standard.isNotEmpty))
                      Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.surfaceContainerHigh, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (word.usage1Simple.isNotEmpty)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.format_quote_rounded, size: 18, color: AppTheme.primary.withValues(alpha: 0.5)),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      word.usage1Simple,
                                      style: GoogleFonts.lexend(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: AppTheme.onSurface.withValues(alpha: 0.7),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (word.usage1Simple.isNotEmpty && word.usage2Standard.isNotEmpty)
                              SizedBox(height: 10),
                            if (word.usage2Standard.isNotEmpty)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.format_quote_rounded, size: 18, color: AppTheme.secondary.withValues(alpha: 0.5)),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      word.usage2Standard,
                                      style: GoogleFonts.lexend(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: AppTheme.onSurface.withValues(alpha: 0.7),
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    SizedBox(height: 24),
                    _buildNextButton(context),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
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
              'Word Key Quest',
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

  Widget _buildWordHeader(BuildContext context, WidgetRef ref, WordEntry? word) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            word?.word ?? 'Word',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        ),
        IconButton(
          iconSize: 36,
          color: AppTheme.primary,
          icon: Icon(Icons.volume_up_rounded),
          onPressed: () {
            if (word != null) {
              ref.read(ttsServiceProvider).speakWord(word.word);
            }
          },
        ),
      ],
    );
  }

  Widget _buildNewWordKeyBadge(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'NEW WORD KEY',
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

  Widget _buildImageCard(WordEntry? word) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 1,
        child: word != null && WordImageHelper.hasImage(word.id)
            ? Image.asset(
                WordImageHelper.getImagePath(word.id)!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
            : Image.asset(
                _fallbackImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.surfaceContainerHigh,
      child: Center(
        child: Icon(Icons.image_rounded, size: 64, color: AppTheme.primaryDim),
      ),
    );
  }

  Widget _buildMeaningText(BuildContext context, WordEntry? word) {
    return Text(
      word?.kidsMeaning ?? 'Loading meaning...',
      style: GoogleFonts.lexend(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: AppTheme.onSurface,
        height: 1.5,
      ),
    );
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final dashCount =
            (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1.5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHigh,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildMemoryKeySection(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.visibility_rounded, size: 20, color: AppTheme.secondary),
        SizedBox(width: 8),
        Text(
          'MEMORY KEY',
          style: GoogleFonts.lexend(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.secondary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryKeyText(BuildContext context, WordEntry? word) {
    final memoryKey = word?.memoryKey ?? '';
    final wordText = word?.word ?? '';
    final cue = word?.cue ?? '';

    // Try to highlight the word and cue in the memory key text
    if (memoryKey.isNotEmpty) {
      return Text(
        memoryKey,
        style: GoogleFonts.lexend(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppTheme.onSurface,
          height: 1.6,
        ),
      );
    }

    return Text(
      'The cue "$cue" helps you remember "$wordText".',
      style: GoogleFonts.lexend(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppTheme.onSurface,
        height: 1.6,
      ),
    );
  }

  Widget _buildHearMemoryKeyButton(BuildContext context, WidgetRef ref, WordEntry? word) {
    return Align(
      alignment: Alignment.centerLeft,
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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.volume_up_rounded, size: 20, color: AppTheme.secondary),
                SizedBox(width: 8),
                Text(
                  'Hear Memory Key',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
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
        onPressed: () {
          // Navigate to memory key focus for this word
          context.push('/memory_key_focus');
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Next',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppTheme.surfaceContainerHigh)),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.onSurface.withValues(alpha: 0.5),
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          onTap: (index) {
            if (index == 0) context.go('/home');
            if (index == 1) context.push('/map');
            if (index == 2) context.push('/vault');
            if (index == 3) context.push('/rewards');
            if (index == 4) context.push('/settings');
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded),
              label: 'Vault',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard_rounded),
              label: 'Rewards',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Parent',
            ),
          ],
        ),
      ),
    );
  }
}
