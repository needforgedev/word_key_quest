import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/models.dart';

/// Central SQLite database service for Vocoro.
///
/// Tables:
///   - words          (seeded, immutable content)
///   - worlds         (seeded, immutable content)
///   - levels         (seeded, immutable content)
///   - rewards        (seeded, immutable content)
///   - player_profile (single row, mutable)
///   - word_progress  (per-word mastery tracking, mutable)
///   - reward_progress(per-reward unlock/equip state, mutable)
///   - daily_quests   (daily review sessions, mutable)
class DatabaseService {
  static const _dbName = 'vocoro.db';
  static const _dbVersion = 1;

  Database? _db;

  /// Returns the database instance, opening it if needed.
  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ── Content tables (seeded from JSON manifests) ──

    await db.execute('''
      CREATE TABLE words (
        id TEXT PRIMARY KEY,
        source_rank INTEGER NOT NULL,
        word TEXT NOT NULL,
        part_of_speech TEXT NOT NULL DEFAULT '',
        pronunciation TEXT NOT NULL DEFAULT '',
        barrons_meaning TEXT NOT NULL DEFAULT '',
        kids_meaning TEXT NOT NULL DEFAULT '',
        cue_type TEXT NOT NULL DEFAULT 'situation',
        cue TEXT NOT NULL DEFAULT '',
        memory_key TEXT NOT NULL DEFAULT '',
        synonyms TEXT NOT NULL DEFAULT '[]',
        antonyms TEXT NOT NULL DEFAULT '[]',
        usage1_simple TEXT NOT NULL DEFAULT '',
        usage2_standard TEXT NOT NULL DEFAULT '',
        world_index INTEGER NOT NULL,
        level_index INTEGER NOT NULL,
        is_bonus INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE worlds (
        id TEXT PRIMARY KEY,
        idx INTEGER NOT NULL,
        name TEXT NOT NULL,
        word_count INTEGER NOT NULL,
        level_count INTEGER NOT NULL,
        unlock_requirement TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE levels (
        id TEXT PRIMARY KEY,
        world_id TEXT NOT NULL,
        world_index INTEGER NOT NULL,
        level_index INTEGER NOT NULL,
        level_number INTEGER NOT NULL,
        new_word_ids TEXT NOT NULL,
        boss_enabled INTEGER NOT NULL DEFAULT 0,
        star_reward INTEGER NOT NULL DEFAULT 3,
        key_reward INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE rewards (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        unlock_rule TEXT NOT NULL,
        rarity TEXT NOT NULL DEFAULT 'common'
      )
    ''');

    // ── Player state tables (mutable, written at runtime) ──

    await db.execute('''
      CREATE TABLE player_profile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL DEFAULT '',
        age_band INTEGER NOT NULL DEFAULT 8,
        avatar_id INTEGER NOT NULL DEFAULT 0,
        selected_theme TEXT NOT NULL DEFAULT 'enchanted_kingdom',
        current_world INTEGER NOT NULL DEFAULT 0,
        current_level INTEGER NOT NULL DEFAULT 0,
        streak_count INTEGER NOT NULL DEFAULT 0,
        stars INTEGER NOT NULL DEFAULT 0,
        keys_count INTEGER NOT NULL DEFAULT 0,
        word_order_seed INTEGER NOT NULL DEFAULT 0,
        last_played_at TEXT,
        streak_start_date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE word_progress (
        word_id TEXT PRIMARY KEY,
        mastery_level INTEGER NOT NULL DEFAULT 0,
        times_seen INTEGER NOT NULL DEFAULT 0,
        times_correct INTEGER NOT NULL DEFAULT 0,
        times_incorrect INTEGER NOT NULL DEFAULT 0,
        last_seen_at TEXT,
        next_review_at TEXT,
        first_seen_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reward_progress (
        reward_id TEXT PRIMARY KEY,
        is_unlocked INTEGER NOT NULL DEFAULT 0,
        is_equipped INTEGER NOT NULL DEFAULT 0,
        unlocked_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_quests (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        review_word_ids TEXT NOT NULL DEFAULT '[]',
        target_count INTEGER NOT NULL DEFAULT 0,
        is_complete INTEGER NOT NULL DEFAULT 0,
        words_reviewed INTEGER NOT NULL DEFAULT 0,
        correct_count INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT
      )
    ''');

    // ── Indexes for common queries ──

    await db.execute(
        'CREATE INDEX idx_words_world_level ON words(world_index, level_index)');
    await db.execute(
        'CREATE INDEX idx_word_progress_mastery ON word_progress(mastery_level)');
    await db.execute(
        'CREATE INDEX idx_word_progress_review ON word_progress(next_review_at)');
    await db.execute(
        'CREATE INDEX idx_levels_world ON levels(world_index)');
  }

  // ═══════════════════════════════════════════════════════
  // Content seeding (called once on first launch)
  // ═══════════════════════════════════════════════════════

  /// Whether the database has been seeded with content.
  Future<bool> isSeeded() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM words');
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  /// Bulk-insert word entries from the manifest.
  Future<void> seedWords(List<WordEntry> words) async {
    final db = await database;
    final batch = db.batch();
    for (final w in words) {
      batch.insert('words', _wordToRow(w),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Bulk-insert worlds from the manifest.
  Future<void> seedWorlds(List<World> worlds) async {
    final db = await database;
    final batch = db.batch();
    for (final w in worlds) {
      batch.insert('worlds', _worldToRow(w),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Bulk-insert levels from the manifest.
  Future<void> seedLevels(List<Level> levels) async {
    final db = await database;
    final batch = db.batch();
    for (final l in levels) {
      batch.insert('levels', _levelToRow(l),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Bulk-insert rewards from the manifest.
  Future<void> seedRewards(List<RewardItem> rewards) async {
    final db = await database;
    final batch = db.batch();
    for (final r in rewards) {
      batch.insert('rewards', _rewardToRow(r),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // ═══════════════════════════════════════════════════════
  // Word queries
  // ═══════════════════════════════════════════════════════

  Future<List<WordEntry>> getAllWords() async {
    final db = await database;
    final rows = await db.query('words', orderBy: 'source_rank');
    return rows.map(_rowToWord).toList();
  }

  Future<List<WordEntry>> getWordsForLevel(
      int worldIndex, int levelIndex) async {
    final db = await database;
    final rows = await db.query('words',
        where: 'world_index = ? AND level_index = ?',
        whereArgs: [worldIndex, levelIndex],
        orderBy: 'source_rank');
    return rows.map(_rowToWord).toList();
  }

  Future<List<WordEntry>> getWordsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final db = await database;
    final placeholders = ids.map((_) => '?').join(',');
    final rows = await db.rawQuery(
        'SELECT * FROM words WHERE id IN ($placeholders)', ids);
    return rows.map(_rowToWord).toList();
  }

  Future<WordEntry?> getWordById(String id) async {
    final db = await database;
    final rows = await db.query('words', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _rowToWord(rows.first);
  }

  Future<List<WordEntry>> getBonusWords() async {
    final db = await database;
    final rows = await db.query('words',
        where: 'is_bonus = 1', orderBy: 'source_rank');
    return rows.map(_rowToWord).toList();
  }

  Future<List<WordEntry>> searchWords(String query) async {
    final db = await database;
    final rows = await db.query('words',
        where: 'word LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'source_rank',
        limit: 50);
    return rows.map(_rowToWord).toList();
  }

  /// Get random words for distractor generation, excluding specific IDs.
  Future<List<WordEntry>> getRandomWords(int count,
      {List<String> excludeIds = const []}) async {
    final db = await database;
    String where = 'is_bonus = 0';
    List<dynamic> args = [];
    if (excludeIds.isNotEmpty) {
      final placeholders = excludeIds.map((_) => '?').join(',');
      where += ' AND id NOT IN ($placeholders)';
      args = [...excludeIds];
    }
    final rows = await db.query('words',
        where: where, whereArgs: args, orderBy: 'RANDOM()', limit: count);
    return rows.map(_rowToWord).toList();
  }

  // ═══════════════════════════════════════════════════════
  // World queries
  // ═══════════════════════════════════════════════════════

  Future<List<World>> getAllWorlds() async {
    final db = await database;
    final rows = await db.query('worlds', orderBy: 'idx');
    return rows.map(_rowToWorld).toList();
  }

  Future<World?> getWorldByIndex(int index) async {
    final db = await database;
    final rows =
        await db.query('worlds', where: 'idx = ?', whereArgs: [index]);
    if (rows.isEmpty) return null;
    return _rowToWorld(rows.first);
  }

  // ═══════════════════════════════════════════════════════
  // Level queries
  // ═══════════════════════════════════════════════════════

  Future<List<Level>> getLevelsForWorld(int worldIndex) async {
    final db = await database;
    final rows = await db.query('levels',
        where: 'world_index = ?',
        whereArgs: [worldIndex],
        orderBy: 'level_index');
    return rows.map(_rowToLevel).toList();
  }

  Future<Level?> getLevel(int worldIndex, int levelIndex) async {
    final db = await database;
    final rows = await db.query('levels',
        where: 'world_index = ? AND level_index = ?',
        whereArgs: [worldIndex, levelIndex]);
    if (rows.isEmpty) return null;
    return _rowToLevel(rows.first);
  }

  // ═══════════════════════════════════════════════════════
  // Reward queries
  // ═══════════════════════════════════════════════════════

  Future<List<RewardItem>> getAllRewards() async {
    final db = await database;
    final rows = await db.query('rewards');
    return rows.map(_rowToReward).toList();
  }

  // ═══════════════════════════════════════════════════════
  // Player profile
  // ═══════════════════════════════════════════════════════

  Future<PlayerProfile?> getPlayerProfile() async {
    final db = await database;
    final rows = await db.query('player_profile', limit: 1);
    if (rows.isEmpty) return null;
    return _rowToPlayer(rows.first);
  }

  Future<void> savePlayerProfile(PlayerProfile profile) async {
    final db = await database;
    await db.insert('player_profile', _playerToRow(profile),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ═══════════════════════════════════════════════════════
  // Word progress
  // ═══════════════════════════════════════════════════════

  Future<WordProgress?> getWordProgress(String wordId) async {
    final db = await database;
    final rows = await db
        .query('word_progress', where: 'word_id = ?', whereArgs: [wordId]);
    if (rows.isEmpty) return null;
    return _rowToWordProgress(rows.first);
  }

  Future<List<WordProgress>> getAllWordProgress() async {
    final db = await database;
    final rows = await db.query('word_progress');
    return rows.map(_rowToWordProgress).toList();
  }

  Future<void> saveWordProgress(WordProgress progress) async {
    final db = await database;
    await db.insert('word_progress', _wordProgressToRow(progress),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get words due for review (nextReviewAt <= now, mastery 1-4).
  Future<List<WordProgress>> getDueReviewWords({int limit = 15}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final rows = await db.query('word_progress',
        where:
            'next_review_at IS NOT NULL AND next_review_at <= ? AND mastery_level > 0 AND mastery_level < 5',
        whereArgs: [now],
        orderBy: 'next_review_at ASC',
        limit: limit);
    return rows.map(_rowToWordProgress).toList();
  }

  /// Get words at a specific mastery level.
  Future<List<WordProgress>> getWordsByMastery(int masteryLevel) async {
    final db = await database;
    final rows = await db.query('word_progress',
        where: 'mastery_level = ?', whereArgs: [masteryLevel]);
    return rows.map(_rowToWordProgress).toList();
  }

  /// Count words at each mastery level.
  Future<Map<int, int>> getMasteryCounts() async {
    final db = await database;
    final rows = await db.rawQuery(
        'SELECT mastery_level, COUNT(*) as cnt FROM word_progress GROUP BY mastery_level');
    return {for (final r in rows) r['mastery_level'] as int: r['cnt'] as int};
  }

  /// Total words with mastery >= 1 (introduced).
  Future<int> getIntroducedWordCount() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM word_progress WHERE mastery_level >= 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Total words with mastery == 5 (mastered).
  Future<int> getMasteredWordCount() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM word_progress WHERE mastery_level = 5');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Overall accuracy across all answered words.
  Future<double> getOverallAccuracy() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT SUM(times_correct) as correct, SUM(times_correct + times_incorrect) as total FROM word_progress WHERE times_seen > 0');
    final row = result.first;
    final correct = (row['correct'] as int?) ?? 0;
    final total = (row['total'] as int?) ?? 0;
    if (total == 0) return 0.0;
    return correct / total;
  }

  // ═══════════════════════════════════════════════════════
  // Reward progress
  // ═══════════════════════════════════════════════════════

  Future<RewardProgress?> getRewardProgress(String rewardId) async {
    final db = await database;
    final rows = await db.query('reward_progress',
        where: 'reward_id = ?', whereArgs: [rewardId]);
    if (rows.isEmpty) return null;
    return _rowToRewardProgress(rows.first);
  }

  Future<List<RewardProgress>> getAllRewardProgress() async {
    final db = await database;
    final rows = await db.query('reward_progress');
    return rows.map(_rowToRewardProgress).toList();
  }

  Future<void> saveRewardProgress(RewardProgress progress) async {
    final db = await database;
    await db.insert('reward_progress', _rewardProgressToRow(progress),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ═══════════════════════════════════════════════════════
  // Daily quests
  // ═══════════════════════════════════════════════════════

  Future<DailyQuest?> getDailyQuestForDate(DateTime date) async {
    final db = await database;
    final dateStr = _dateOnly(date);
    final rows = await db
        .query('daily_quests', where: 'date = ?', whereArgs: [dateStr]);
    if (rows.isEmpty) return null;
    return _rowToDailyQuest(rows.first);
  }

  Future<void> saveDailyQuest(DailyQuest quest) async {
    final db = await database;
    await db.insert('daily_quests', _dailyQuestToRow(quest),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ═══════════════════════════════════════════════════════
  // Utilities
  // ═══════════════════════════════════════════════════════

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  String _dateOnly(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  // ── Row mappers: WordEntry ──

  Map<String, dynamic> _wordToRow(WordEntry w) => {
        'id': w.id,
        'source_rank': w.sourceRank,
        'word': w.word,
        'part_of_speech': w.partOfSpeech,
        'pronunciation': w.pronunciation,
        'barrons_meaning': w.barronsMeaning,
        'kids_meaning': w.kidsMeaning,
        'cue_type': w.cueType,
        'cue': w.cue,
        'memory_key': w.memoryKey,
        'synonyms': w.synonyms.join(';'),
        'antonyms': w.antonyms.join(';'),
        'usage1_simple': w.usage1Simple,
        'usage2_standard': w.usage2Standard,
        'world_index': w.worldIndex,
        'level_index': w.levelIndex,
        'is_bonus': w.isBonus ? 1 : 0,
      };

  WordEntry _rowToWord(Map<String, dynamic> row) => WordEntry(
        id: row['id'] as String,
        sourceRank: row['source_rank'] as int,
        word: row['word'] as String,
        partOfSpeech: row['part_of_speech'] as String? ?? '',
        pronunciation: row['pronunciation'] as String? ?? '',
        barronsMeaning: row['barrons_meaning'] as String? ?? '',
        kidsMeaning: row['kids_meaning'] as String? ?? '',
        cueType: row['cue_type'] as String? ?? 'situation',
        cue: row['cue'] as String? ?? '',
        memoryKey: row['memory_key'] as String? ?? '',
        synonyms: _splitSemicolon(row['synonyms']),
        antonyms: _splitSemicolon(row['antonyms']),
        usage1Simple: row['usage1_simple'] as String? ?? '',
        usage2Standard: row['usage2_standard'] as String? ?? '',
        worldIndex: row['world_index'] as int,
        levelIndex: row['level_index'] as int,
        isBonus: (row['is_bonus'] as int) == 1,
      );

  // ── Row mappers: World ──

  Map<String, dynamic> _worldToRow(World w) => {
        'id': w.id,
        'idx': w.index,
        'name': w.name,
        'word_count': w.wordCount,
        'level_count': w.levelCount,
        'unlock_requirement': w.unlockRequirement,
      };

  World _rowToWorld(Map<String, dynamic> row) => World(
        id: row['id'] as String,
        index: row['idx'] as int,
        name: row['name'] as String,
        wordCount: row['word_count'] as int,
        levelCount: row['level_count'] as int,
        unlockRequirement: row['unlock_requirement'] as String,
      );

  // ── Row mappers: Level ──

  Map<String, dynamic> _levelToRow(Level l) => {
        'id': l.id,
        'world_id': l.worldId,
        'world_index': l.worldIndex,
        'level_index': l.levelIndex,
        'level_number': l.levelNumber,
        'new_word_ids': l.newWordIds.join(','),
        'boss_enabled': l.bossEnabled ? 1 : 0,
        'star_reward': l.starReward,
        'key_reward': l.keyReward,
      };

  Level _rowToLevel(Map<String, dynamic> row) => Level(
        id: row['id'] as String,
        worldId: row['world_id'] as String,
        worldIndex: row['world_index'] as int,
        levelIndex: row['level_index'] as int,
        levelNumber: row['level_number'] as int,
        newWordIds: (row['new_word_ids'] as String).split(','),
        bossEnabled: (row['boss_enabled'] as int) == 1,
        starReward: row['star_reward'] as int,
        keyReward: row['key_reward'] as int,
      );

  // ── Row mappers: RewardItem ──

  Map<String, dynamic> _rewardToRow(RewardItem r) => {
        'id': r.id,
        'name': r.name,
        'type': r.type,
        'category': r.category,
        'unlock_rule': r.unlockRule,
        'rarity': r.rarity,
      };

  RewardItem _rowToReward(Map<String, dynamic> row) => RewardItem(
        id: row['id'] as String,
        name: row['name'] as String,
        type: row['type'] as String,
        category: row['category'] as String,
        unlockRule: row['unlock_rule'] as String,
        rarity: row['rarity'] as String? ?? 'common',
      );

  // ── Row mappers: PlayerProfile ──

  Map<String, dynamic> _playerToRow(PlayerProfile p) => {
        'id': p.id,
        'name': p.name,
        'age_band': p.ageBand,
        'avatar_id': p.avatarId,
        'selected_theme': p.selectedTheme,
        'current_world': p.currentWorld,
        'current_level': p.currentLevel,
        'streak_count': p.streakCount,
        'stars': p.stars,
        'keys_count': p.keys,
        'word_order_seed': p.wordOrderSeed,
        'last_played_at': p.lastPlayedAt?.toIso8601String(),
        'streak_start_date': p.streakStartDate?.toIso8601String(),
      };

  PlayerProfile _rowToPlayer(Map<String, dynamic> row) => PlayerProfile(
        id: row['id'] as String,
        name: row['name'] as String? ?? '',
        ageBand: row['age_band'] as int? ?? 8,
        avatarId: row['avatar_id'] as int? ?? 0,
        selectedTheme:
            row['selected_theme'] as String? ?? 'enchanted_kingdom',
        currentWorld: row['current_world'] as int? ?? 0,
        currentLevel: row['current_level'] as int? ?? 0,
        streakCount: row['streak_count'] as int? ?? 0,
        stars: row['stars'] as int? ?? 0,
        keys: row['keys_count'] as int? ?? 0,
        wordOrderSeed: row['word_order_seed'] as int? ?? 0,
        lastPlayedAt: row['last_played_at'] != null
            ? DateTime.tryParse(row['last_played_at'] as String)
            : null,
        streakStartDate: row['streak_start_date'] != null
            ? DateTime.tryParse(row['streak_start_date'] as String)
            : null,
      );

  // ── Row mappers: WordProgress ──

  Map<String, dynamic> _wordProgressToRow(WordProgress wp) => {
        'word_id': wp.wordId,
        'mastery_level': wp.masteryLevel,
        'times_seen': wp.timesSeen,
        'times_correct': wp.timesCorrect,
        'times_incorrect': wp.timesIncorrect,
        'last_seen_at': wp.lastSeenAt?.toIso8601String(),
        'next_review_at': wp.nextReviewAt?.toIso8601String(),
        'first_seen_at': wp.firstSeenAt?.toIso8601String(),
      };

  WordProgress _rowToWordProgress(Map<String, dynamic> row) => WordProgress(
        wordId: row['word_id'] as String,
        masteryLevel: row['mastery_level'] as int? ?? 0,
        timesSeen: row['times_seen'] as int? ?? 0,
        timesCorrect: row['times_correct'] as int? ?? 0,
        timesIncorrect: row['times_incorrect'] as int? ?? 0,
        lastSeenAt: row['last_seen_at'] != null
            ? DateTime.tryParse(row['last_seen_at'] as String)
            : null,
        nextReviewAt: row['next_review_at'] != null
            ? DateTime.tryParse(row['next_review_at'] as String)
            : null,
        firstSeenAt: row['first_seen_at'] != null
            ? DateTime.tryParse(row['first_seen_at'] as String)
            : null,
      );

  // ── Row mappers: RewardProgress ──

  Map<String, dynamic> _rewardProgressToRow(RewardProgress rp) => {
        'reward_id': rp.rewardId,
        'is_unlocked': rp.isUnlocked ? 1 : 0,
        'is_equipped': rp.isEquipped ? 1 : 0,
        'unlocked_at': rp.unlockedAt?.toIso8601String(),
      };

  RewardProgress _rowToRewardProgress(Map<String, dynamic> row) =>
      RewardProgress(
        rewardId: row['reward_id'] as String,
        isUnlocked: (row['is_unlocked'] as int) == 1,
        isEquipped: (row['is_equipped'] as int) == 1,
        unlockedAt: row['unlocked_at'] != null
            ? DateTime.tryParse(row['unlocked_at'] as String)
            : null,
      );

  // ── Row mappers: DailyQuest ──

  Map<String, dynamic> _dailyQuestToRow(DailyQuest q) => {
        'id': q.id,
        'date': _dateOnly(q.date),
        'review_word_ids': q.reviewWordIds.join(','),
        'target_count': q.targetCount,
        'is_complete': q.isComplete ? 1 : 0,
        'words_reviewed': q.wordsReviewed,
        'correct_count': q.correctCount,
        'completed_at': q.completedAt?.toIso8601String(),
      };

  DailyQuest _rowToDailyQuest(Map<String, dynamic> row) => DailyQuest(
        id: row['id'] as String,
        date: DateTime.parse(row['date'] as String),
        reviewWordIds: (row['review_word_ids'] as String)
            .split(',')
            .where((s) => s.isNotEmpty)
            .toList(),
        targetCount: row['target_count'] as int,
        isComplete: (row['is_complete'] as int) == 1,
        wordsReviewed: row['words_reviewed'] as int? ?? 0,
        correctCount: row['correct_count'] as int? ?? 0,
        completedAt: row['completed_at'] != null
            ? DateTime.tryParse(row['completed_at'] as String)
            : null,
      );

  // ── Helpers ──

  List<String> _splitSemicolon(dynamic value) {
    if (value == null) return [];
    final str = value.toString().trim();
    if (str.isEmpty) return [];
    return str.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }
}
