import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import 'service_providers.dart';

/// Provides access to seeded content: words, worlds, levels.
///
/// All content is immutable after seeding. These providers
/// use FutureProvider since content loading is async but data never changes.

/// All campaign worlds (cached).
final worldsProvider = FutureProvider<List<World>>((ref) {
  return ref.read(contentRepositoryProvider).getCampaignWorlds();
});

/// A single world by index.
final worldByIndexProvider =
    FutureProvider.family<World?, int>((ref, index) {
  return ref.read(contentRepositoryProvider).getWorldByIndex(index);
});

/// All levels for a world.
final levelsForWorldProvider =
    FutureProvider.family<List<Level>, int>((ref, worldIndex) {
  return ref.read(contentRepositoryProvider).getLevelsForWorld(worldIndex);
});

/// A specific level.
final levelProvider =
    FutureProvider.family<Level?, ({int world, int level})>((ref, params) {
  return ref.read(contentRepositoryProvider).getLevel(params.world, params.level);
});

/// Words for a specific level.
final wordsForLevelProvider = FutureProvider.family<List<WordEntry>,
    ({int world, int level})>((ref, params) {
  return ref
      .read(contentRepositoryProvider)
      .getWordsForLevel(params.world, params.level);
});

/// A single word by ID.
final wordByIdProvider =
    FutureProvider.family<WordEntry?, String>((ref, id) {
  return ref.read(contentRepositoryProvider).getWordById(id);
});

/// Multiple words by IDs.
final wordsByIdsProvider =
    FutureProvider.family<List<WordEntry>, List<String>>((ref, ids) {
  return ref.read(contentRepositoryProvider).getWordsByIds(ids);
});

/// Search words by query string.
final wordSearchProvider =
    FutureProvider.family<List<WordEntry>, String>((ref, query) {
  if (query.trim().isEmpty) return Future.value([]);
  return ref.read(contentRepositoryProvider).searchWords(query);
});

/// Bonus vault words.
final bonusWordsProvider = FutureProvider<List<WordEntry>>((ref) {
  return ref.read(contentRepositoryProvider).getBonusWords();
});

/// All rewards from catalog.
final rewardCatalogProvider = FutureProvider<List<RewardItem>>((ref) {
  return ref.read(contentRepositoryProvider).getAllRewards();
});
