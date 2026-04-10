/// A daily review session generated from due words in the spaced repetition queue.
///
/// Presented to the child as a "quest" — never as an SRS review session.
class DailyQuest {
  final String id;
  final DateTime date;
  final List<String> reviewWordIds;
  final int targetCount;
  bool isComplete;
  int wordsReviewed;
  int correctCount;
  DateTime? completedAt;

  DailyQuest({
    required this.id,
    required this.date,
    required this.reviewWordIds,
    int? targetCount,
    this.isComplete = false,
    this.wordsReviewed = 0,
    this.correctCount = 0,
    this.completedAt,
  }) : targetCount = targetCount ?? reviewWordIds.length;

  /// How many words are waiting to be reviewed.
  int get remainingCount => targetCount - wordsReviewed;

  /// Accuracy for this quest session.
  double get accuracy {
    if (wordsReviewed == 0) return 0.0;
    return correctCount / wordsReviewed;
  }

  /// Estimated time in minutes (roughly 30s per word).
  int get estimatedMinutes => (targetCount * 0.5).ceil().clamp(1, 15);

  factory DailyQuest.fromJson(Map<String, dynamic> json) {
    return DailyQuest(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      reviewWordIds: (json['reviewWordIds'] as List).cast<String>(),
      targetCount: json['targetCount'] as int?,
      isComplete: json['isComplete'] as bool? ?? false,
      wordsReviewed: json['wordsReviewed'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'reviewWordIds': reviewWordIds,
        'targetCount': targetCount,
        'isComplete': isComplete,
        'wordsReviewed': wordsReviewed,
        'correctCount': correctCount,
        'completedAt': completedAt?.toIso8601String(),
      };

  @override
  String toString() =>
      'DailyQuest($id, ${reviewWordIds.length} words, complete=$isComplete)';
}
