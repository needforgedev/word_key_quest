/// Content Manifest Generator for Word Key Quest
///
/// Transforms the raw Barron's 3500 JSON into four app-ready manifest files:
///   - assets/data/words.json    (3,523 normalized word entries)
///   - assets/data/worlds.json   (35 campaign worlds + 1 bonus vault)
///   - assets/data/levels.json   (350 campaign levels)
///   - assets/data/reward_catalog.json (cosmetic rewards)
///
/// Usage: dart run tools/generate_manifests.dart

import 'dart:convert';
import 'dart:io';

// ── World names themed around vocabulary adventure ──
const worldNames = [
  'The Whispering Meadow',
  'Crystal Caverns',
  'Sunstone Valley',
  'The Echo Cave',
  'Starfall Ridge',
  'Moonlit Marsh',
  'Thornwood Thicket',
  'Driftwood Shores',
  'Ember Peak',
  'The Frozen Quill',
  'Sapphire Lagoon',
  'Windmill Heights',
  'The Iron Library',
  'Coral Reef Kingdom',
  'Sandstorm Citadel',
  'The Verdant Canopy',
  'Obsidian Fortress',
  'Lantern Falls',
  'The Painted Desert',
  'Cloudtop Spire',
  'The Sunken Archive',
  'Blossom Gate',
  'Stormwatch Tower',
  'The Amber Ruins',
  'Frostfire Hollow',
  'The Golden Bazaar',
  'Shadowfern Glade',
  'Skybridge Summit',
  'The Velvet Depths',
  'Dragonfly Isles',
  'The Wandering Path',
  'Prism Peak',
  'The Silent Lighthouse',
  'Evergreen Sanctum',
  'The Final Chapter',
];

// ── Reward motifs cycling through theme packs ──
const rewardTypes = [
  {'type': 'badge', 'category': 'Sky Heroes'},
  {'type': 'sticker', 'category': 'Enchanted Kingdom'},
  {'type': 'pet', 'category': 'Explorer Quest'},
  {'type': 'outfit', 'category': 'Sky Heroes'},
  {'type': 'room_prop', 'category': 'Enchanted Kingdom'},
  {'type': 'badge', 'category': 'Explorer Quest'},
];

void main() {
  final projectRoot = Directory.current.path;
  final rawPath = '$projectRoot/barrons_3500_master copy - Sheet1.json';
  final outputDir = '$projectRoot/assets/data';

  // ── Load raw data ──
  final rawFile = File(rawPath);
  if (!rawFile.existsSync()) {
    stderr.writeln('ERROR: Raw word file not found at $rawPath');
    exit(1);
  }

  final List<dynamic> rawWords = jsonDecode(rawFile.readAsStringSync());
  print('Loaded ${rawWords.length} raw words');

  // ── Sort by sourceRank ──
  rawWords.sort((a, b) {
    final rankA = int.tryParse(a['sourceRank']?.toString() ?? '9999') ?? 9999;
    final rankB = int.tryParse(b['sourceRank']?.toString() ?? '9999') ?? 9999;
    return rankA.compareTo(rankB);
  });

  // ── Split: 3500 campaign + 23 bonus ──
  final campaignWords = rawWords.take(3500).toList();
  final bonusWords = rawWords.skip(3500).toList();

  print('Campaign words: ${campaignWords.length}');
  print('Bonus words: ${bonusWords.length}');

  // ── Generate words.json ──
  final List<Map<String, dynamic>> wordEntries = [];

  for (var i = 0; i < campaignWords.length; i++) {
    final raw = campaignWords[i] as Map<String, dynamic>;
    final worldIndex = i ~/ 100; // 0-34
    final levelIndex = (i % 100) ~/ 10; // 0-9

    wordEntries.add(_normalizeWord(
      raw: raw,
      id: 'w_${i + 1}',
      index: i,
      worldIndex: worldIndex,
      levelIndex: levelIndex,
      isBonus: false,
    ));
  }

  for (var i = 0; i < bonusWords.length; i++) {
    final raw = bonusWords[i] as Map<String, dynamic>;
    wordEntries.add(_normalizeWord(
      raw: raw,
      id: 'bonus_${i + 1}',
      index: 3500 + i,
      worldIndex: -1, // bonus vault
      levelIndex: -1,
      isBonus: true,
    ));
  }

  // ── Generate worlds.json ──
  final List<Map<String, dynamic>> worlds = [];

  for (var w = 0; w < 35; w++) {
    worlds.add({
      'id': 'world_${w + 1}',
      'index': w,
      'name': worldNames[w],
      'wordCount': 100,
      'levelCount': 10,
      'unlockRequirement': w == 0
          ? 'none'
          : 'complete_world_$w', // complete previous world
    });
  }

  // Add bonus vault as a special world
  worlds.add({
    'id': 'bonus_vault',
    'index': 35,
    'name': 'The Bonus Vault',
    'wordCount': bonusWords.length,
    'levelCount': 0,
    'unlockRequirement': 'complete_all_campaign',
  });

  // ── Generate levels.json ──
  final List<Map<String, dynamic>> levels = [];

  for (var w = 0; w < 35; w++) {
    for (var l = 0; l < 10; l++) {
      final startIndex = w * 100 + l * 10;
      final wordIds =
          List.generate(10, (i) => 'w_${startIndex + i + 1}');
      final levelNumber = w * 10 + l + 1; // 1-350

      levels.add({
        'id': 'level_${levelNumber}',
        'worldId': 'world_${w + 1}',
        'worldIndex': w,
        'levelIndex': l,
        'levelNumber': levelNumber,
        'newWordIds': wordIds,
        'bossEnabled': (l + 1) % 5 == 0, // every 5th level (5, 10)
        'starReward': 3,
        'keyReward': (l + 1) % 5 == 0 ? 2 : 1, // boss levels give 2 keys
      });
    }
  }

  // ── Generate reward_catalog.json ──
  final List<Map<String, dynamic>> rewards = [];
  var rewardId = 0;

  // World completion rewards (35 rewards)
  for (var w = 0; w < 35; w++) {
    final motif = rewardTypes[w % rewardTypes.length];
    rewardId++;
    rewards.add({
      'id': 'reward_$rewardId',
      'name': _generateRewardName(w, motif['type']!),
      'type': motif['type'],
      'category': motif['category'],
      'unlockRule': 'complete_world_${w + 1}',
      'rarity': w % 7 == 0 ? 'rare' : (w % 3 == 0 ? 'uncommon' : 'common'),
    });
  }

  // Boss level rewards (70 rewards — 2 per world)
  for (var w = 0; w < 35; w++) {
    for (var bossLevel in [5, 10]) {
      rewardId++;
      final levelNum = w * 10 + bossLevel;
      rewards.add({
        'id': 'reward_$rewardId',
        'name': 'Boss Key ${w + 1}-$bossLevel',
        'type': 'key',
        'category': 'campaign',
        'unlockRule': 'complete_level_$levelNum',
        'rarity': bossLevel == 10 ? 'rare' : 'uncommon',
      });
    }
  }

  // Milestone rewards
  final milestones = [50, 100, 250, 500, 1000, 1500, 2000, 2500, 3000, 3500];
  for (final m in milestones) {
    rewardId++;
    rewards.add({
      'id': 'reward_$rewardId',
      'name': '$m Words Mastered',
      'type': 'badge',
      'category': 'milestone',
      'unlockRule': 'words_mastered_$m',
      'rarity': m >= 2000 ? 'legendary' : (m >= 500 ? 'rare' : 'uncommon'),
    });
  }

  // ── Write output files ──
  Directory(outputDir).createSync(recursive: true);

  _writeJson('$outputDir/words.json', wordEntries);
  _writeJson('$outputDir/worlds.json', worlds);
  _writeJson('$outputDir/levels.json', levels);
  _writeJson('$outputDir/reward_catalog.json', rewards);

  // ── Validation ──
  print('\n── Validation ──');
  _validate(wordEntries, worlds, levels, rewards);
}

Map<String, dynamic> _normalizeWord({
  required Map<String, dynamic> raw,
  required String id,
  required int index,
  required int worldIndex,
  required int levelIndex,
  required bool isBonus,
}) {
  return {
    'id': id,
    'sourceRank': int.tryParse(raw['sourceRank']?.toString() ?? '') ?? index + 1,
    'word': (raw['word'] as String?)?.trim() ?? '',
    'partOfSpeech': (raw['partOfSpeech'] as String?)?.trim() ?? '',
    'pronunciation': (raw['pronunciation'] as String?)?.trim() ?? '',
    'barronsMeaning': (raw['barronsMeaning'] as String?)?.trim() ?? '',
    'kidsMeaning': (raw['kidsMeaning'] as String?)?.trim() ?? '',
    'cueType': (raw['cueType'] as String?)?.trim() ?? 'situation',
    'cue': (raw['cue'] as String?)?.trim() ?? '',
    'memoryKey': (raw['memoryKey'] as String?)?.trim() ?? '',
    'synonyms': _splitField(raw['synonyms']),
    'antonyms': _splitField(raw['antonyms']),
    'usage1Simple': (raw['usage1Simple'] as String?)?.trim() ?? '',
    'usage2Standard': (raw['usage2Standard'] as String?)?.trim() ?? '',
    'worldIndex': worldIndex,
    'levelIndex': levelIndex,
    'isBonus': isBonus,
  };
}

List<String> _splitField(dynamic value) {
  if (value == null) return [];
  final str = value.toString().trim();
  if (str.isEmpty) return [];
  return str
      .split(RegExp(r'[;,]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

String _generateRewardName(int worldIndex, String type) {
  final adjectives = [
    'Golden', 'Silver', 'Crystal', 'Emerald', 'Ruby',
    'Starlit', 'Ancient', 'Mystic', 'Royal', 'Enchanted',
    'Blazing', 'Frozen', 'Shadow', 'Radiant', 'Celestial',
    'Thunder', 'Coral', 'Amber', 'Sapphire', 'Moonlit',
    'Iron', 'Velvet', 'Crimson', 'Jade', 'Obsidian',
    'Prism', 'Storm', 'Dawn', 'Twilight', 'Ethereal',
    'Luminous', 'Gilded', 'Phantom', 'Verdant', 'Final',
  ];

  final nouns = {
    'badge': ['Shield', 'Crest', 'Emblem', 'Medal', 'Seal'],
    'sticker': ['Gem', 'Star', 'Charm', 'Glyph', 'Rune'],
    'pet': ['Fox', 'Owl', 'Dragon', 'Phoenix', 'Griffin'],
    'outfit': ['Cape', 'Crown', 'Armor', 'Boots', 'Cloak'],
    'room_prop': ['Lamp', 'Banner', 'Throne', 'Bookshelf', 'Tapestry'],
  };

  final adj = adjectives[worldIndex % adjectives.length];
  final nounList = nouns[type] ?? ['Trophy'];
  final noun = nounList[worldIndex % nounList.length];

  return '$adj $noun';
}

void _writeJson(String path, dynamic data) {
  final encoder = JsonEncoder.withIndent('  ');
  File(path).writeAsStringSync(encoder.convert(data));
  final sizeKb = (File(path).lengthSync() / 1024).toStringAsFixed(1);
  print('Wrote $path (${sizeKb}KB)');
}

void _validate(
  List<Map<String, dynamic>> words,
  List<Map<String, dynamic>> worlds,
  List<Map<String, dynamic>> levels,
  List<Map<String, dynamic>> rewards,
) {
  var errors = 0;

  // Check total counts
  final campaignWords = words.where((w) => w['isBonus'] == false).length;
  final bonusWords = words.where((w) => w['isBonus'] == true).length;

  if (campaignWords != 3500) {
    print('ERROR: Expected 3500 campaign words, got $campaignWords');
    errors++;
  }
  if (bonusWords != 23) {
    print('WARNING: Expected 23 bonus words, got $bonusWords');
  }
  if (worlds.length != 36) {
    // 35 campaign + 1 bonus vault
    print('ERROR: Expected 36 worlds, got ${worlds.length}');
    errors++;
  }
  if (levels.length != 350) {
    print('ERROR: Expected 350 levels, got ${levels.length}');
    errors++;
  }

  // Check each level has exactly 10 words
  for (final level in levels) {
    final wordIds = level['newWordIds'] as List;
    if (wordIds.length != 10) {
      print(
          'ERROR: Level ${level['id']} has ${wordIds.length} words (expected 10)');
      errors++;
    }
  }

  // Check no duplicate word IDs
  final allIds = words.map((w) => w['id'] as String).toSet();
  if (allIds.length != words.length) {
    print('ERROR: Duplicate word IDs found');
    errors++;
  }

  // Check all level wordIds reference existing words
  for (final level in levels) {
    for (final wordId in level['newWordIds']) {
      if (!allIds.contains(wordId)) {
        print('ERROR: Level ${level['id']} references unknown word $wordId');
        errors++;
      }
    }
  }

  // Check boss levels
  final bossLevels = levels.where((l) => l['bossEnabled'] == true).length;
  if (bossLevels != 70) {
    // 2 per world (level 5 and 10)
    print('WARNING: Expected 70 boss levels, got $bossLevels');
  }

  // Check missing required fields
  var missingPronunciation = 0;
  var missingKidsMeaning = 0;
  var missingMemoryKey = 0;
  var missingCue = 0;

  for (final w in words) {
    if ((w['pronunciation'] as String).isEmpty) missingPronunciation++;
    if ((w['kidsMeaning'] as String).isEmpty) missingKidsMeaning++;
    if ((w['memoryKey'] as String).isEmpty) missingMemoryKey++;
    if ((w['cue'] as String).isEmpty) missingCue++;
  }

  print('Words with missing pronunciation: $missingPronunciation');
  print('Words with missing kidsMeaning: $missingKidsMeaning');
  print('Words with missing memoryKey: $missingMemoryKey');
  print('Words with missing cue: $missingCue');

  if (errors == 0) {
    print('\n✓ All validations passed!');
  } else {
    print('\n✗ $errors validation errors found');
  }

  print('\nManifest summary:');
  print('  Words: ${words.length} (${campaignWords} campaign + $bonusWords bonus)');
  print('  Worlds: ${worlds.length - 1} campaign + 1 bonus vault');
  print('  Levels: ${levels.length} (${bossLevels} boss levels)');
  print('  Rewards: ${rewards.length}');
}
