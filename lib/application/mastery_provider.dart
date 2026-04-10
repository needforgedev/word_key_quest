import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import 'service_providers.dart';

/// Provides word mastery data for vault, detail, and dashboard screens.

/// Progress for a single word.
final wordProgressProvider =
    FutureProvider.family<WordProgress?, String>((ref, wordId) {
  return ref.read(progressRepositoryProvider).getProgress(wordId);
});

/// All word progress entries (for vault listing).
final allWordProgressProvider = FutureProvider<List<WordProgress>>((ref) {
  return ref.read(progressRepositoryProvider).getAllProgress();
});

/// Count of introduced words (mastery >= 1).
final introducedCountProvider = FutureProvider<int>((ref) {
  return ref.read(progressRepositoryProvider).getIntroducedCount();
});

/// Count of mastered words (mastery == 5).
final masteredCountProvider = FutureProvider<int>((ref) {
  return ref.read(progressRepositoryProvider).getMasteredCount();
});

/// Mastery level counts (how many words at each level 0-5).
final masteryCountsProvider = FutureProvider<Map<int, int>>((ref) {
  return ref.read(progressRepositoryProvider).getMasteryCounts();
});

/// Overall accuracy across all answered words.
final overallAccuracyProvider = FutureProvider<double>((ref) {
  return ref.read(progressRepositoryProvider).getOverallAccuracy();
});
