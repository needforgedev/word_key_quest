import 'dart:collection';

import '../data/models/models.dart';

/// Adaptive difficulty controller.
///
/// Monitors the child's rolling accuracy and adjusts gameplay parameters:
///   - Number of new words per level
///   - Number of review words per level
///   - Mini-game type distribution (bias toward weak areas)
///
/// The child never sees difficulty labels — this runs silently behind
/// the session manager and question engine.
class DifficultyController {
  // ── Configurable thresholds ──

  /// Below this accuracy, reduce new words and increase review.
  static const double _struggleThreshold = 0.60;

  /// Above this accuracy, increase harder question types.
  static const double _cruisingThreshold = 0.85;

  /// How many recent results to track for rolling accuracy.
  static const int _windowSize = 20;

  /// Default new words per level.
  static const int _defaultNewWords = 10;

  /// Default review words per level.
  static const int _defaultReviewWords = 3;

  // ── Rolling accuracy window ──

  final Queue<_AnswerRecord> _recentAnswers = Queue();

  // ── Per-game-type accuracy tracking ──

  final Map<QuestionType, _TypeAccuracy> _typeAccuracy = {
    for (final type in QuestionType.values) type: _TypeAccuracy(),
  };

  // ═══════════════════════════════════════════════════════
  // Record answers
  // ═══════════════════════════════════════════════════════

  /// Record a question result into the rolling window.
  void recordAnswer(QuestionResult result) {
    _recentAnswers.addLast(_AnswerRecord(
      type: result.type,
      isCorrect: result.isCorrect,
    ));

    // Trim to window size
    while (_recentAnswers.length > _windowSize) {
      _recentAnswers.removeFirst();
    }

    // Update per-type tracking
    _typeAccuracy[result.type]!.record(result.isCorrect);
  }

  /// Record a batch of results (e.g., from a completed session).
  void recordAnswers(List<QuestionResult> results) {
    for (final r in results) {
      recordAnswer(r);
    }
  }

  // ═══════════════════════════════════════════════════════
  // Current state
  // ═══════════════════════════════════════════════════════

  /// Rolling accuracy over the last [_windowSize] answers.
  double get rollingAccuracy {
    if (_recentAnswers.isEmpty) return 1.0; // assume good until proven otherwise
    final correct = _recentAnswers.where((a) => a.isCorrect).length;
    return correct / _recentAnswers.length;
  }

  /// Whether the child is struggling (accuracy below threshold).
  bool get isStruggling => rollingAccuracy < _struggleThreshold;

  /// Whether the child is cruising (accuracy above threshold).
  bool get isCruising => rollingAccuracy > _cruisingThreshold;

  /// Current difficulty profile based on rolling accuracy.
  DifficultyProfile get currentProfile {
    if (isStruggling) return DifficultyProfile.supportive;
    if (isCruising) return DifficultyProfile.challenging;
    return DifficultyProfile.standard;
  }

  /// Accuracy for a specific question type.
  double typeAccuracy(QuestionType type) {
    return _typeAccuracy[type]!.accuracy;
  }

  /// The weakest question type (lowest accuracy).
  QuestionType get weakestType {
    QuestionType weakest = QuestionType.meaningTap;
    double lowest = 1.0;

    for (final entry in _typeAccuracy.entries) {
      if (entry.value.totalAttempts > 0 && entry.value.accuracy < lowest) {
        lowest = entry.value.accuracy;
        weakest = entry.key;
      }
    }

    return weakest;
  }

  /// The strongest question type (highest accuracy).
  QuestionType get strongestType {
    QuestionType strongest = QuestionType.meaningTap;
    double highest = 0.0;

    for (final entry in _typeAccuracy.entries) {
      if (entry.value.totalAttempts > 0 && entry.value.accuracy > highest) {
        highest = entry.value.accuracy;
        strongest = entry.key;
      }
    }

    return strongest;
  }

  // ═══════════════════════════════════════════════════════
  // Level parameters
  // ═══════════════════════════════════════════════════════

  /// How many new words to introduce in the next level.
  int get newWordsPerLevel {
    if (isStruggling) return 7; // fewer new words when struggling
    return _defaultNewWords;
  }

  /// How many review words to include in the next level.
  int get reviewWordsPerLevel {
    if (isStruggling) return 6; // more review when struggling
    if (isCruising) return 2; // less review when cruising
    return _defaultReviewWords;
  }

  // ═══════════════════════════════════════════════════════
  // Question type distribution
  // ═══════════════════════════════════════════════════════

  /// Select the best question type for a word based on current difficulty.
  ///
  /// [masteryLevel] is the word's current mastery (determines valid types).
  /// [index] is the question's position in the session (for variety).
  QuestionType selectQuestionType(int masteryLevel, int index) {
    // Get valid types for this mastery level
    final validTypes = _validTypesForMastery(masteryLevel);

    if (isStruggling) {
      // When struggling: bias toward easier types (recognition)
      return _biasEasier(validTypes, index);
    }

    if (isCruising) {
      // When cruising: bias toward harder types and weak areas
      return _biasHarder(validTypes, index);
    }

    // Standard: cycle through valid types with some bias toward weak areas
    return _balancedSelection(validTypes, index);
  }

  /// Get the distribution of question types for an entire level.
  List<QuestionType> generateTypeDistribution(
    int wordCount, {
    List<int>? masteryLevels,
  }) {
    return List.generate(wordCount, (i) {
      final mastery = masteryLevels != null && i < masteryLevels.length
          ? masteryLevels[i]
          : 1;
      return selectQuestionType(mastery, i);
    });
  }

  // ═══════════════════════════════════════════════════════
  // Private helpers
  // ═══════════════════════════════════════════════════════

  List<QuestionType> _validTypesForMastery(int mastery) {
    switch (mastery) {
      case 0:
      case 1:
        return [QuestionType.meaningTap, QuestionType.imageMatch];
      case 2:
        return [
          QuestionType.meaningTap,
          QuestionType.imageMatch,
          QuestionType.cueRecall,
        ];
      case 3:
        return [QuestionType.cueRecall, QuestionType.sentenceFix];
      case 4:
      case 5:
        return [QuestionType.cueRecall, QuestionType.sentenceFix];
      default:
        return QuestionType.values;
    }
  }

  /// Bias toward easier types (first in the valid list).
  QuestionType _biasEasier(List<QuestionType> validTypes, int index) {
    // 70% chance of the easiest valid type
    if (index % 10 < 7) return validTypes.first;
    return validTypes[index % validTypes.length];
  }

  /// Bias toward harder types and the child's weakest area.
  QuestionType _biasHarder(List<QuestionType> validTypes, int index) {
    // If the weakest type is valid, bias 40% toward it
    if (validTypes.contains(weakestType) && index % 5 < 2) {
      return weakestType;
    }
    // Otherwise prefer the hardest valid type
    return validTypes.last;
  }

  /// Balanced selection with slight bias toward weak areas.
  QuestionType _balancedSelection(List<QuestionType> validTypes, int index) {
    // Every 4th question, target the weakest type if valid
    if (index % 4 == 3 && validTypes.contains(weakestType)) {
      return weakestType;
    }
    // Otherwise cycle through valid types
    return validTypes[index % validTypes.length];
  }

  // ═══════════════════════════════════════════════════════
  // Snapshot for debugging / parent dashboard
  // ═══════════════════════════════════════════════════════

  DifficultySnapshot getSnapshot() {
    return DifficultySnapshot(
      rollingAccuracy: rollingAccuracy,
      profile: currentProfile,
      newWordsPerLevel: newWordsPerLevel,
      reviewWordsPerLevel: reviewWordsPerLevel,
      weakestType: weakestType,
      strongestType: strongestType,
      typeAccuracies: {
        for (final entry in _typeAccuracy.entries)
          entry.key: entry.value.accuracy,
      },
      windowSize: _recentAnswers.length,
    );
  }
}

// ═══════════════════════════════════════════════════════
// Supporting types
// ═══════════════════════════════════════════════════════

/// The three difficulty profiles the controller can be in.
enum DifficultyProfile {
  /// Accuracy < 60%: fewer new words, more review, easier games.
  supportive,

  /// Accuracy 60-85%: default parameters.
  standard,

  /// Accuracy > 85%: harder games, bias toward weak areas.
  challenging,
}

/// Tracks accuracy for a single question type.
class _TypeAccuracy {
  int _correct = 0;
  int _total = 0;

  void record(bool isCorrect) {
    _total++;
    if (isCorrect) _correct++;
  }

  double get accuracy => _total == 0 ? 1.0 : _correct / _total;
  int get totalAttempts => _total;
}

/// A single answer in the rolling window.
class _AnswerRecord {
  final QuestionType type;
  final bool isCorrect;

  const _AnswerRecord({required this.type, required this.isCorrect});
}

/// Diagnostic snapshot for parent dashboard or debugging.
class DifficultySnapshot {
  final double rollingAccuracy;
  final DifficultyProfile profile;
  final int newWordsPerLevel;
  final int reviewWordsPerLevel;
  final QuestionType weakestType;
  final QuestionType strongestType;
  final Map<QuestionType, double> typeAccuracies;
  final int windowSize;

  const DifficultySnapshot({
    required this.rollingAccuracy,
    required this.profile,
    required this.newWordsPerLevel,
    required this.reviewWordsPerLevel,
    required this.weakestType,
    required this.strongestType,
    required this.typeAccuracies,
    required this.windowSize,
  });

  @override
  String toString() =>
      'DifficultySnapshot(accuracy=${(rollingAccuracy * 100).toStringAsFixed(0)}%, profile=$profile, new=$newWordsPerLevel, review=$reviewWordsPerLevel)';
}
