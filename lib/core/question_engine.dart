import 'dart:math';

import '../data/models/models.dart';
import '../data/repositories/content_repository.dart';

/// Generates quiz questions for all four mini-game types.
///
/// Each generator takes the target word and produces a [QuestionItem]
/// with the correct answer and 2 plausible distractors.
///
/// Distractor strategy:
///   - Prefer same part of speech so choices look plausible
///   - Avoid using antonyms of each other (too easy to eliminate)
///   - Shuffle choice order so the correct answer isn't always first
class QuestionEngine {
  final ContentRepository _contentRepo;
  final Random _random;

  QuestionEngine(this._contentRepo, {Random? random})
      : _random = random ?? Random();

  // ═══════════════════════════════════════════════════════
  // Meaning Tap
  // ═══════════════════════════════════════════════════════

  /// Generate a "pick the correct meaning" question.
  ///
  /// Prompt: the word itself
  /// Correct answer: the word's kidsMeaning
  /// Distractors: kidsMeanings from 2 other words
  Future<QuestionItem> generateMeaningTap(WordEntry word) async {
    final distractors = await _getDistractorWords(word, 2);

    final choices = <String>[
      word.kidsMeaning,
      ...distractors.map((d) => d.kidsMeaning),
    ];

    return _buildQuestion(
      wordId: word.id,
      type: QuestionType.meaningTap,
      prompt: word.word,
      correctAnswer: word.kidsMeaning,
      choices: choices,
    );
  }

  // ═══════════════════════════════════════════════════════
  // Image Match
  // ═══════════════════════════════════════════════════════

  /// Generate a "pick the correct image" question.
  ///
  /// Prompt: the word or its meaning
  /// Correct answer: the word's ID (UI resolves to image)
  /// Distractors: IDs of 2 other words (UI resolves their images)
  Future<QuestionItem> generateImageMatch(WordEntry word) async {
    final distractors = await _getDistractorWords(word, 3);

    final choices = <String>[
      word.id,
      ...distractors.map((d) => d.id),
    ];

    return _buildQuestion(
      wordId: word.id,
      type: QuestionType.imageMatch,
      prompt: 'Which picture shows "${word.word}"?',
      correctAnswer: word.id,
      choices: choices,
    );
  }

  // ═══════════════════════════════════════════════════════
  // Cue Recall
  // ═══════════════════════════════════════════════════════

  /// Generate a "which word fits this cue" question.
  ///
  /// Prompt: the word's cue or a fragment of the memoryKey
  /// Correct answer: the word itself
  /// Distractors: 2 other words (similar sourceRank range)
  Future<QuestionItem> generateCueRecall(WordEntry word) async {
    final distractors = await _getDistractorWords(word, 2);

    // Use the cue as the prompt; fall back to a memoryKey fragment
    final prompt = word.cue.isNotEmpty
        ? word.cue
        : _extractCueFragment(word.memoryKey);

    final choices = <String>[
      word.word,
      ...distractors.map((d) => d.word),
    ];

    return _buildQuestion(
      wordId: word.id,
      type: QuestionType.cueRecall,
      prompt: prompt,
      correctAnswer: word.word,
      choices: choices,
    );
  }

  // ═══════════════════════════════════════════════════════
  // Sentence Fix
  // ═══════════════════════════════════════════════════════

  /// Generate a "fill in the blank" question.
  ///
  /// Prompt: usage sentence with the word blanked out
  /// Correct answer: the word itself
  /// Distractors: 2 other words (same part of speech preferred)
  Future<QuestionItem> generateSentenceFix(WordEntry word) async {
    final distractors = await _getDistractorWords(word, 2);

    // Use the sentence with blank, or fall back to a generic prompt
    final prompt = word.sentenceWithBlank.isNotEmpty
        ? word.sentenceWithBlank
        : 'The _______ was very ${word.kidsMeaning}.';

    final choices = <String>[
      word.word,
      ...distractors.map((d) => d.word),
    ];

    return _buildQuestion(
      wordId: word.id,
      type: QuestionType.sentenceFix,
      prompt: prompt,
      correctAnswer: word.word,
      choices: choices,
    );
  }

  // ═══════════════════════════════════════════════════════
  // Generate by type
  // ═══════════════════════════════════════════════════════

  /// Generate a question for a specific mini-game type.
  Future<QuestionItem> generate(WordEntry word, QuestionType type) {
    switch (type) {
      case QuestionType.meaningTap:
        return generateMeaningTap(word);
      case QuestionType.imageMatch:
        return generateImageMatch(word);
      case QuestionType.cueRecall:
        return generateCueRecall(word);
      case QuestionType.sentenceFix:
        return generateSentenceFix(word);
    }
  }

  /// Generate a batch of questions for a list of words.
  ///
  /// [typeSelector] decides which game type each word gets.
  /// If null, picks a random appropriate type based on the word index.
  Future<List<QuestionItem>> generateBatch(
    List<WordEntry> words, {
    QuestionType Function(int index, WordEntry word)? typeSelector,
  }) async {
    final questions = <QuestionItem>[];

    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      final type = typeSelector?.call(i, word) ?? _defaultTypeForIndex(i);
      questions.add(await generate(word, type));
    }

    return questions;
  }

  /// Generate questions for a level session.
  ///
  /// Creates one question per word, cycling through game types
  /// in order: MeaningTap → ImageMatch → CueRecall → SentenceFix.
  Future<List<QuestionItem>> generateForLevel(List<WordEntry> words) {
    return generateBatch(words, typeSelector: (i, _) => _defaultTypeForIndex(i));
  }

  // ═══════════════════════════════════════════════════════
  // Score calculation
  // ═══════════════════════════════════════════════════════

  /// Calculate star rating (1-3) from accuracy percentage.
  static int calculateStars(double accuracy) {
    if (accuracy >= 0.9) return 3;
    if (accuracy >= 0.7) return 2;
    return 1;
  }

  /// Calculate bonus points from response time.
  /// Faster answers get more bonus (max 10 per question).
  static int calculateTimeBonus(Duration responseTime) {
    if (responseTime.inSeconds <= 3) return 10;
    if (responseTime.inSeconds <= 5) return 7;
    if (responseTime.inSeconds <= 8) return 4;
    if (responseTime.inSeconds <= 12) return 2;
    return 0;
  }

  /// Calculate total stars earned for a session.
  static int calculateSessionStars(List<QuestionResult> results) {
    if (results.isEmpty) return 1;
    final correct = results.where((r) => r.isCorrect).length;
    final accuracy = correct / results.length;
    return calculateStars(accuracy);
  }

  // ═══════════════════════════════════════════════════════
  // Private helpers
  // ═══════════════════════════════════════════════════════

  /// Get distractor words, preferring same part of speech.
  Future<List<WordEntry>> _getDistractorWords(
    WordEntry target,
    int count,
  ) async {
    List<WordEntry> distractors;

    if (target.partOfSpeech.isNotEmpty) {
      distractors = await _contentRepo.getDistractorsBySpeech(
        target.partOfSpeech,
        count,
        excludeIds: [target.id],
      );
    } else {
      distractors = await _contentRepo.getDistractors(
        count,
        excludeIds: [target.id],
      );
    }

    // Filter out words whose meanings are too similar (antonyms of correct)
    if (target.antonyms.isNotEmpty) {
      distractors = distractors.where((d) {
        // Don't use a word if it's an antonym of the target
        return !target.antonyms
            .any((ant) => d.word.toLowerCase() == ant.toLowerCase());
      }).toList();

      // If filtering removed too many, get replacements
      if (distractors.length < count) {
        final more = await _contentRepo.getDistractors(
          count - distractors.length,
          excludeIds: [target.id, ...distractors.map((d) => d.id)],
        );
        distractors.addAll(more);
      }
    }

    return distractors.take(count).toList();
  }

  /// Build a QuestionItem with shuffled choices.
  QuestionItem _buildQuestion({
    required String wordId,
    required QuestionType type,
    required String prompt,
    required String correctAnswer,
    required List<String> choices,
  }) {
    // Shuffle choices so correct answer isn't always first
    final shuffled = [...choices];
    shuffled.shuffle(_random);
    final correctIndex = shuffled.indexOf(correctAnswer);

    return QuestionItem(
      wordId: wordId,
      type: type,
      prompt: prompt,
      correctAnswer: correctAnswer,
      choices: shuffled,
      correctIndex: correctIndex,
    );
  }

  /// Default game type cycling for level questions.
  /// Rotates: MeaningTap → ImageMatch → CueRecall → SentenceFix
  QuestionType _defaultTypeForIndex(int index) {
    const cycle = [
      QuestionType.meaningTap,
      QuestionType.imageMatch,
      QuestionType.cueRecall,
      QuestionType.sentenceFix,
    ];
    return cycle[index % cycle.length];
  }

  /// Extract a short fragment from a memoryKey for use as a cue prompt.
  /// Takes the first sentence or caps at 60 characters.
  String _extractCueFragment(String memoryKey) {
    if (memoryKey.isEmpty) return '';

    // Try first sentence
    final sentenceEnd = memoryKey.indexOf('.');
    if (sentenceEnd > 0 && sentenceEnd < 80) {
      return memoryKey.substring(0, sentenceEnd + 1);
    }

    // Cap at 60 chars
    if (memoryKey.length <= 60) return memoryKey;
    final lastSpace = memoryKey.lastIndexOf(' ', 60);
    return '${memoryKey.substring(0, lastSpace > 0 ? lastSpace : 60)}...';
  }
}
