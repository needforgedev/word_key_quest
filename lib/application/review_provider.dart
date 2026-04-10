import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import '../core/review_scheduler.dart';
import 'service_providers.dart';

/// Provides review queue and daily quest data for home and daily quest screens.

/// Number of words currently due for review.
final dueWordCountProvider = FutureProvider<int>((ref) {
  return ref.read(reviewSchedulerProvider).getDueWordCount();
});

/// Whether there are words to review right now.
final hasWordsToReviewProvider = FutureProvider<bool>((ref) {
  return ref.read(reviewSchedulerProvider).hasWordsToReview();
});

/// Today's daily quest (created if doesn't exist).
final todayQuestProvider = FutureProvider<DailyQuest>((ref) {
  return ref.read(reviewSchedulerProvider).getTodayQuest();
});

/// Whether today's quest is complete.
final isTodayQuestCompleteProvider = FutureProvider<bool>((ref) {
  return ref.read(reviewSchedulerProvider).isTodayQuestComplete();
});

/// Review queue status snapshot (for home screen stats).
final reviewQueueStatusProvider = FutureProvider<ReviewQueueStatus>((ref) {
  return ref.read(reviewSchedulerProvider).getQueueStatus();
});
