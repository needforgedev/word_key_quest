import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import 'service_providers.dart';

/// Provides reward data for the rewards room screen.

/// All reward progress entries.
final allRewardProgressProvider = FutureProvider<List<RewardProgress>>((ref) {
  return ref.read(rewardRepositoryProvider).getAllProgress();
});

/// All unlocked reward items (catalog joined with progress).
final unlockedRewardsProvider = FutureProvider<List<RewardItem>>((ref) {
  return ref.read(rewardRepositoryProvider).getUnlockedRewards();
});

/// Count of unlocked rewards.
final unlockedRewardCountProvider = FutureProvider<int>((ref) {
  return ref.read(rewardRepositoryProvider).getUnlockedCount();
});

/// Manages reward equip/unequip actions.
class RewardActionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> equip(String rewardId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(rewardRepositoryProvider).equipReward(rewardId);
      ref.invalidate(allRewardProgressProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unequip(String rewardId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(rewardRepositoryProvider).unequipReward(rewardId);
      ref.invalidate(allRewardProgressProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final rewardActionProvider =
    NotifierProvider<RewardActionNotifier, AsyncValue<void>>(() {
  return RewardActionNotifier();
});
