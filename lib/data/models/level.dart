/// A single level within a world, containing 10 new words.
///
/// Maps to entries in `assets/data/levels.json`. Immutable content data.
class Level {
  final String id;
  final String worldId;
  final int worldIndex;
  final int levelIndex;
  final int levelNumber; // global 1-350
  final List<String> newWordIds;
  final bool bossEnabled;
  final int starReward;
  final int keyReward;

  const Level({
    required this.id,
    required this.worldId,
    required this.worldIndex,
    required this.levelIndex,
    required this.levelNumber,
    required this.newWordIds,
    required this.bossEnabled,
    required this.starReward,
    required this.keyReward,
  });

  /// Whether this is the last level in its world.
  bool get isWorldFinale => levelIndex == 9;

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as String,
      worldId: json['worldId'] as String,
      worldIndex: json['worldIndex'] as int,
      levelIndex: json['levelIndex'] as int,
      levelNumber: json['levelNumber'] as int,
      newWordIds: (json['newWordIds'] as List).cast<String>(),
      bossEnabled: json['bossEnabled'] as bool? ?? false,
      starReward: json['starReward'] as int? ?? 3,
      keyReward: json['keyReward'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'worldId': worldId,
        'worldIndex': worldIndex,
        'levelIndex': levelIndex,
        'levelNumber': levelNumber,
        'newWordIds': newWordIds,
        'bossEnabled': bossEnabled,
        'starReward': starReward,
        'keyReward': keyReward,
      };

  @override
  String toString() => 'Level($id: world=$worldIndex, level=$levelIndex)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Level && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
