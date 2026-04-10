import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/settings_repository.dart';
export '../data/repositories/settings_repository.dart' show AppSettings;
import 'service_providers.dart';

/// Manages app settings state (audio, accessibility, difficulty).
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _load();
    return const AppSettings();
  }

  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  Future<void> _load() async {
    state = await _repo.loadAll();
  }

  Future<void> setMusicEnabled(bool value) async {
    await _repo.setMusicEnabled(value);
    state = state.copyWith(musicEnabled: value);
  }

  Future<void> setVoiceEnabled(bool value) async {
    await _repo.setVoiceEnabled(value);
    state = state.copyWith(voiceEnabled: value);
  }

  Future<void> setDyslexiaFont(bool value) async {
    await _repo.setDyslexiaFontEnabled(value);
    state = state.copyWith(dyslexiaFont: value);
  }

  Future<void> setTextSize(String size) async {
    await _repo.setTextSize(size);
    state = state.copyWith(textSize: size);
  }

  Future<void> setDifficulty(String difficulty) async {
    await _repo.setDifficulty(difficulty);
    state = state.copyWith(difficulty: difficulty);
  }

  Future<void> setAudioCues(bool value) async {
    await _repo.setAudioCuesEnabled(value);
    state = state.copyWith(audioCues: value);
  }

  Future<void> setVisualCues(bool value) async {
    await _repo.setVisualCuesEnabled(value);
    state = state.copyWith(visualCues: value);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});
