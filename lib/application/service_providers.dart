import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_db/database_service.dart';
import '../data/repositories/repositories.dart';
import '../core/mastery_engine.dart';
import '../core/question_engine.dart';
import '../core/difficulty_controller.dart';
import '../core/review_scheduler.dart';
import '../core/session_manager.dart';
import '../core/audio/tts_service.dart';

// ═══════════════════════════════════════════════════════
// Database
// ═══════════════════════════════════════════════════════

/// Single DatabaseService instance shared across the app.
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// ═══════════════════════════════════════════════════════
// Repositories
// ═══════════════════════════════════════════════════════

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository(ref.watch(databaseServiceProvider));
});

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepository(ref.watch(databaseServiceProvider));
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(ref.watch(databaseServiceProvider));
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.watch(databaseServiceProvider));
});

final rewardRepositoryProvider = Provider<RewardRepository>((ref) {
  return RewardRepository(ref.watch(databaseServiceProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

// ═══════════════════════════════════════════════════════
// Core engines
// ═══════════════════════════════════════════════════════

final masteryEngineProvider = Provider<MasteryEngine>((ref) {
  return MasteryEngine(ref.watch(progressRepositoryProvider));
});

final questionEngineProvider = Provider<QuestionEngine>((ref) {
  return QuestionEngine(ref.watch(contentRepositoryProvider));
});

final difficultyControllerProvider = Provider<DifficultyController>((ref) {
  return DifficultyController();
});

final reviewSchedulerProvider = Provider<ReviewScheduler>((ref) {
  return ReviewScheduler(
    ref.watch(progressRepositoryProvider),
    ref.watch(reviewRepositoryProvider),
  );
});

final sessionManagerProvider = Provider<SessionManager>((ref) {
  return SessionManager(
    contentRepo: ref.watch(contentRepositoryProvider),
    playerRepo: ref.watch(playerRepositoryProvider),
    progressRepo: ref.watch(progressRepositoryProvider),
    reviewRepo: ref.watch(reviewRepositoryProvider),
    rewardRepo: ref.watch(rewardRepositoryProvider),
    masteryEngine: ref.watch(masteryEngineProvider),
    questionEngine: ref.watch(questionEngineProvider),
    difficultyController: ref.watch(difficultyControllerProvider),
    reviewScheduler: ref.watch(reviewSchedulerProvider),
  );
});

// ═══════════════════════════════════════════════════════
// Audio
// ═══════════════════════════════════════════════════════

/// Single TtsService instance shared across the app.
final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService();
});
