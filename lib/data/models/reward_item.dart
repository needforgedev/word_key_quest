/// A cosmetic reward that can be unlocked through gameplay.
///
/// Maps to entries in `assets/data/reward_catalog.json`. Immutable content data.
class RewardItem {
  final String id;
  final String name;
  final String type; // badge, sticker, pet, outfit, room_prop, key
  final String category; // Sky Heroes, Enchanted Kingdom, Explorer Quest, campaign, milestone
  final String unlockRule; // e.g. 'complete_world_1', 'complete_level_50', 'words_mastered_500'
  final String rarity; // common, uncommon, rare, legendary

  const RewardItem({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.unlockRule,
    required this.rarity,
  });

  factory RewardItem.fromJson(Map<String, dynamic> json) {
    return RewardItem(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      unlockRule: json['unlockRule'] as String,
      rarity: json['rarity'] as String? ?? 'common',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'category': category,
        'unlockRule': unlockRule,
        'rarity': rarity,
      };

  @override
  String toString() => 'RewardItem($id: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RewardItem && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Tracks whether a specific reward has been unlocked and/or equipped.
class RewardProgress {
  final String rewardId;
  bool isUnlocked;
  bool isEquipped;
  DateTime? unlockedAt;

  RewardProgress({
    required this.rewardId,
    this.isUnlocked = false,
    this.isEquipped = false,
    this.unlockedAt,
  });

  factory RewardProgress.fromJson(Map<String, dynamic> json) {
    return RewardProgress(
      rewardId: json['rewardId'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      isEquipped: json['isEquipped'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'rewardId': rewardId,
        'isUnlocked': isUnlocked,
        'isEquipped': isEquipped,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };
}
