import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/theme.dart';
import '../../application/mastery_provider.dart';
import '../../application/content_provider.dart';
import '../../core/word_image_helper.dart';
import '../../data/models/models.dart';
import '../vault/word_detail_screen.dart';

class WordVaultScreen extends ConsumerStatefulWidget {
  const WordVaultScreen({super.key});

  @override
  ConsumerState<WordVaultScreen> createState() => _WordVaultScreenState();
}

class _WordVaultScreenState extends ConsumerState<WordVaultScreen> {
  String _activeFilter = 'Learned';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final allProgress = ref.watch(allWordProgressProvider);
    final introducedCount = ref.watch(introducedCountProvider);
    final masteredCount = ref.watch(masteredCountProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24),
                children: [
                  SizedBox(height: 16),
                  _buildSearchBar(),
                  SizedBox(height: 16),
                  _buildFilterChips(),
                  SizedBox(height: 20),
                  _buildStatsBento(introducedCount, masteredCount),
                  SizedBox(height: 24),
                  _buildSectionHeader(),
                  SizedBox(height: 12),
                  ..._buildWordList(allProgress),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  List<Widget> _buildWordList(AsyncValue<List<WordProgress>> allProgress) {
    // If searching, use search provider instead
    if (_searchQuery.isNotEmpty) {
      final searchResults = ref.watch(wordSearchProvider(_searchQuery));
      return searchResults.when(
        data: (entries) {
          if (entries.isEmpty) {
            return [_buildEmptyState('No words match your search.')];
          }
          return entries
              .map((entry) => Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: _buildSearchWordCard(context, entry),
                  ))
              .toList();
        },
        loading: () => [_buildLoadingIndicator()],
        error: (_, __) => [_buildEmptyState('Error searching words.')],
      );
    }

    return allProgress.when(
      data: (progressList) {
        // Filter based on _activeFilter
        var filtered =
            progressList.where((p) => p.masteryLevel > 0).toList();
        if (_activeFilter == 'Mastered') {
          filtered =
              filtered.where((p) => p.masteryLevel >= 5).toList();
        } else if (_activeFilter == 'Review') {
          filtered = filtered.where((p) => p.needsReview).toList();
        }

        if (filtered.isEmpty) {
          return [_buildEmptyState('No words found for this filter.')];
        }

        return filtered
            .map((progress) => Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _buildProgressWordCard(context, progress),
                ))
            .toList();
      },
      loading: () => [_buildLoadingIndicator()],
      error: (_, __) => [_buildEmptyState('Error loading words.')],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.lexend(
            fontSize: 14,
            color: AppTheme.onSurface.withOpacity(0.5),
          ),
        ),
      ),
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
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              'Word Vault',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.star_rounded,
              color: AppTheme.secondaryContainer,
              size: 22,
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: GoogleFonts.lexend(
          fontSize: 14,
          color: AppTheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search your words...',
          hintStyle: GoogleFonts.lexend(
            fontSize: 14,
            color: AppTheme.onSurface.withOpacity(0.4),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.onSurface.withOpacity(0.4),
          ),
          filled: true,
          fillColor: AppTheme.surfaceContainerLowest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Learned', 'Review', 'Mastered'];
    return Row(
      children: [
        Icon(
          Icons.filter_list_rounded,
          size: 20,
          color: AppTheme.onSurface,
        ),
        SizedBox(width: 8),
        ...filters.map((filter) {
          final isActive = _activeFilter == filter;
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _activeFilter = filter),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? AppTheme.primary
                        : AppTheme.onSurface.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  filter,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? Colors.white
                        : AppTheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatsBento(
    AsyncValue<int> introducedCount,
    AsyncValue<int> masteredCount,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryDim,
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  introducedCount.when(
                    data: (c) => '$c',
                    loading: () => '\u2014',
                    error: (_, __) => '0',
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'WORDS FOUND',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryContainer,
                    letterSpacing: 0.5,
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
              color: AppTheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondary.withOpacity(0.4),
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  masteredCount.when(
                    data: (c) => '$c',
                    loading: () => '\u2014',
                    error: (_, __) => '0',
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'MASTERED',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Text(
      'Recent Discoveries',
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.onSurface,
        letterSpacing: -0.5,
      ),
    );
  }

  /// Word card built from WordProgress — loads the WordEntry via provider.
  Widget _buildProgressWordCard(BuildContext context, WordProgress progress) {
    final wordEntryAsync = ref.watch(wordByIdProvider(progress.wordId));

    return wordEntryAsync.when(
      data: (wordEntry) {
        final displayWord = wordEntry?.word ?? progress.wordId;
        return _buildWordCardContent(
          context,
          word: displayWord,
          masteryLevel: progress.masteryLevel,
          wordId: progress.wordId,
        );
      },
      loading: () => _buildWordCardContent(
        context,
        word: progress.wordId,
        masteryLevel: progress.masteryLevel,
        wordId: progress.wordId,
        isLoading: true,
      ),
      error: (_, __) => _buildWordCardContent(
        context,
        word: progress.wordId,
        masteryLevel: progress.masteryLevel,
        wordId: progress.wordId,
      ),
    );
  }

  /// Word card built from a search-result WordEntry (no progress context).
  Widget _buildSearchWordCard(BuildContext context, WordEntry entry) {
    // Try to get progress for this word to show mastery
    final progressAsync = ref.watch(wordProgressProvider(entry.id));
    final masteryLevel = progressAsync.when(
      data: (p) => p?.masteryLevel ?? 0,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return _buildWordCardContent(
      context,
      word: entry.word,
      masteryLevel: masteryLevel,
      wordId: entry.id,
    );
  }

  Widget _buildWordCardContent(
    BuildContext context, {
    required String word,
    required int masteryLevel,
    String wordId = '',
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (wordId.isNotEmpty) {
          ref.read(selectedWordIdProvider.notifier).select(wordId);
        }
        context.push('/word_detail');
      },
      child: Container(
        padding: EdgeInsets.all(12),
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
        child: Row(
          children: [
            // Word thumbnail image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 56,
                height: 56,
                child: wordId.isNotEmpty && WordImageHelper.hasImage(wordId)
                    ? Image.asset(
                        WordImageHelper.getImagePath(wordId)!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppTheme.surfaceContainerHigh,
                          child: Icon(Icons.image_rounded,
                              color: AppTheme.onSurface, size: 24),
                        ),
                      )
                    : Container(
                        color: AppTheme.surfaceContainerHigh,
                        child: Icon(
                          isLoading
                              ? Icons.hourglass_empty_rounded
                              : Icons.image_rounded,
                          color: AppTheme.onSurface,
                          size: 24,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 14),
            // Word name and mastery
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'MASTERY: $masteryLevel/5',
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface.withOpacity(0.5),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            // Star rating — masteryLevel filled out of 5
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                return Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: i < masteryLevel
                      ? AppTheme.secondaryContainer
                      : AppTheme.surfaceContainerHigh,
                );
              }),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.onSurface,
              size: 20,
            ),
          ],
        ),
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
                onTap: () {},
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
