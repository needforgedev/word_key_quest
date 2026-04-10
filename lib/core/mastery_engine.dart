import '../data/models/models.dart';
import '../data/repositories/progress_repository.dart';

/// Mastery level definitions:
///   0 = unseen
///   1 = introduced (learn card viewed)
///   2 = recognized (Meaning Tap / Image Match correct)
///   3 = recalled from cue (Cue Recall correct)
///   4 = used in context (Sentence Fix correct)
///   5 = mastered (correct across multiple review sessions)
///
/// Promotion rules:
///   - Each question type has a mastery ceiling it can promote to.
///   - Promotion to level 5 requires the word to have been correct
///     in at least 2 separate review sessions (not just one lucky answer).
///   - Wrong answers demote by 1, with a floor of 1 (once introduced,
///     a word never returns to "unseen").
///
/// This engine is the central authority for mastery transitions.
/// Repositories handle persistence; this class handles the rules.
class MasteryEngine {
  final ProgressRepository _progressRepo;

  MasteryEngine(this._progressRepo);

  // ═══════════════════════════════════════════════════════
  // Core transitions
  // ═══════════════════════════════════════════════════════

  /// Mark a word as introduced (learn card was viewed).
  /// Transitions mastery from 0 → 1.
  Future<WordProgress> introduceWord(String wordId) {
    return _progressRepo.markIntroduced(wordId);
  }

  /// Process a correct answer from a mini-game.
  /// Returns the updated progress with potentially promoted mastery.
  Future<MasteryResult> recordCorrectAnswer(
    String wordId,
    QuestionType questionType,
  ) async {
    final before = await _progressRepo.getOrCreate(wordId);
    final beforeLevel = before.masteryLevel;

    final after = await _progressRepo.recordCorrect(wordId, questionType);
    final promoted = after.masteryLevel > beforeLevel;

    return MasteryResult(
      wordId: wordId,
      previousLevel: beforeLevel,
      newLevel: after.masteryLevel,
      wasPromoted: promoted,
      progress: after,
    );
  }

  /// Process an incorrect answer from a mini-game.
  /// Returns the updated progress with potentially demoted mastery.
  Future<MasteryResult> recordIncorrectAnswer(
    String wordId,
    QuestionType questionType,
  ) async {
    final before = await _progressRepo.getOrCreate(wordId);
    final beforeLevel = before.masteryLevel;

    final after = await _progressRepo.recordIncorrect(wordId, questionType);
    final demoted = after.masteryLevel < beforeLevel;

    return MasteryResult(
      wordId: wordId,
      previousLevel: beforeLevel,
      newLevel: after.masteryLevel,
      wasPromoted: false,
      wasDemoted: demoted,
      progress: after,
    );
  }

  // ═══════════════════════════════════════════════════════
  // Batch operations
  // ═══════════════════════════════════════════════════════

  /// Introduce multiple words at once (e.g., all words in a level).
  Future<List<WordProgress>> introduceWords(List<String> wordIds) async {
    final results = <WordProgress>[];
    for (final id in wordIds) {
      results.add(await introduceWord(id));
    }
    return results;
  }

  /// Process a full question result from a mini-game.
  Future<MasteryResult> processQuestionResult(QuestionResult result) {
    if (result.isCorrect) {
      return recordCorrectAnswer(result.wordId, result.type);
    } else {
      return recordIncorrectAnswer(result.wordId, result.type);
    }
  }

  /// Process all results from a completed level session.
  /// Returns a summary of mastery changes.
  Future<SessionMasterySummary> processSessionResults(
      LevelSession session) async {
    final results = <MasteryResult>[];

    for (final questionResult in session.results) {
      final masteryResult = await processQuestionResult(questionResult);
      results.add(masteryResult);
    }

    return SessionMasterySummary(
      results: results,
      wordsPromoted: results.where((r) => r.wasPromoted).length,
      wordsDemoted: results.where((r) => r.wasDemoted).length,
      newlyMastered:
          results.where((r) => r.wasPromoted && r.newLevel == 5).length,
    );
  }

  // ═══════════════════════════════════════════════════════
  // Query helpers
  // ═══════════════════════════════════════════════════════

  /// Get the mastery level for a word (0 if never seen).
  Future<int> getMasteryLevel(String wordId) async {
    final progress = await _progressRepo.getProgress(wordId);
    return progress?.masteryLevel ?? 0;
  }

  /// Get mastery levels for multiple words.
  Future<Map<String, int>> getMasteryLevels(List<String> wordIds) async {
    final map = <String, int>{};
    for (final id in wordIds) {
      final progress = await _progressRepo.getProgress(id);
      map[id] = progress?.masteryLevel ?? 0;
    }
    return map;
  }

  /// Human-readable label for a mastery level.
  static String masteryLabel(int level) {
    switch (level) {
      case 0:
        return 'Unseen';
      case 1:
        return 'Introduced';
      case 2:
        return 'Recognized';
      case 3:
        return 'Recalled';
      case 4:
        return 'In Context';
      case 5:
        return 'Mastered';
      default:
        return 'Unknown';
    }
  }

  /// The maximum mastery level a question type can promote to.
  static int maxMasteryForQuestionType(QuestionType type) {
    switch (type) {
      case QuestionType.meaningTap:
      case QuestionType.imageMatch:
        return 2; // recognition
      case QuestionType.cueRecall:
        return 3; // recall
      case QuestionType.sentenceFix:
        return 5; // context usage → can reach mastered
    }
  }

  /// Which question types are appropriate for a word at a given mastery level.
  /// Lower mastery → easier games. Higher mastery → harder games.
  static List<QuestionType> appropriateQuestionTypes(int masteryLevel) {
    switch (masteryLevel) {
      case 0:
      case 1:
        // Just introduced — start with recognition
        return [QuestionType.meaningTap, QuestionType.imageMatch];
      case 2:
        // Recognized — add cue recall
        return [
          QuestionType.meaningTap,
          QuestionType.imageMatch,
          QuestionType.cueRecall,
        ];
      case 3:
        // Recalled — add sentence fix
        return [
          QuestionType.cueRecall,
          QuestionType.sentenceFix,
        ];
      case 4:
      case 5:
        // In context / mastered — focus on harder games for review
        return [
          QuestionType.cueRecall,
          QuestionType.sentenceFix,
        ];
      default:
        return QuestionType.values;
    }
  }
}

/// The result of a single mastery transition.
class MasteryResult {
  final String wordId;
  final int previousLevel;
  final int newLevel;
  final bool wasPromoted;
  final bool wasDemoted;
  final WordProgress progress;

  const MasteryResult({
    required this.wordId,
    required this.previousLevel,
    required this.newLevel,
    this.wasPromoted = false,
    this.wasDemoted = false,
    required this.progress,
  });

  bool get levelChanged => previousLevel != newLevel;

  @override
  String toString() =>
      'MasteryResult($wordId: $previousLevel→$newLevel, promoted=$wasPromoted, demoted=$wasDemoted)';
}

/// Summary of all mastery changes from a completed session.
class SessionMasterySummary {
  final List<MasteryResult> results;
  final int wordsPromoted;
  final int wordsDemoted;
  final int newlyMastered;

  const SessionMasterySummary({
    required this.results,
    required this.wordsPromoted,
    required this.wordsDemoted,
    required this.newlyMastered,
  });

  int get totalAnswered => results.length;
  int get correctCount => results.where((r) => r.progress.timesCorrect > 0).length;

  @override
  String toString() =>
      'SessionMasterySummary(answered=$totalAnswered, promoted=$wordsPromoted, demoted=$wordsDemoted, mastered=$newlyMastered)';
}
