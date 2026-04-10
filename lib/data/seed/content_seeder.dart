import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../local_db/database_service.dart';
import '../models/models.dart';

/// Loads JSON manifest files from assets and seeds them into the SQLite database.
///
/// Called once on first launch. Subsequent launches skip seeding
/// because [DatabaseService.isSeeded] returns true.
class ContentSeeder {
  final DatabaseService _db;

  ContentSeeder(this._db);

  /// Seeds all content tables if not already seeded.
  /// Returns true if seeding was performed, false if already seeded.
  Future<bool> seedIfNeeded() async {
    if (await _db.isSeeded()) return false;

    await _seedWords();
    await _seedWorlds();
    await _seedLevels();
    await _seedRewards();

    return true;
  }

  Future<void> _seedWords() async {
    final jsonStr = await rootBundle.loadString('assets/data/words.json');
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    final words = jsonList.map((j) => WordEntry.fromJson(j as Map<String, dynamic>)).toList();
    await _db.seedWords(words);
  }

  Future<void> _seedWorlds() async {
    final jsonStr = await rootBundle.loadString('assets/data/worlds.json');
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    final worlds = jsonList.map((j) => World.fromJson(j as Map<String, dynamic>)).toList();
    await _db.seedWorlds(worlds);
  }

  Future<void> _seedLevels() async {
    final jsonStr = await rootBundle.loadString('assets/data/levels.json');
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    final levels = jsonList.map((j) => Level.fromJson(j as Map<String, dynamic>)).toList();
    await _db.seedLevels(levels);
  }

  Future<void> _seedRewards() async {
    final jsonStr = await rootBundle.loadString('assets/data/reward_catalog.json');
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    final rewards = jsonList.map((j) => RewardItem.fromJson(j as Map<String, dynamic>)).toList();
    await _db.seedRewards(rewards);
  }
}
