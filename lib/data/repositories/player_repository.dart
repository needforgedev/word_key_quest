import 'dart:math';
import '../local_db/database_service.dart';
import '../models/models.dart';

/// Manages the player profile — creation, updates, and stat tracking.
///
/// Single profile per device for MVP.
class PlayerRepository {
  final DatabaseService _db;

  PlayerRepository(this._db);

  /// Get the current player profile, or null if none exists (first launch).
  Future<PlayerProfile?> getProfile() => _db.getPlayerProfile();

  /// Create a new player profile (during onboarding).
  Future<PlayerProfile> createProfile({
    required String name,
    required int ageBand,
    required int avatarId,
    required String selectedTheme,
  }) async {
    // Generate a unique random seed for this player's word order
    final seed = Random().nextInt(1 << 31);

    final profile = PlayerProfile(
      id: 'player_1',
      name: name,
      ageBand: ageBand,
      avatarId: avatarId,
      selectedTheme: selectedTheme,
      wordOrderSeed: seed,
      lastPlayedAt: DateTime.now(),
      streakStartDate: DateTime.now(),
    );
    await _db.savePlayerProfile(profile);
    return profile;
  }

  /// Save the full profile (after any update).
  Future<void> saveProfile(PlayerProfile profile) =>
      _db.savePlayerProfile(profile);

  /// Award stars to the player.
  Future<PlayerProfile> addStars(PlayerProfile profile, int amount) async {
    final updated = profile.copyWith(stars: profile.stars + amount);
    await _db.savePlayerProfile(updated);
    return updated;
  }

  /// Award keys to the player.
  Future<PlayerProfile> addKeys(PlayerProfile profile, int amount) async {
    final updated = profile.copyWith(keys: profile.keys + amount);
    await _db.savePlayerProfile(updated);
    return updated;
  }

  /// Advance to the next level. If at end of world, advance to next world.
  Future<PlayerProfile> advanceLevel(PlayerProfile profile) async {
    int nextWorld = profile.currentWorld;
    int nextLevel = profile.currentLevel + 1;

    if (nextLevel >= 10) {
      nextWorld++;
      nextLevel = 0;
    }

    // Cap at world 34, level 9 (last campaign level)
    if (nextWorld > 34) {
      nextWorld = 34;
      nextLevel = 9;
    }

    final updated = profile.copyWith(
      currentWorld: nextWorld,
      currentLevel: nextLevel,
    );
    await _db.savePlayerProfile(updated);
    return updated;
  }

  /// Update the daily streak.
  /// Call this when the player completes a session.
  Future<PlayerProfile> updateStreak(PlayerProfile profile) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak = profile.streakCount;
    DateTime? streakStart = profile.streakStartDate;

    if (profile.lastPlayedAt != null) {
      final lastPlayed = profile.lastPlayedAt!;
      final lastDay =
          DateTime(lastPlayed.year, lastPlayed.month, lastPlayed.day);
      final diff = today.difference(lastDay).inDays;

      if (diff == 0) {
        // Already played today, no streak change
      } else if (diff == 1) {
        // Consecutive day — extend streak
        newStreak++;
      } else {
        // Streak broken — reset
        newStreak = 1;
        streakStart = today;
      }
    } else {
      // First ever session
      newStreak = 1;
      streakStart = today;
    }

    final updated = profile.copyWith(
      streakCount: newStreak,
      lastPlayedAt: now,
      streakStartDate: streakStart,
    );
    await _db.savePlayerProfile(updated);
    return updated;
  }

  /// Update the selected theme.
  Future<PlayerProfile> updateTheme(
      PlayerProfile profile, String theme) async {
    final updated = profile.copyWith(selectedTheme: theme);
    await _db.savePlayerProfile(updated);
    return updated;
  }

  /// Update the avatar.
  Future<PlayerProfile> updateAvatar(
      PlayerProfile profile, int avatarId) async {
    final updated = profile.copyWith(avatarId: avatarId);
    await _db.savePlayerProfile(updated);
    return updated;
  }
}
