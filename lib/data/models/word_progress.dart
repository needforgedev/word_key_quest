/// Tracks a child's learning progress for a single word.
///
/// Mutable — updated each time the word is seen or answered in a mini-game.
/// Persisted to local database.
class WordProgress {
  final String wordId;
  int masteryLevel; // 0=unseen, 1=introduced, 2=recognized, 3=recalled, 4=in-context, 5=mastered
  int timesSeen;
  int timesCorrect;
  int timesIncorrect;
  DateTime? lastSeenAt;
  DateTime? nextReviewAt;
  DateTime? firstSeenAt;

  WordProgress({
    required this.wordId,
    this.masteryLevel = 0,
    this.timesSeen = 0,
    this.timesCorrect = 0,
    this.timesIncorrect = 0,
    this.lastSeenAt,
    this.nextReviewAt,
    this.firstSeenAt,
  });

  bool get isUnseen => masteryLevel == 0;
  bool get isIntroduced => masteryLevel >= 1;
  bool get isMastered => masteryLevel >= 5;
  bool get needsReview =>
      nextReviewAt != null && DateTime.now().isAfter(nextReviewAt!);

  double get accuracy {
    final total = timesCorrect + timesIncorrect;
    if (total == 0) return 0.0;
    return timesCorrect / total;
  }

  factory WordProgress.fromJson(Map<String, dynamic> json) {
    return WordProgress(
      wordId: json['wordId'] as String,
      masteryLevel: json['masteryLevel'] as int? ?? 0,
      timesSeen: json['timesSeen'] as int? ?? 0,
      timesCorrect: json['timesCorrect'] as int? ?? 0,
      timesIncorrect: json['timesIncorrect'] as int? ?? 0,
      lastSeenAt: _parseDateTime(json['lastSeenAt']),
      nextReviewAt: _parseDateTime(json['nextReviewAt']),
      firstSeenAt: _parseDateTime(json['firstSeenAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'wordId': wordId,
        'masteryLevel': masteryLevel,
        'timesSeen': timesSeen,
        'timesCorrect': timesCorrect,
        'timesIncorrect': timesIncorrect,
        'lastSeenAt': lastSeenAt?.toIso8601String(),
        'nextReviewAt': nextReviewAt?.toIso8601String(),
        'firstSeenAt': firstSeenAt?.toIso8601String(),
      };

  WordProgress copyWith({
    int? masteryLevel,
    int? timesSeen,
    int? timesCorrect,
    int? timesIncorrect,
    DateTime? lastSeenAt,
    DateTime? nextReviewAt,
    DateTime? firstSeenAt,
  }) {
    return WordProgress(
      wordId: wordId,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      timesSeen: timesSeen ?? this.timesSeen,
      timesCorrect: timesCorrect ?? this.timesCorrect,
      timesIncorrect: timesIncorrect ?? this.timesIncorrect,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  String toString() => 'WordProgress($wordId, mastery=$masteryLevel)';
}
