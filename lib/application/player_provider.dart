import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import 'service_providers.dart';

/// Manages the player profile state.
class PlayerNotifier extends AsyncNotifier<PlayerProfile?> {
  @override
  Future<PlayerProfile?> build() async {
    return ref.read(playerRepositoryProvider).getProfile();
  }

  /// Create a new profile during onboarding.
  Future<PlayerProfile> createProfile({
    required String name,
    required int ageBand,
    required int avatarId,
    required String selectedTheme,
  }) async {
    final profile = await ref.read(playerRepositoryProvider).createProfile(
          name: name,
          ageBand: ageBand,
          avatarId: avatarId,
          selectedTheme: selectedTheme,
        );
    state = AsyncValue.data(profile);
    return profile;
  }

  /// Refresh from database.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(
        await ref.read(playerRepositoryProvider).getProfile());
  }

  /// Update profile after external changes (e.g., session completion).
  void updateProfile(PlayerProfile profile) {
    state = AsyncValue.data(profile);
  }

  /// Update the selected theme.
  Future<void> updateTheme(String theme) async {
    final current = state.value;
    if (current == null) return;
    final updated =
        await ref.read(playerRepositoryProvider).updateTheme(current, theme);
    state = AsyncValue.data(updated);
  }

  /// Update the avatar.
  Future<void> updateAvatar(int avatarId) async {
    final current = state.value;
    if (current == null) return;
    final updated = await ref
        .read(playerRepositoryProvider)
        .updateAvatar(current, avatarId);
    state = AsyncValue.data(updated);
  }
}

final playerProvider =
    AsyncNotifierProvider<PlayerNotifier, PlayerProfile?>(() {
  return PlayerNotifier();
});

/// Convenience: the current profile or null (non-async).
final currentProfileProvider = Provider<PlayerProfile?>((ref) {
  return ref.watch(playerProvider).value;
});
