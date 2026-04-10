/// The type of mini-game question.
enum QuestionType {
  meaningTap,
  imageMatch,
  cueRecall,
  sentenceFix,
}

/// A single question presented during a level session or daily quest.
class QuestionItem {
  final String wordId;
  final QuestionType type;
  final String prompt;
  final String correctAnswer;
  final List<String> choices; // includes correct answer
  final int correctIndex;

  const QuestionItem({
    required this.wordId,
    required this.type,
    required this.prompt,
    required this.correctAnswer,
    required this.choices,
    required this.correctIndex,
  });

  Map<String, dynamic> toJson() => {
        'wordId': wordId,
        'type': type.name,
        'prompt': prompt,
        'correctAnswer': correctAnswer,
        'choices': choices,
        'correctIndex': correctIndex,
      };
}

/// The result of answering a single question.
class QuestionResult {
  final String wordId;
  final QuestionType type;
  final bool isCorrect;
  final int selectedIndex;
  final Duration responseTime;
  final DateTime answeredAt;

  const QuestionResult({
    required this.wordId,
    required this.type,
    required this.isCorrect,
    required this.selectedIndex,
    required this.responseTime,
    required this.answeredAt,
  });

  Map<String, dynamic> toJson() => {
        'wordId': wordId,
        'type': type.name,
        'isCorrect': isCorrect,
        'selectedIndex': selectedIndex,
        'responseTimeMs': responseTime.inMilliseconds,
        'answeredAt': answeredAt.toIso8601String(),
      };
}

/// Tracks the state of an active level or review session.
class LevelSession {
  final String levelId; // level_X or 'daily_quest'
  final int worldIndex;
  final int levelIndex;
  final List<String> newWordIds;
  final List<String> reviewWordIds;
  final List<QuestionItem> questions;
  final List<QuestionResult> results;
  final DateTime startedAt;
  DateTime? completedAt;

  LevelSession({
    required this.levelId,
    required this.worldIndex,
    required this.levelIndex,
    required this.newWordIds,
    this.reviewWordIds = const [],
    this.questions = const [],
    List<QuestionResult>? results,
    DateTime? startedAt,
    this.completedAt,
  })  : results = results ?? [],
        startedAt = startedAt ?? DateTime.now();

  bool get isComplete => completedAt != null;
  bool get isDailyQuest => levelId == 'daily_quest';

  int get totalQuestions => questions.length;
  int get answeredCount => results.length;
  int get correctCount => results.where((r) => r.isCorrect).length;
  int get remainingCount => totalQuestions - answeredCount;

  double get accuracy {
    if (answeredCount == 0) return 0.0;
    return correctCount / answeredCount;
  }

  /// Star rating (1-3) based on accuracy.
  int get starRating {
    if (accuracy >= 0.9) return 3;
    if (accuracy >= 0.7) return 2;
    return 1;
  }

  /// All unique word IDs in this session (new + review).
  List<String> get allWordIds => [...newWordIds, ...reviewWordIds];

  Map<String, dynamic> toJson() => {
        'levelId': levelId,
        'worldIndex': worldIndex,
        'levelIndex': levelIndex,
        'newWordIds': newWordIds,
        'reviewWordIds': reviewWordIds,
        'results': results.map((r) => r.toJson()).toList(),
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'accuracy': accuracy,
        'starRating': starRating,
      };

  @override
  String toString() =>
      'LevelSession($levelId, answered=$answeredCount/$totalQuestions)';
}
