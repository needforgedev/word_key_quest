import 'dart:math';
import '../local_db/database_service.dart';
import '../models/models.dart';

/// Read-only access to seeded content: words, worlds, levels, rewards.
///
/// All content is immutable after seeding. This repository provides
/// query methods for the game engine and UI.
class ContentRepository {
  final DatabaseService _db;

  // In-memory caches (loaded once, never change)
  List<World>? _worldsCache;
  Map<String, WordEntry>? _wordByIdCache;
  List<String>? _campaignWordIdsCache; // all 3500 campaign word IDs sorted by sourceRank

  ContentRepository(this._db);

  // ═══════════════════════════════════════════════════════
  // Words
  // ═══════════════════════════════════════════════════════

  /// Get all campaign + bonus words.
  Future<List<WordEntry>> getAllWords() => _db.getAllWords();

  /// Get a single word by ID.
  Future<WordEntry?> getWordById(String id) async {
    await _ensureWordCache();
    return _wordByIdCache![id];
  }

  /// Get multiple words by their IDs, preserving order.
  Future<List<WordEntry>> getWordsByIds(List<String> ids) async {
    await _ensureWordCache();
    return ids
        .map((id) => _wordByIdCache![id])
        .where((w) => w != null)
        .cast<WordEntry>()
        .toList();
  }

  /// Get the 10 words assigned to a specific level.
  Future<List<WordEntry>> getWordsForLevel(
          int worldIndex, int levelIndex) =>
      _db.getWordsForLevel(worldIndex, levelIndex);

  /// Get the 23 bonus vault words.
  Future<List<WordEntry>> getBonusWords() => _db.getBonusWords();

  /// Search words by prefix/substring.
  Future<List<WordEntry>> searchWords(String query) => _db.searchWords(query);

  /// Get random words for distractor generation, excluding given IDs.
  Future<List<WordEntry>> getDistractors(
    int count, {
    required List<String> excludeIds,
  }) =>
      _db.getRandomWords(count, excludeIds: excludeIds);

  /// Get distractor words that share the same part of speech.
  /// Falls back to any random words if not enough matches found.
  Future<List<WordEntry>> getDistractorsBySpeech(
    String partOfSpeech,
    int count, {
    required List<String> excludeIds,
  }) async {
    // First try: same part of speech from DB
    final all = await _db.getRandomWords(count * 3, excludeIds: excludeIds);
    final samePOS =
        all.where((w) => w.partOfSpeech == partOfSpeech).take(count).toList();
    if (samePOS.length >= count) return samePOS;

    // Fallback: fill remaining from any words
    final remaining = count - samePOS.length;
    final usedIds = [...excludeIds, ...samePOS.map((w) => w.id)];
    final extras = await _db.getRandomWords(remaining, excludeIds: usedIds);
    return [...samePOS, ...extras];
  }

  // ═══════════════════════════════════════════════════════
  // Per-player shuffled word order
  // ═══════════════════════════════════════════════════════

  /// Get all 3,500 campaign word IDs in sourceRank order (cached).
  Future<List<String>> _getCampaignWordIds() async {
    if (_campaignWordIdsCache != null) return _campaignWordIdsCache!;
    final allWords = await _db.getAllWords();
    _campaignWordIdsCache = allWords
        .where((w) => !w.isBonus)
        .map((w) => w.id)
        .toList();
    return _campaignWordIdsCache!;
  }

  /// Generate a deterministic shuffled word sequence from a seed.
  ///
  /// Same seed always produces the same order. Different seeds produce
  /// different orders. All 3,500 campaign words are included exactly once.
  Future<List<String>> getShuffledWordIds(int seed) async {
    final ids = List<String>.from(await _getCampaignWordIds());
    ids.shuffle(Random(seed));
    return ids;
  }

  /// Get the 10 word IDs for a specific level using the player's shuffled order.
  ///
  /// levelNumber is 1-indexed (1-350).
  Future<List<String>> getShuffledWordsForLevel(int seed, int levelNumber) async {
    final shuffled = await getShuffledWordIds(seed);
    final startIndex = (levelNumber - 1) * 10;
    final endIndex = startIndex + 10;
    if (endIndex > shuffled.length) return shuffled.sublist(startIndex);
    return shuffled.sublist(startIndex, endIndex);
  }

  /// Get the WordEntry objects for a specific level using the player's shuffled order.
  Future<List<WordEntry>> getShuffledWordEntriesForLevel(
      int seed, int levelNumber) async {
    final wordIds = await getShuffledWordsForLevel(seed, levelNumber);
    return getWordsByIds(wordIds);
  }

  // ═══════════════════════════════════════════════════════
  // Worlds
  // ═══════════════════════════════════════════════════════

  /// Get all worlds (cached after first call).
  Future<List<World>> getAllWorlds() async {
    _worldsCache ??= await _db.getAllWorlds();
    return _worldsCache!;
  }

  /// Get a single world by its index (0-34, or 35 for bonus vault).
  Future<World?> getWorldByIndex(int index) async {
    final worlds = await getAllWorlds();
    return worlds.where((w) => w.index == index).firstOrNull;
  }

  /// Get campaign worlds only (excludes bonus vault).
  Future<List<World>> getCampaignWorlds() async {
    final worlds = await getAllWorlds();
    return worlds.where((w) => !w.isBonusVault).toList();
  }

  // ═══════════════════════════════════════════════════════
  // Levels
  // ═══════════════════════════════════════════════════════

  /// Get all 10 levels for a world.
  Future<List<Level>> getLevelsForWorld(int worldIndex) =>
      _db.getLevelsForWorld(worldIndex);

  /// Get a specific level.
  Future<Level?> getLevel(int worldIndex, int levelIndex) =>
      _db.getLevel(worldIndex, levelIndex);

  // ═══════════════════════════════════════════════════════
  // Rewards
  // ═══════════════════════════════════════════════════════

  /// Get all reward definitions.
  Future<List<RewardItem>> getAllRewards() => _db.getAllRewards();

  // ═══════════════════════════════════════════════════════
  // Cache management
  // ═══════════════════════════════════════════════════════

  Future<void> _ensureWordCache() async {
    if (_wordByIdCache != null) return;
    final allWords = await _db.getAllWords();
    _wordByIdCache = {for (final w in allWords) w.id: w};
  }

  /// Clear caches (useful for testing).
  void clearCaches() {
    _worldsCache = null;
    _wordByIdCache = null;
    _campaignWordIdsCache = null;
  }
}
