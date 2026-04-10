import '../local_db/database_service.dart';
import '../models/models.dart';

/// Manages per-word mastery progress.
///
/// Each word tracks mastery level (0-5), attempt counts, and review schedule.
class ProgressRepository {
  final DatabaseService _db;

  ProgressRepository(this._db);

  /// Get progress for a single word, or null if never seen.
  Future<WordProgress?> getProgress(String wordId) =>
      _db.getWordProgress(wordId);

  /// Get progress for all words that have been seen.
  Future<List<WordProgress>> getAllProgress() => _db.getAllWordProgress();

  /// Save/update progress for a word.
  Future<void> saveProgress(WordProgress progress) =>
      _db.saveWordProgress(progress);

  /// Get or create progress for a word (initializes at mastery 0 if new).
  Future<WordProgress> getOrCreate(String wordId) async {
    final existing = await _db.getWordProgress(wordId);
    if (existing != null) return existing;
    final fresh = WordProgress(wordId: wordId);
    await _db.saveWordProgress(fresh);
    return fresh;
  }

  /// Record that a word was introduced (learn card viewed).
  /// Sets mastery to 1 if currently 0.
  Future<WordProgress> markIntroduced(String wordId) async {
    final progress = await getOrCreate(wordId);
    final now = DateTime.now();

    progress.timesSeen++;
    progress.lastSeenAt = now;
    progress.firstSeenAt ??= now;

    if (progress.masteryLevel == 0) {
      progress.masteryLevel = 1;
      // Schedule first review for later today
      progress.nextReviewAt = now.add(const Duration(hours: 4));
    }

    await _db.saveWordProgress(progress);
    return progress;
  }

  /// Record a correct answer. May promote mastery level.
  Future<WordProgress> recordCorrect(
    String wordId,
    QuestionType questionType,
  ) async {
    final progress = await getOrCreate(wordId);
    final now = DateTime.now();

    progress.timesSeen++;
    progress.timesCorrect++;
    progress.lastSeenAt = now;

    // Promote mastery based on question type
    final newMastery = _calculatePromotion(progress.masteryLevel, questionType);
    if (newMastery > progress.masteryLevel) {
      progress.masteryLevel = newMastery;
    }

    // Schedule next review based on new mastery level
    progress.nextReviewAt = _nextReviewDate(now, progress.masteryLevel);

    await _db.saveWordProgress(progress);
    return progress;
  }

  /// Record an incorrect answer. May demote mastery level.
  Future<WordProgress> recordIncorrect(
    String wordId,
    QuestionType questionType,
  ) async {
    final progress = await getOrCreate(wordId);
    final now = DateTime.now();

    progress.timesSeen++;
    progress.timesIncorrect++;
    progress.lastSeenAt = now;

    // Demote by 1, but never below 1 (once introduced, stay introduced)
    if (progress.masteryLevel > 1) {
      progress.masteryLevel--;
    }

    // Review sooner after incorrect
    progress.nextReviewAt = now.add(const Duration(hours: 2));

    await _db.saveWordProgress(progress);
    return progress;
  }

  /// Get words at a specific mastery level.
  Future<List<WordProgress>> getWordsByMastery(int level) =>
      _db.getWordsByMastery(level);

  /// Count of words at each mastery level.
  Future<Map<int, int>> getMasteryCounts() => _db.getMasteryCounts();

  /// Total words introduced (mastery >= 1).
  Future<int> getIntroducedCount() => _db.getIntroducedWordCount();

  /// Total words fully mastered (mastery == 5).
  Future<int> getMasteredCount() => _db.getMasteredWordCount();

  /// Overall accuracy across all attempted words.
  Future<double> getOverallAccuracy() => _db.getOverallAccuracy();

  // ── Mastery promotion logic ──

  /// Determine if mastery should be promoted based on question type.
  ///
  /// Each question type maps to a mastery ceiling:
  ///   - Meaning Tap / Image Match → can promote up to 2 (recognized)
  ///   - Cue Recall → can promote up to 3 (recalled)
  ///   - Sentence Fix → can promote up to 4 (in-context)
  ///   - Multiple correct reviews → can reach 5 (mastered)
  int _calculatePromotion(int currentMastery, QuestionType type) {
    switch (type) {
      case QuestionType.meaningTap:
      case QuestionType.imageMatch:
        // Recognition — caps at mastery 2
        return currentMastery < 2 ? currentMastery + 1 : currentMastery;
      case QuestionType.cueRecall:
        // Recall — caps at mastery 3
        return currentMastery < 3 ? currentMastery + 1 : currentMastery;
      case QuestionType.sentenceFix:
        // Context usage — caps at mastery 4, or 5 if already at 4
        return currentMastery < 5 ? currentMastery + 1 : currentMastery;
    }
  }

  // ── Spaced repetition intervals ──

  /// Calculate next review date based on current mastery level.
  ///
  /// Intervals: same day, 1d, 3d, 7d, 14d, 30d, 60d
  DateTime _nextReviewDate(DateTime now, int masteryLevel) {
    switch (masteryLevel) {
      case 0:
      case 1:
        return now.add(const Duration(hours: 4)); // same day
      case 2:
        return now.add(const Duration(days: 1));
      case 3:
        return now.add(const Duration(days: 3));
      case 4:
        return now.add(const Duration(days: 7));
      case 5:
        return now.add(const Duration(days: 14));
      default:
        return now.add(const Duration(days: 30));
    }
  }
}
