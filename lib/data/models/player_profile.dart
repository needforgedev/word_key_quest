/// The child's profile and overall game state.
///
/// Persisted to local database. One profile per app installation for MVP.
class PlayerProfile {
  final String id;
  String name;
  int ageBand; // 6-13
  int avatarId; // index into avatar list
  String selectedTheme; // 'sky_heroes', 'enchanted_kingdom', 'explorer_quest'
  int currentWorld; // 0-indexed
  int currentLevel; // 0-indexed within world
  int streakCount;
  int stars;
  int keys;
  int wordOrderSeed; // deterministic shuffle seed for per-player word order
  DateTime? lastPlayedAt;
  DateTime? streakStartDate;

  PlayerProfile({
    required this.id,
    required this.name,
    required this.ageBand,
    this.avatarId = 0,
    this.selectedTheme = 'enchanted_kingdom',
    this.currentWorld = 0,
    this.currentLevel = 0,
    this.streakCount = 0,
    this.stars = 0,
    this.keys = 0,
    this.wordOrderSeed = 0,
    this.lastPlayedAt,
    this.streakStartDate,
  });

  /// The global level number (1-350).
  int get globalLevel => currentWorld * 10 + currentLevel + 1;

  /// Total words the player should have been introduced to based on progression.
  int get maxIntroducedWords => globalLevel * 10;

  /// Whether the player has completed all campaign content.
  bool get hasCompletedCampaign => currentWorld >= 34 && currentLevel >= 9;

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      ageBand: json['ageBand'] as int? ?? 8,
      avatarId: json['avatarId'] as int? ?? 0,
      selectedTheme: json['selectedTheme'] as String? ?? 'enchanted_kingdom',
      currentWorld: json['currentWorld'] as int? ?? 0,
      currentLevel: json['currentLevel'] as int? ?? 0,
      streakCount: json['streakCount'] as int? ?? 0,
      stars: json['stars'] as int? ?? 0,
      keys: json['keys'] as int? ?? 0,
      wordOrderSeed: json['wordOrderSeed'] as int? ?? 0,
      lastPlayedAt: _parseDateTime(json['lastPlayedAt']),
      streakStartDate: _parseDateTime(json['streakStartDate']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ageBand': ageBand,
        'avatarId': avatarId,
        'selectedTheme': selectedTheme,
        'currentWorld': currentWorld,
        'currentLevel': currentLevel,
        'streakCount': streakCount,
        'stars': stars,
        'keys': keys,
        'wordOrderSeed': wordOrderSeed,
        'lastPlayedAt': lastPlayedAt?.toIso8601String(),
        'streakStartDate': streakStartDate?.toIso8601String(),
      };

  PlayerProfile copyWith({
    String? name,
    int? ageBand,
    int? avatarId,
    String? selectedTheme,
    int? currentWorld,
    int? currentLevel,
    int? streakCount,
    int? stars,
    int? keys,
    int? wordOrderSeed,
    DateTime? lastPlayedAt,
    DateTime? streakStartDate,
  }) {
    return PlayerProfile(
      id: id,
      name: name ?? this.name,
      ageBand: ageBand ?? this.ageBand,
      avatarId: avatarId ?? this.avatarId,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      currentWorld: currentWorld ?? this.currentWorld,
      currentLevel: currentLevel ?? this.currentLevel,
      streakCount: streakCount ?? this.streakCount,
      stars: stars ?? this.stars,
      keys: keys ?? this.keys,
      wordOrderSeed: wordOrderSeed ?? this.wordOrderSeed,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      streakStartDate: streakStartDate ?? this.streakStartDate,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  String toString() => 'PlayerProfile($name, world=$currentWorld, level=$currentLevel)';
}
