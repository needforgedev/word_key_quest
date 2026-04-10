import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import '../core/session_manager.dart';
import 'service_providers.dart';
import 'player_provider.dart';
import 'campaign_provider.dart';

/// Manages the active gameplay session (level or daily quest).
///
/// Screens read from this provider to know:
///   - Which phase we're in (learning / quizzing / complete)
///   - The current learn card word or quiz question
///   - Progress through the session
class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() => SessionState.idle();

  SessionManager get _sessionManager => ref.read(sessionManagerProvider);

  /// Start a level session.
  Future<void> startLevel(int worldIndex, int levelIndex) async {
    state = SessionState.loading();
    try {
      final session =
          await _sessionManager.startLevelSession(worldIndex, levelIndex);
      final words = _sessionManager.sessionWords;
      final firstLearnWord = _sessionManager.getCurrentLearnWord();

      state = SessionState(
        phase: SessionPhase.learning,
        session: session,
        sessionWords: words,
        currentLearnWord: firstLearnWord,
        remainingLearnCards: _sessionManager.remainingLearnCards,
      );
    } catch (e) {
      state = SessionState.error(e.toString());
    }
  }

  /// Start a daily quest session.
  Future<void> startDailyQuest() async {
    state = SessionState.loading();
    try {
      final session = await _sessionManager.startDailyQuestSession();

      state = SessionState(
        phase: SessionPhase.quizzing,
        session: session,
        sessionWords: _sessionManager.sessionWords,
        currentQuestion: _sessionManager.getCurrentQuestion(),
        questionNumber: _sessionManager.currentQuestionNumber,
        totalQuestions: _sessionManager.totalQuestions,
        quizProgress: _sessionManager.quizProgress,
      );
    } catch (e) {
      state = SessionState.error(e.toString());
    }
  }

  /// Advance to the next learn card.
  Future<void> advanceLearnCard() async {
    final nextWord = await _sessionManager.advanceLearnWord();

    if (_sessionManager.isLearnPhaseComplete) {
      state = state.copyWith(
        phase: SessionPhase.quizzing,
        currentLearnWord: null,
        currentQuestion: _sessionManager.getCurrentQuestion(),
        questionNumber: _sessionManager.currentQuestionNumber,
        totalQuestions: _sessionManager.totalQuestions,
        quizProgress: _sessionManager.quizProgress,
      );
    } else {
      state = state.copyWith(
        currentLearnWord: nextWord,
        remainingLearnCards: _sessionManager.remainingLearnCards,
      );
    }
  }

  /// Submit an answer to the current question.
  Future<AnswerFeedback> submitAnswer(int selectedIndex) async {
    final feedback = await _sessionManager.submitAnswer(selectedIndex);

    if (feedback.hasMoreQuestions) {
      state = state.copyWith(
        currentQuestion: _sessionManager.getCurrentQuestion(),
        questionNumber: _sessionManager.currentQuestionNumber,
        quizProgress: _sessionManager.quizProgress,
        lastFeedback: feedback,
      );
    } else {
      state = state.copyWith(
        phase: SessionPhase.complete,
        currentQuestion: null,
        quizProgress: 1.0,
        lastFeedback: feedback,
      );
    }

    return feedback;
  }

  /// Complete the session and get results.
  Future<SessionCompletionResult> completeSession() async {
    final result = await _sessionManager.completeSession();

    // Refresh player and campaign state
    await ref.read(playerProvider.notifier).refresh();
    await ref.read(campaignProvider.notifier).refresh();

    state = SessionState.idle();
    return result;
  }

  /// Abandon the current session.
  void abandonSession() {
    _sessionManager.abandonSession();
    state = SessionState.idle();
  }
}

/// Session state exposed to screens.
class SessionState {
  final SessionPhase phase;
  final LevelSession? session;
  final List<WordEntry> sessionWords;
  final WordEntry? currentLearnWord;
  final int remainingLearnCards;
  final QuestionItem? currentQuestion;
  final int questionNumber;
  final int totalQuestions;
  final double quizProgress;
  final AnswerFeedback? lastFeedback;
  final String? error;
  final bool isLoading;

  const SessionState({
    this.phase = SessionPhase.idle,
    this.session,
    this.sessionWords = const [],
    this.currentLearnWord,
    this.remainingLearnCards = 0,
    this.currentQuestion,
    this.questionNumber = 0,
    this.totalQuestions = 0,
    this.quizProgress = 0.0,
    this.lastFeedback,
    this.error,
    this.isLoading = false,
  });

  factory SessionState.idle() => const SessionState();

  factory SessionState.loading() => const SessionState(isLoading: true);

  factory SessionState.error(String message) =>
      SessionState(error: message);

  bool get isIdle => phase == SessionPhase.idle;
  bool get isLearning => phase == SessionPhase.learning;
  bool get isQuizzing => phase == SessionPhase.quizzing;
  bool get isComplete => phase == SessionPhase.complete;
  bool get isDailyQuest => session?.isDailyQuest ?? false;

  SessionState copyWith({
    SessionPhase? phase,
    LevelSession? session,
    List<WordEntry>? sessionWords,
    WordEntry? currentLearnWord,
    int? remainingLearnCards,
    QuestionItem? currentQuestion,
    int? questionNumber,
    int? totalQuestions,
    double? quizProgress,
    AnswerFeedback? lastFeedback,
    String? error,
  }) {
    return SessionState(
      phase: phase ?? this.phase,
      session: session ?? this.session,
      sessionWords: sessionWords ?? this.sessionWords,
      currentLearnWord: currentLearnWord ?? this.currentLearnWord,
      remainingLearnCards: remainingLearnCards ?? this.remainingLearnCards,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      questionNumber: questionNumber ?? this.questionNumber,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      quizProgress: quizProgress ?? this.quizProgress,
      lastFeedback: lastFeedback ?? this.lastFeedback,
      error: error ?? this.error,
    );
  }
}

final sessionProvider =
    NotifierProvider<SessionNotifier, SessionState>(() {
  return SessionNotifier();
});
