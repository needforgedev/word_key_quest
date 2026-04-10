import '../data/models/models.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/player_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/review_repository.dart';
import '../data/repositories/reward_repository.dart';
import 'mastery_engine.dart';
import 'question_engine.dart';
import 'difficulty_controller.dart';
import 'review_scheduler.dart';

/// Orchestrates the full gameplay flow for a level or daily quest.
///
/// Lifecycle:
///   1. [startLevelSession] / [startDailyQuestSession] — load words, generate questions
///   2. [getCurrentLearnWord] / [advanceLearnWord] — learn card phase
///   3. [getCurrentQuestion] / [submitAnswer] — mini-game phase
///   4. [completeSession] — calculate rewards, update mastery, advance progression
///
/// The session manager holds the active [LevelSession] and coordinates
/// between the mastery engine, question engine, and difficulty controller.
class SessionManager {
  final ContentRepository _contentRepo;
  final PlayerRepository _playerRepo;
  final ProgressRepository _progressRepo;
  final ReviewRepository _reviewRepo;
  final RewardRepository _rewardRepo;
  final MasteryEngine _masteryEngine;
  final QuestionEngine _questionEngine;
  final DifficultyController _difficultyController;
  final ReviewScheduler _reviewScheduler;

  LevelSession? _activeSession;
  List<WordEntry> _sessionWords = [];
  int _learnCardIndex = 0;
  int _questionIndex = 0;
  DateTime? _questionStartTime;
  final List<MasteryResult> _masteryResults = [];

  SessionManager({
    required ContentRepository contentRepo,
    required PlayerRepository playerRepo,
    required ProgressRepository progressRepo,
    required ReviewRepository reviewRepo,
    required RewardRepository rewardRepo,
    required MasteryEngine masteryEngine,
    required QuestionEngine questionEngine,
    required DifficultyController difficultyController,
    required ReviewScheduler reviewScheduler,
  })  : _contentRepo = contentRepo,
        _playerRepo = playerRepo,
        _progressRepo = progressRepo,
        _reviewRepo = reviewRepo,
        _rewardRepo = rewardRepo,
        _masteryEngine = masteryEngine,
        _questionEngine = questionEngine,
        _difficultyController = difficultyController,
        _reviewScheduler = reviewScheduler;

  // ═══════════════════════════════════════════════════════
  // Session state
  // ═══════════════════════════════════════════════════════

  /// The currently active session, or null if none.
  LevelSession? get activeSession => _activeSession;

  /// Whether a session is currently in progress.
  bool get hasActiveSession => _activeSession != null;

  /// All words loaded for the current session.
  List<WordEntry> get sessionWords => _sessionWords;

  /// Current phase of the session.
  SessionPhase get currentPhase {
    if (_activeSession == null) return SessionPhase.idle;
    if (_learnCardIndex < _sessionWords.length) return SessionPhase.learning;
    if (_questionIndex < (_activeSession!.questions.length)) {
      return SessionPhase.quizzing;
    }
    return SessionPhase.complete;
  }

  // ═══════════════════════════════════════════════════════
  // Start sessions
  // ═══════════════════════════════════════════════════════

  /// Start a new level session.
  ///
  /// Loads words using the player's unique shuffled order,
  /// applies difficulty adjustments, adds review words,
  /// generates questions, and returns the session.
  Future<LevelSession> startLevelSession(
    int worldIndex,
    int levelIndex,
  ) async {
    // Load level definition (for metadata like bossEnabled, rewards)
    final level = await _contentRepo.getLevel(worldIndex, levelIndex);
    if (level == null) {
      throw StateError('Level not found: world=$worldIndex, level=$levelIndex');
    }

    // Get the player's word order seed
    final profile = await _playerRepo.getProfile();
    final seed = profile?.wordOrderSeed ?? 0;

    // Load words using player's shuffled order (not fixed manifest order)
    final globalLevelNumber = worldIndex * 10 + levelIndex + 1;
    final shuffledWordIds =
        await _contentRepo.getShuffledWordsForLevel(seed, globalLevelNumber);

    final newWordCount = _difficultyController.newWordsPerLevel
        .clamp(1, shuffledWordIds.length);
    final newWordIds = shuffledWordIds.take(newWordCount).toList();
    final newWords = await _contentRepo.getWordsByIds(newWordIds);

    // Load review words (due or weak)
    final reviewCount = _difficultyController.reviewWordsPerLevel;
    final dueWords = await _reviewScheduler.getDueWords(limit: reviewCount);
    final reviewWordIds = dueWords.map((w) => w.wordId).toList();
    final reviewWords = await _contentRepo.getWordsByIds(reviewWordIds);

    // Combine all session words
    _sessionWords = [...newWords, ...reviewWords];

    // Get mastery levels for type selection
    final masteryLevels = await _masteryEngine.getMasteryLevels(
      _sessionWords.map((w) => w.id).toList(),
    );

    // Generate questions using difficulty-aware type distribution
    final types = _difficultyController.generateTypeDistribution(
      _sessionWords.length,
      masteryLevels:
          _sessionWords.map((w) => masteryLevels[w.id] ?? 0).toList(),
    );

    final questions = <QuestionItem>[];
    for (var i = 0; i < _sessionWords.length; i++) {
      final q = await _questionEngine.generate(_sessionWords[i], types[i]);
      questions.add(q);
    }

    // Create session
    _activeSession = LevelSession(
      levelId: level.id,
      worldIndex: worldIndex,
      levelIndex: levelIndex,
      newWordIds: newWordIds,
      reviewWordIds: reviewWordIds,
      questions: questions,
    );

    _learnCardIndex = 0;
    _questionIndex = 0;
    _questionStartTime = null;

    return _activeSession!;
  }

  /// Start a daily quest session from the review scheduler.
  Future<LevelSession> startDailyQuestSession() async {
    final quest = await _reviewScheduler.getTodayQuest();

    // Load the review words
    final words = await _contentRepo.getWordsByIds(quest.reviewWordIds);
    _sessionWords = words;

    // Get mastery levels for question type selection
    final masteryLevels = await _masteryEngine.getMasteryLevels(
      words.map((w) => w.id).toList(),
    );

    // Generate questions
    final types = _difficultyController.generateTypeDistribution(
      words.length,
      masteryLevels: words.map((w) => masteryLevels[w.id] ?? 1).toList(),
    );

    final questions = <QuestionItem>[];
    for (var i = 0; i < words.length; i++) {
      final q = await _questionEngine.generate(words[i], types[i]);
      questions.add(q);
    }

    _activeSession = LevelSession(
      levelId: 'daily_quest',
      worldIndex: -1,
      levelIndex: -1,
      newWordIds: [],
      reviewWordIds: quest.reviewWordIds,
      questions: questions,
    );

    // Daily quest skips learn cards — go straight to questions
    _learnCardIndex = _sessionWords.length;
    _questionIndex = 0;
    _questionStartTime = null;

    return _activeSession!;
  }

  // ═══════════════════════════════════════════════════════
  // Learn card phase
  // ═══════════════════════════════════════════════════════

  /// Get the current word to show on the learn card.
  /// Returns null if all learn cards have been viewed.
  WordEntry? getCurrentLearnWord() {
    if (_learnCardIndex >= _sessionWords.length) return null;
    // Only show learn cards for new words (not review words)
    final newWordCount = _activeSession?.newWordIds.length ?? 0;
    if (_learnCardIndex >= newWordCount) return null;
    return _sessionWords[_learnCardIndex];
  }

  /// Advance to the next learn card. Marks the current word as introduced.
  /// Returns the next word, or null if learn phase is complete.
  Future<WordEntry?> advanceLearnWord() async {
    final current = getCurrentLearnWord();
    if (current != null) {
      await _masteryEngine.introduceWord(current.id);
    }

    _learnCardIndex++;

    return getCurrentLearnWord();
  }

  /// Whether all learn cards have been viewed.
  bool get isLearnPhaseComplete {
    final newWordCount = _activeSession?.newWordIds.length ?? 0;
    return _learnCardIndex >= newWordCount;
  }

  /// How many learn cards remain.
  int get remainingLearnCards {
    final newWordCount = _activeSession?.newWordIds.length ?? 0;
    return (newWordCount - _learnCardIndex).clamp(0, newWordCount);
  }

  // ═══════════════════════════════════════════════════════
  // Quiz phase
  // ═══════════════════════════════════════════════════════

  /// Get the current question to display in the mini-game.
  /// Returns null if all questions have been answered.
  QuestionItem? getCurrentQuestion() {
    if (_activeSession == null) return null;
    if (_questionIndex >= _activeSession!.questions.length) return null;
    _questionStartTime ??= DateTime.now();
    return _activeSession!.questions[_questionIndex];
  }

  /// Submit an answer to the current question.
  ///
  /// Returns the [AnswerFeedback] with correctness, mastery change,
  /// and whether there are more questions.
  Future<AnswerFeedback> submitAnswer(int selectedIndex) async {
    final session = _activeSession;
    if (session == null) throw StateError('No active session');

    final question = session.questions[_questionIndex];
    final isCorrect = selectedIndex == question.correctIndex;
    final responseTime = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!)
        : Duration.zero;

    // Record the result
    final result = QuestionResult(
      wordId: question.wordId,
      type: question.type,
      isCorrect: isCorrect,
      selectedIndex: selectedIndex,
      responseTime: responseTime,
      answeredAt: DateTime.now(),
    );
    session.results.add(result);

    // Update mastery and track the result
    final masteryResult = await _masteryEngine.processQuestionResult(result);
    _masteryResults.add(masteryResult);

    // Feed difficulty controller
    _difficultyController.recordAnswer(result);

    // If this is a daily quest, update quest progress
    if (session.isDailyQuest) {
      final quest = await _reviewRepo.getOrCreateTodayQuest();
      await _reviewScheduler.recordQuestAnswer(quest, isCorrect);
    }

    // Advance to next question
    _questionIndex++;
    _questionStartTime = null;

    final hasMore = _questionIndex < session.questions.length;

    return AnswerFeedback(
      isCorrect: isCorrect,
      correctAnswer: question.correctAnswer,
      selectedAnswer: question.choices[selectedIndex],
      masteryResult: masteryResult,
      timeBonus: QuestionEngine.calculateTimeBonus(responseTime),
      hasMoreQuestions: hasMore,
      questionsRemaining: session.questions.length - _questionIndex,
    );
  }

  /// Whether all questions have been answered.
  bool get isQuizPhaseComplete {
    if (_activeSession == null) return true;
    return _questionIndex >= _activeSession!.questions.length;
  }

  /// Current question number (1-indexed).
  int get currentQuestionNumber => _questionIndex + 1;

  /// Total questions in this session.
  int get totalQuestions => _activeSession?.questions.length ?? 0;

  /// Progress through the quiz phase (0.0 to 1.0).
  double get quizProgress {
    if (totalQuestions == 0) return 0.0;
    return _questionIndex / totalQuestions;
  }

  // ═══════════════════════════════════════════════════════
  // Complete session
  // ═══════════════════════════════════════════════════════

  /// Complete the active session: calculate rewards, update profile, check unlocks.
  ///
  /// Returns a [SessionCompletionResult] with all the data the
  /// level complete screen needs to display.
  Future<SessionCompletionResult> completeSession() async {
    final session = _activeSession;
    if (session == null) throw StateError('No active session');

    session.completedAt = DateTime.now();

    // Calculate stars
    final starsEarned = QuestionEngine.calculateSessionStars(session.results);

    // Get player profile
    var profile = await _playerRepo.getProfile();
    if (profile == null) throw StateError('No player profile');

    // Award stars
    profile = await _playerRepo.addStars(profile, starsEarned * 10);

    // Build mastery summary from results tracked during submitAnswer()
    // (don't re-process — mastery was already updated per-question)
    final masterySummary = SessionMasterySummary(
      results: _masteryResults,
      wordsPromoted: _masteryResults.where((r) => r.wasPromoted).length,
      wordsDemoted: _masteryResults.where((r) => r.wasDemoted).length,
      newlyMastered:
          _masteryResults.where((r) => r.wasPromoted && r.newLevel == 5).length,
    );

    List<RewardItem> unlockedRewards = [];

    if (!session.isDailyQuest) {
      // Award keys (level reward)
      final level =
          await _contentRepo.getLevel(session.worldIndex, session.levelIndex);
      if (level != null) {
        profile = await _playerRepo.addKeys(profile, level.keyReward);
      }

      // Advance to next level
      if (session.worldIndex == profile.currentWorld &&
          session.levelIndex == profile.currentLevel) {
        profile = await _playerRepo.advanceLevel(profile);
      }

      // Check reward unlocks
      final levelNum = session.worldIndex * 10 + session.levelIndex + 1;
      unlockedRewards.addAll(
        await _rewardRepo.checkAndUnlock('complete_level_$levelNum'),
      );

      // Check if world completed (level 10)
      if (session.levelIndex == 9) {
        unlockedRewards.addAll(
          await _rewardRepo.checkAndUnlock(
              'complete_world_${session.worldIndex + 1}'),
        );
      }

      // Check mastery milestones
      final masteredCount = await _progressRepo.getMasteredCount();
      for (final milestone in [50, 100, 250, 500, 1000, 1500, 2000, 2500, 3000, 3500]) {
        if (masteredCount >= milestone) {
          unlockedRewards.addAll(
            await _rewardRepo.checkAndUnlock('words_mastered_$milestone'),
          );
        }
      }
    }

    // Update streak
    profile = await _playerRepo.updateStreak(profile);

    // Build completion result
    final result = SessionCompletionResult(
      session: session,
      starsEarned: starsEarned,
      totalStars: profile.stars,
      keysEarned: session.isDailyQuest ? 0 : 1,
      totalKeys: profile.keys,
      wordsIntroduced: session.newWordIds.length,
      wordsMastered: masterySummary.newlyMastered,
      wordsPromoted: masterySummary.wordsPromoted,
      accuracy: session.accuracy,
      streakCount: profile.streakCount,
      unlockedRewards: unlockedRewards,
      isDailyQuest: session.isDailyQuest,
    );

    // Clear active session
    _activeSession = null;
    _sessionWords = [];
    _learnCardIndex = 0;
    _questionIndex = 0;
    _masteryResults.clear();

    return result;
  }

  /// Abandon the current session without saving completion.
  void abandonSession() {
    _activeSession = null;
    _sessionWords = [];
    _learnCardIndex = 0;
    _questionIndex = 0;
    _questionStartTime = null;
    _masteryResults.clear();
  }
}

// ═══════════════════════════════════════════════════════
// Supporting types
// ═══════════════════════════════════════════════════════

/// Current phase of a session.
enum SessionPhase {
  /// No session active.
  idle,

  /// Showing learn cards for new words.
  learning,

  /// Running mini-game questions.
  quizzing,

  /// All questions answered, ready for completion.
  complete,
}

/// Feedback returned after each answer submission.
class AnswerFeedback {
  final bool isCorrect;
  final String correctAnswer;
  final String selectedAnswer;
  final MasteryResult masteryResult;
  final int timeBonus;
  final bool hasMoreQuestions;
  final int questionsRemaining;

  const AnswerFeedback({
    required this.isCorrect,
    required this.correctAnswer,
    required this.selectedAnswer,
    required this.masteryResult,
    required this.timeBonus,
    required this.hasMoreQuestions,
    required this.questionsRemaining,
  });

  @override
  String toString() =>
      'AnswerFeedback(correct=$isCorrect, mastery=${masteryResult.previousLevel}→${masteryResult.newLevel}, remaining=$questionsRemaining)';
}

/// Everything the level complete screen needs to display.
class SessionCompletionResult {
  final LevelSession session;
  final int starsEarned; // 1-3
  final int totalStars;
  final int keysEarned;
  final int totalKeys;
  final int wordsIntroduced;
  final int wordsMastered;
  final int wordsPromoted;
  final double accuracy;
  final int streakCount;
  final List<RewardItem> unlockedRewards;
  final bool isDailyQuest;

  const SessionCompletionResult({
    required this.session,
    required this.starsEarned,
    required this.totalStars,
    required this.keysEarned,
    required this.totalKeys,
    required this.wordsIntroduced,
    required this.wordsMastered,
    required this.wordsPromoted,
    required this.accuracy,
    required this.streakCount,
    required this.unlockedRewards,
    required this.isDailyQuest,
  });

  bool get hasNewRewards => unlockedRewards.isNotEmpty;
  int get totalAnswered => session.answeredCount;
  int get totalCorrect => session.correctCount;

  @override
  String toString() =>
      'SessionCompletionResult(stars=$starsEarned, mastered=$wordsMastered, rewards=${unlockedRewards.length})';
}
