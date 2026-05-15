import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/theme.dart';
import '../../application/content_provider.dart';
import '../../application/mastery_provider.dart';
import '../../application/service_providers.dart';
import '../../core/word_image_helper.dart';
import '../../data/models/models.dart';

/// Holds the currently selected word ID for the detail screen.
class SelectedWordIdNotifier extends Notifier<String> {
  @override
  String build() => '';

  void select(String wordId) {
    state = wordId;
  }
}

final selectedWordIdProvider =
    NotifierProvider<SelectedWordIdNotifier, String>(
        () => SelectedWordIdNotifier());

class WordDetailScreen extends ConsumerWidget {
  const WordDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordId = ref.watch(selectedWordIdProvider);
    final wordAsync = ref.watch(wordByIdProvider(wordId));
    final progressAsync = ref.watch(wordProgressProvider(wordId));

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: wordAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, stack) => Center(
                  child: Text('Error loading word: $err'),
                ),
                data: (word) {
                  if (word == null) {
                    return Center(
                      child: Text(
                        'Word not found',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          color: AppTheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    );
                  }
                  final progress = progressAsync.value;
                  final mastery = progress?.masteryLevel ?? 0;
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        _buildWordHeader(word),
                        SizedBox(height: 20),
                        _buildHeroImage(word),
                        SizedBox(height: 16),
                        _buildActionButtons(ref, word),
                        SizedBox(height: 24),
                        _buildMeaningSection(word),
                        SizedBox(height: 20),
                        _buildMemoryKeySection(word),
                        SizedBox(height: 20),
                        _buildSynonymsAntonyms(word),
                        // Usage examples
                        if (word.usage1Simple.isNotEmpty || word.usage2Standard.isNotEmpty) ...[
                          SizedBox(height: 20),
                          _buildUsageExamples(word),
                        ],
                        SizedBox(height: 20),
                        _buildMasteryProgress(mastery),
                        SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/vault'),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              'Vocoro',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordHeader(WordEntry word) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          word.word,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurface,
            letterSpacing: -1.0,
          ),
        ),
        if (word.pronunciation.isNotEmpty) ...[
          SizedBox(height: 4),
          Text(
            '/${word.pronunciation}/',
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: AppTheme.onSurface.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (word.partOfSpeech.isNotEmpty) ...[
          SizedBox(height: 6),
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
                color: AppTheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeroImage(WordEntry word) {
    final caption =
        word.usage1Simple.isNotEmpty ? word.usage1Simple : null;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            WordImageHelper.getImagePath(word.id) ?? 'assets/images/image_2f7dc974.jpg',
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Icon(
                  Icons.castle_rounded,
                  size: 80,
                  color: AppTheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        // Caption overlay at bottom
        if (caption != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Text(
                caption,
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(WidgetRef ref, WordEntry word) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ref.read(ttsServiceProvider).speakWord(word.word);
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.volume_up_rounded,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Hear',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryDim,
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Practice',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeaningSection(WordEntry word) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'What does it mean?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Text(
            word.kidsMeaning,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: AppTheme.onSurface.withOpacity(0.8),
              height: 1.6,
            ),
          ),
          if (word.barronsMeaning.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              word.barronsMeaning,
              style: GoogleFonts.lexend(
                fontSize: 13,
                color: AppTheme.onSurface.withOpacity(0.5),
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemoryKeySection(WordEntry word) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.secondaryContainer,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.vpn_key_rounded,
                  color: AppTheme.secondary,
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Memory Key Story',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          if (word.cue.isNotEmpty) ...[
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.lightbulb_rounded, size: 16, color: AppTheme.secondaryContainer),
                SizedBox(width: 6),
                Text(
                  'Cue: ',
                  style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.secondary),
                ),
                Flexible(
                  child: Text(
                    '"${word.cue}" (${word.cueType})',
                    style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.secondary),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 14),
          Text(
            word.memoryKey,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: AppTheme.onSurface.withOpacity(0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynonymsAntonyms(WordEntry word) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Same As',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 10),
                word.synonyms.isNotEmpty
                    ? Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: word.synonyms
                            .map((s) =>
                                _buildWordBadge(s, AppTheme.primary))
                            .toList(),
                      )
                    : Text(
                        'None',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: AppTheme.onSurface.withOpacity(0.4),
                        ),
                      ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Opposite',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 10),
                word.antonyms.isNotEmpty
                    ? Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: word.antonyms
                            .map((a) => _buildWordBadge(
                                a, AppTheme.errorContainer))
                            .toList(),
                      )
                    : Text(
                        'None',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: AppTheme.onSurface.withOpacity(0.4),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordBadge(String word, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        word,
        style: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildUsageExamples(WordEntry word) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote_rounded, size: 20, color: AppTheme.primary),
              SizedBox(width: 8),
              Text(
                'Usage Examples',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          if (word.usage1Simple.isNotEmpty) ...[
            SizedBox(height: 10),
            Text(
              word.usage1Simple,
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppTheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ],
          if (word.usage2Standard.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              word.usage2Standard,
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppTheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMasteryProgress(int mastery) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Word Mastery',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star_rounded,
                    size: 24,
                    color: index < mastery
                        ? AppTheme.secondaryContainer
                        : AppTheme.surfaceContainerHigh,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: mastery / 5,
              minHeight: 12,
              backgroundColor: AppTheme.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryContainer,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '$mastery of 5 mastery levels reached',
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: AppTheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: Offset(0, -2),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_rounded,
                label: 'Home',
                onTap: () => context.go('/home'),
              ),
              _buildNavItem(
                context,
                icon: Icons.map_rounded,
                label: 'Map',
                onTap: () => context.push('/map'),
              ),
              _buildNavItem(
                context,
                icon: Icons.inventory_2_rounded,
                label: 'Vault',
                isActive: true,
                onTap: () => context.go('/vault'),
              ),
              _buildNavItem(
                context,
                icon: Icons.card_giftcard_rounded,
                label: 'Rewards',
                onTap: () => context.push('/rewards'),
              ),
              _buildNavItem(
                context,
                icon: Icons.supervisor_account_rounded,
                label: 'Parent',
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color:
                  isActive ? Colors.white : AppTheme.onSurface.withOpacity(0.5),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? Colors.white
                    : AppTheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
