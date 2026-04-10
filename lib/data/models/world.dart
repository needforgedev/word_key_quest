/// A campaign world containing 10 levels and 100 words.
///
/// Maps to entries in `assets/data/worlds.json`. Immutable content data.
class World {
  final String id;
  final int index;
  final String name;
  final int wordCount;
  final int levelCount;
  final String unlockRequirement;

  const World({
    required this.id,
    required this.index,
    required this.name,
    required this.wordCount,
    required this.levelCount,
    required this.unlockRequirement,
  });

  bool get isFirstWorld => unlockRequirement == 'none';
  bool get isBonusVault => id == 'bonus_vault';

  factory World.fromJson(Map<String, dynamic> json) {
    return World(
      id: json['id'] as String,
      index: json['index'] as int,
      name: json['name'] as String,
      wordCount: json['wordCount'] as int,
      levelCount: json['levelCount'] as int,
      unlockRequirement: json['unlockRequirement'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'index': index,
        'name': name,
        'wordCount': wordCount,
        'levelCount': levelCount,
        'unlockRequirement': unlockRequirement,
      };

  @override
  String toString() => 'World($id: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is World && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
