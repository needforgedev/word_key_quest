/// A single vocabulary word with all content fields.
///
/// Maps directly to entries in `assets/data/words.json`.
/// Immutable — content is seeded once and never modified at runtime.
class WordEntry {
  final String id;
  final int sourceRank;
  final String word;
  final String partOfSpeech;
  final String pronunciation;
  final String barronsMeaning;
  final String kidsMeaning;
  final String cueType;
  final String cue;
  final String memoryKey;
  final List<String> synonyms;
  final List<String> antonyms;
  final String usage1Simple;
  final String usage2Standard;
  final int worldIndex;
  final int levelIndex;
  final bool isBonus;

  const WordEntry({
    required this.id,
    required this.sourceRank,
    required this.word,
    required this.partOfSpeech,
    required this.pronunciation,
    required this.barronsMeaning,
    required this.kidsMeaning,
    required this.cueType,
    required this.cue,
    required this.memoryKey,
    required this.synonyms,
    required this.antonyms,
    required this.usage1Simple,
    required this.usage2Standard,
    required this.worldIndex,
    required this.levelIndex,
    required this.isBonus,
  });

  factory WordEntry.fromJson(Map<String, dynamic> json) {
    return WordEntry(
      id: json['id'] as String,
      sourceRank: json['sourceRank'] as int,
      word: json['word'] as String,
      partOfSpeech: json['partOfSpeech'] as String? ?? '',
      pronunciation: json['pronunciation'] as String? ?? '',
      barronsMeaning: json['barronsMeaning'] as String? ?? '',
      kidsMeaning: json['kidsMeaning'] as String? ?? '',
      cueType: json['cueType'] as String? ?? 'situation',
      cue: json['cue'] as String? ?? '',
      memoryKey: json['memoryKey'] as String? ?? '',
      synonyms: _parseStringList(json['synonyms']),
      antonyms: _parseStringList(json['antonyms']),
      usage1Simple: json['usage1Simple'] as String? ?? '',
      usage2Standard: json['usage2Standard'] as String? ?? '',
      worldIndex: json['worldIndex'] as int,
      levelIndex: json['levelIndex'] as int,
      isBonus: json['isBonus'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceRank': sourceRank,
        'word': word,
        'partOfSpeech': partOfSpeech,
        'pronunciation': pronunciation,
        'barronsMeaning': barronsMeaning,
        'kidsMeaning': kidsMeaning,
        'cueType': cueType,
        'cue': cue,
        'memoryKey': memoryKey,
        'synonyms': synonyms,
        'antonyms': antonyms,
        'usage1Simple': usage1Simple,
        'usage2Standard': usage2Standard,
        'worldIndex': worldIndex,
        'levelIndex': levelIndex,
        'isBonus': isBonus,
      };

  /// The sentence with the word blanked out for Sentence Fix mini-game.
  String get sentenceWithBlank {
    if (usage1Simple.isEmpty) return '';
    // Replace the word (case-insensitive) with a blank
    return usage1Simple.replaceAll(
      RegExp(RegExp.escape(word), caseSensitive: false),
      '_______',
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.cast<String>();
    return [];
  }

  @override
  String toString() => 'WordEntry($id: $word)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WordEntry && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
