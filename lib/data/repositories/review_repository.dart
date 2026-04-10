import '../local_db/database_service.dart';
import '../models/models.dart';

/// Manages the spaced repetition review queue and daily quest generation.
///
/// Words are surfaced for review based on their `nextReviewAt` timestamp,
/// presented to the child as "quests" rather than SRS sessions.
class ReviewRepository {
  final DatabaseService _db;

  ReviewRepository(this._db);

  /// Get all words currently due for review.
  Future<List<WordProgress>> getDueWords({int limit = 15}) =>
      _db.getDueReviewWords(limit: limit);

  /// Count of words currently due for review.
  Future<int> getDueWordCount() async {
    final due = await _db.getDueReviewWords(limit: 1000);
    return due.length;
  }

  /// Get today's daily quest. Creates one if it doesn't exist yet.
  Future<DailyQuest> getOrCreateTodayQuest() async {
    final today = DateTime.now();
    final existing = await _db.getDailyQuestForDate(today);
    if (existing != null) return existing;

    // Generate a new quest from due review words
    final dueWords = await _db.getDueReviewWords(limit: 15);
    final wordIds = dueWords.map((w) => w.wordId).toList();

    // If not enough due words, pad with weak words (mastery 1-2)
    if (wordIds.length < 5) {
      final weakWords = await _db.getWordsByMastery(1);
      final weakWords2 = await _db.getWordsByMastery(2);
      final candidates = [...weakWords, ...weakWords2]
          .where((w) => !wordIds.contains(w.wordId))
          .take(10 - wordIds.length);
      wordIds.addAll(candidates.map((w) => w.wordId));
    }

    // Cap at 5-15 words
    final targetCount = wordIds.length.clamp(5, 15);
    final questWords = wordIds.take(targetCount).toList();

    final quest = DailyQuest(
      id: 'quest_${_dateStr(today)}',
      date: today,
      reviewWordIds: questWords,
      targetCount: questWords.length,
    );

    await _db.saveDailyQuest(quest);
    return quest;
  }

  /// Update daily quest progress after answering a word.
  Future<DailyQuest> recordQuestAnswer(
      DailyQuest quest, bool isCorrect) async {
    quest.wordsReviewed++;
    if (isCorrect) quest.correctCount++;

    if (quest.wordsReviewed >= quest.targetCount) {
      quest.isComplete = true;
      quest.completedAt = DateTime.now();
    }

    await _db.saveDailyQuest(quest);
    return quest;
  }

  /// Check if today's quest has been completed.
  Future<bool> isTodayQuestComplete() async {
    final quest = await _db.getDailyQuestForDate(DateTime.now());
    return quest?.isComplete ?? false;
  }

  String _dateStr(DateTime dt) =>
      '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}';
}
