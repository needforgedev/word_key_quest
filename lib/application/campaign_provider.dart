import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import 'service_providers.dart';
import 'player_provider.dart';

/// Manages campaign progression: which worlds/levels are unlocked,
/// current position, and completion state.
class CampaignNotifier extends Notifier<CampaignState> {
  @override
  CampaignState build() {
    _load();
    return CampaignState.initial();
  }

  Future<void> _load() async {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return;

    final worlds =
        await ref.read(contentRepositoryProvider).getCampaignWorlds();
    final currentLevels = await ref
        .read(contentRepositoryProvider)
        .getLevelsForWorld(profile.currentWorld);

    state = CampaignState(
      worlds: worlds,
      currentWorldIndex: profile.currentWorld,
      currentLevelIndex: profile.currentLevel,
      currentWorldLevels: currentLevels,
      isLoaded: true,
    );
  }

  /// Refresh after level completion or profile change.
  Future<void> refresh() async => _load();

  /// Whether a specific world is unlocked.
  bool isWorldUnlocked(int worldIndex) {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return false;
    return worldIndex <= profile.currentWorld;
  }

  /// Whether a specific level within a world is unlocked.
  bool isLevelUnlocked(int worldIndex, int levelIndex) {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return false;

    if (worldIndex < profile.currentWorld) return true;
    if (worldIndex == profile.currentWorld) {
      return levelIndex <= profile.currentLevel;
    }
    return false;
  }

  /// Whether a level has been completed.
  bool isLevelCompleted(int worldIndex, int levelIndex) {
    final profile = ref.read(currentProfileProvider);
    if (profile == null) return false;

    if (worldIndex < profile.currentWorld) return true;
    if (worldIndex == profile.currentWorld) {
      return levelIndex < profile.currentLevel;
    }
    return false;
  }

  /// Load levels for a specific world.
  Future<List<Level>> loadWorldLevels(int worldIndex) async {
    final levels = await ref
        .read(contentRepositoryProvider)
        .getLevelsForWorld(worldIndex);
    if (worldIndex == state.currentWorldIndex) {
      state = state.copyWith(currentWorldLevels: levels);
    }
    return levels;
  }
}

/// Campaign state snapshot.
class CampaignState {
  final List<World> worlds;
  final int currentWorldIndex;
  final int currentLevelIndex;
  final List<Level> currentWorldLevels;
  final bool isLoaded;

  const CampaignState({
    required this.worlds,
    required this.currentWorldIndex,
    required this.currentLevelIndex,
    required this.currentWorldLevels,
    required this.isLoaded,
  });

  factory CampaignState.initial() => const CampaignState(
        worlds: [],
        currentWorldIndex: 0,
        currentLevelIndex: 0,
        currentWorldLevels: [],
        isLoaded: false,
      );

  World? get currentWorld =>
      worlds.isNotEmpty && currentWorldIndex < worlds.length
          ? worlds[currentWorldIndex]
          : null;

  Level? get currentLevel => currentWorldLevels.isNotEmpty &&
          currentLevelIndex < currentWorldLevels.length
      ? currentWorldLevels[currentLevelIndex]
      : null;

  int get globalLevel => currentWorldIndex * 10 + currentLevelIndex + 1;

  CampaignState copyWith({
    List<World>? worlds,
    int? currentWorldIndex,
    int? currentLevelIndex,
    List<Level>? currentWorldLevels,
    bool? isLoaded,
  }) {
    return CampaignState(
      worlds: worlds ?? this.worlds,
      currentWorldIndex: currentWorldIndex ?? this.currentWorldIndex,
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
      currentWorldLevels: currentWorldLevels ?? this.currentWorldLevels,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

final campaignProvider =
    NotifierProvider<CampaignNotifier, CampaignState>(() {
  return CampaignNotifier();
});
