import '../data/models/models.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/review_repository.dart';

/// Hidden spaced repetition scheduler.
///
/// Manages review timing using expanding intervals. The child sees
/// "quests" and "revisits" — never SRS terminology.
///
/// Intervals by mastery level:
///   1 (introduced)  → 4 hours  (same day)
///   2 (recognized)  → 1 day
///   3 (recalled)    → 3 days
///   4 (in context)  → 7 days
///   5 (mastered)    → 14 days, then 30 days, then 60 days
///
/// After incorrect answers, the review is brought forward (2 hours).
class ReviewScheduler {
  final ProgressRepository _progressRepo;
  final ReviewRepository _reviewRepo;

  ReviewScheduler(this._progressRepo, this._reviewRepo);

  // ═══════════════════════════════════════════════════════
  // Review interval calculation
  // ═══════════════════════════════════════════════════════

  /// The SRS intervals mapped to mastery level.
  static const Map<int, Duration> _intervals = {
    0: Duration(hours: 4),     // unseen → shouldn't happen, but safe default
    1: Duration(hours: 4),     // introduced → same day
    2: Duration(days: 1),      // recognized → 1 day
    3: Duration(days: 3),      // recalled → 3 days
    4: Duration(days: 7),      // in context → 7 days
    5: Duration(days: 14),     // mastered → 14 days (first review)
  };

  /// Extended intervals for mastered words on subsequent reviews.
  /// After the first 14-day review, space out further.
  static const List<Duration> _masteredIntervals = [
    Duration(days: 14),
    Duration(days: 30),
    Duration(days: 60),
  ];

  /// Calculate the next review date for a word based on its mastery level
  /// and how many times it has been correctly reviewed.
  static DateTime calculateNextReview(
    DateTime now,
    int masteryLevel, {
    int timesCorrect = 0,
  }) {
    if (masteryLevel >= 5) {
      // Mastered words use expanding intervals based on review count
      // timesCorrect roughly maps to which interval stage they're at
      final stage = (timesCorrect - 4).clamp(0, _masteredIntervals.length - 1);
      return now.add(_masteredIntervals[stage]);
    }

    final interval = _intervals[masteryLevel] ?? const Duration(hours: 4);
    return now.add(interval);
  }

  /// Calculate review date after an incorrect answer (sooner than normal).
  static DateTime calculateReviewAfterError(DateTime now) {
    return now.add(const Duration(hours: 2));
  }

  // ═══════════════════════════════════════════════════════
  // Due word queries
  // ═══════════════════════════════════════════════════════

  /// Get all words currently due for review.
  Future<List<WordProgress>> getDueWords({int limit = 15}) {
    return _reviewRepo.getDueWords(limit: limit);
  }

  /// Count of words currently due for review.
  Future<int> getDueWordCount() {
    return _reviewRepo.getDueWordCount();
  }

  /// Check if there are any words due for review right now.
  Future<bool> hasWordsToReview() async {
    final count = await getDueWordCount();
    return count > 0;
  }

  // ═══════════════════════════════════════════════════════
  // Daily quest generation
  // ═══════════════════════════════════════════════════════

  /// Get or create today's daily quest.
  ///
  /// Pulls from:
  ///   1. Words with nextReviewAt <= now (SRS due words)
  ///   2. Weak words (mastery 1-2) if not enough due words
  ///   3. Caps at 5-15 words per quest
  Future<DailyQuest> getTodayQuest() {
    return _reviewRepo.getOrCreateTodayQuest();
  }

  /// Whether today's quest has been completed.
  Future<bool> isTodayQuestComplete() {
    return _reviewRepo.isTodayQuestComplete();
  }

  /// Record an answer within the daily quest.
  Future<DailyQuest> recordQuestAnswer(
    DailyQuest quest,
    bool isCorrect,
  ) {
    return _reviewRepo.recordQuestAnswer(quest, isCorrect);
  }

  // ═══════════════════════════════════════════════════════
  // Review priority scoring
  // ═══════════════════════════════════════════════════════

  /// Score a word's review priority (higher = more urgent).
  ///
  /// Used to order the daily quest queue. Factors:
  ///   - How overdue the word is
  ///   - Lower mastery = higher priority
  ///   - More incorrect answers = higher priority
  static double reviewPriority(WordProgress progress) {
    double score = 0;

    // Overdue bonus: how many hours past the review date
    if (progress.nextReviewAt != null) {
      final overdue =
          DateTime.now().difference(progress.nextReviewAt!).inHours;
      if (overdue > 0) {
        score += overdue.clamp(0, 168).toDouble(); // cap at 1 week
      }
    }

    // Lower mastery = higher priority (invert: mastery 1 → +40, mastery 4 → +10)
    score += (5 - progress.masteryLevel) * 10;

    // Error-prone words get priority
    if (progress.timesIncorrect > 0) {
      final errorRate = progress.timesIncorrect /
          (progress.timesCorrect + progress.timesIncorrect);
      score += errorRate * 20;
    }

    return score;
  }

  /// Sort a list of word progress by review priority (most urgent first).
  static List<WordProgress> sortByPriority(List<WordProgress> words) {
    return [...words]..sort(
        (a, b) => reviewPriority(b).compareTo(reviewPriority(a)),
      );
  }

  // ═══════════════════════════════════════════════════════
  // Stats
  // ═══════════════════════════════════════════════════════

  /// Get a summary of the review queue status.
  Future<ReviewQueueStatus> getQueueStatus() async {
    final dueNow = await getDueWordCount();
    final masteryCounts = await _progressRepo.getMasteryCounts();
    final totalIntroduced = await _progressRepo.getIntroducedCount();
    final totalMastered = await _progressRepo.getMasteredCount();

    return ReviewQueueStatus(
      dueNow: dueNow,
      totalIntroduced: totalIntroduced,
      totalMastered: totalMastered,
      masteryCounts: masteryCounts,
    );
  }
}

/// Snapshot of the review queue for display on the home screen.
class ReviewQueueStatus {
  final int dueNow;
  final int totalIntroduced;
  final int totalMastered;
  final Map<int, int> masteryCounts;

  const ReviewQueueStatus({
    required this.dueNow,
    required this.totalIntroduced,
    required this.totalMastered,
    required this.masteryCounts,
  });

  /// Words currently being learned (mastery 1-4).
  int get inProgress =>
      totalIntroduced - totalMastered - (masteryCounts[0] ?? 0);

  /// Percentage of introduced words that are mastered.
  double get masteryRate {
    if (totalIntroduced == 0) return 0.0;
    return totalMastered / totalIntroduced;
  }

  @override
  String toString() =>
      'ReviewQueueStatus(due=$dueNow, introduced=$totalIntroduced, mastered=$totalMastered)';
}
