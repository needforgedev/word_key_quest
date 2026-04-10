import 'package:shared_preferences/shared_preferences.dart';

/// Manages app settings using SharedPreferences.
///
/// Lightweight key-value store for toggles and preferences
/// that don't need relational queries.
class SettingsRepository {
  static const _keyMusicEnabled = 'settings_music_enabled';
  static const _keyVoiceEnabled = 'settings_voice_enabled';
  static const _keyDyslexiaFont = 'settings_dyslexia_font';
  static const _keyTextSize = 'settings_text_size'; // 'small', 'medium', 'large'
  static const _keyDifficulty = 'settings_difficulty'; // 'easy', 'intermediate', 'hard'
  static const _keyAudioCues = 'settings_audio_cues';
  static const _keyVisualCues = 'settings_visual_cues';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── Audio ──

  Future<bool> isMusicEnabled() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyMusicEnabled) ?? true;
  }

  Future<void> setMusicEnabled(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyMusicEnabled, value);
  }

  Future<bool> isVoiceEnabled() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyVoiceEnabled) ?? true;
  }

  Future<void> setVoiceEnabled(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyVoiceEnabled, value);
  }

  Future<bool> isAudioCuesEnabled() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyAudioCues) ?? true;
  }

  Future<void> setAudioCuesEnabled(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyAudioCues, value);
  }

  // ── Accessibility ──

  Future<bool> isDyslexiaFontEnabled() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyDyslexiaFont) ?? false;
  }

  Future<void> setDyslexiaFontEnabled(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyDyslexiaFont, value);
  }

  Future<String> getTextSize() async {
    final prefs = await _preferences;
    return prefs.getString(_keyTextSize) ?? 'medium';
  }

  Future<void> setTextSize(String size) async {
    final prefs = await _preferences;
    await prefs.setString(_keyTextSize, size);
  }

  Future<bool> isVisualCuesEnabled() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyVisualCues) ?? true;
  }

  Future<void> setVisualCuesEnabled(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyVisualCues, value);
  }

  // ── Difficulty ──

  Future<String> getDifficulty() async {
    final prefs = await _preferences;
    return prefs.getString(_keyDifficulty) ?? 'intermediate';
  }

  Future<void> setDifficulty(String difficulty) async {
    final prefs = await _preferences;
    await prefs.setString(_keyDifficulty, difficulty);
  }

  /// Load all settings at once for provider initialization.
  Future<AppSettings> loadAll() async {
    return AppSettings(
      musicEnabled: await isMusicEnabled(),
      voiceEnabled: await isVoiceEnabled(),
      dyslexiaFont: await isDyslexiaFontEnabled(),
      textSize: await getTextSize(),
      difficulty: await getDifficulty(),
      audioCues: await isAudioCuesEnabled(),
      visualCues: await isVisualCuesEnabled(),
    );
  }
}

/// Snapshot of all app settings, used by the settings provider.
class AppSettings {
  final bool musicEnabled;
  final bool voiceEnabled;
  final bool dyslexiaFont;
  final String textSize;
  final String difficulty;
  final bool audioCues;
  final bool visualCues;

  const AppSettings({
    this.musicEnabled = true,
    this.voiceEnabled = true,
    this.dyslexiaFont = false,
    this.textSize = 'medium',
    this.difficulty = 'intermediate',
    this.audioCues = true,
    this.visualCues = true,
  });

  AppSettings copyWith({
    bool? musicEnabled,
    bool? voiceEnabled,
    bool? dyslexiaFont,
    String? textSize,
    String? difficulty,
    bool? audioCues,
    bool? visualCues,
  }) {
    return AppSettings(
      musicEnabled: musicEnabled ?? this.musicEnabled,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      dyslexiaFont: dyslexiaFont ?? this.dyslexiaFont,
      textSize: textSize ?? this.textSize,
      difficulty: difficulty ?? this.difficulty,
      audioCues: audioCues ?? this.audioCues,
      visualCues: visualCues ?? this.visualCues,
    );
  }
}
