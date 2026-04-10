import '../local_db/database_service.dart';
import '../models/models.dart';

/// Manages reward unlocking and equipping.
///
/// Rewards are unlocked by completing worlds, boss levels, or milestones.
/// Equipping is cosmetic only — one item per type can be equipped.
class RewardRepository {
  final DatabaseService _db;

  RewardRepository(this._db);

  /// Get all reward definitions from the catalog.
  Future<List<RewardItem>> getAllRewards() => _db.getAllRewards();

  /// Get unlock/equip state for a specific reward.
  Future<RewardProgress?> getProgress(String rewardId) =>
      _db.getRewardProgress(rewardId);

  /// Get all reward progress entries.
  Future<List<RewardProgress>> getAllProgress() => _db.getAllRewardProgress();

  /// Get all unlocked rewards (joined with catalog data).
  Future<List<RewardItem>> getUnlockedRewards() async {
    final allRewards = await _db.getAllRewards();
    final allProgress = await _db.getAllRewardProgress();
    final unlockedIds =
        allProgress.where((p) => p.isUnlocked).map((p) => p.rewardId).toSet();
    return allRewards.where((r) => unlockedIds.contains(r.id)).toList();
  }

  /// Unlock a reward by ID.
  Future<void> unlockReward(String rewardId) async {
    final existing = await _db.getRewardProgress(rewardId);
    if (existing != null && existing.isUnlocked) return; // already unlocked

    final progress = RewardProgress(
      rewardId: rewardId,
      isUnlocked: true,
      isEquipped: false,
      unlockedAt: DateTime.now(),
    );
    await _db.saveRewardProgress(progress);
  }

  /// Equip a reward (unequip others of the same type).
  Future<void> equipReward(String rewardId) async {
    final progress = await _db.getRewardProgress(rewardId);
    if (progress == null || !progress.isUnlocked) return; // can't equip locked

    progress.isEquipped = true;
    await _db.saveRewardProgress(progress);
  }

  /// Unequip a reward.
  Future<void> unequipReward(String rewardId) async {
    final progress = await _db.getRewardProgress(rewardId);
    if (progress == null) return;

    progress.isEquipped = false;
    await _db.saveRewardProgress(progress);
  }

  /// Check and unlock any rewards triggered by a rule string.
  ///
  /// Called after level completion, world completion, or mastery milestones.
  /// Example rules: 'complete_world_1', 'complete_level_50', 'words_mastered_500'
  Future<List<RewardItem>> checkAndUnlock(String unlockRule) async {
    final allRewards = await _db.getAllRewards();
    final matching =
        allRewards.where((r) => r.unlockRule == unlockRule).toList();

    final unlocked = <RewardItem>[];
    for (final reward in matching) {
      final progress = await _db.getRewardProgress(reward.id);
      if (progress == null || !progress.isUnlocked) {
        await unlockReward(reward.id);
        unlocked.add(reward);
      }
    }
    return unlocked;
  }

  /// Count of unlocked rewards.
  Future<int> getUnlockedCount() async {
    final allProgress = await _db.getAllRewardProgress();
    return allProgress.where((p) => p.isUnlocked).length;
  }
}
