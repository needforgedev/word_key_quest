import 'package:flutter_tts/flutter_tts.dart';
import '../../data/models/models.dart';

/// Text-to-Speech service for word pronunciation and memory key narration.
///
/// Uses the device's built-in speech engine (offline):
///   - iOS: AVSpeechSynthesizer
///   - Android: Google TTS
///
/// Optimized for vocabulary learning:
///   - Slower rate for word pronunciation (clarity for children)
///   - Normal rate for sentences and memory keys
///   - English (US) locale
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  /// Initialize the TTS engine with child-friendly settings.
  Future<void> init() async {
    if (_isInitialized) return;

    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
    });

    _isInitialized = true;
  }

  /// Whether the TTS engine is currently speaking.
  bool get isSpeaking => _isSpeaking;

  /// Speak a word clearly and slowly (for pronunciation).
  Future<void> speakWord(String word) async {
    await init();
    await stop();
    // Slower rate for clear pronunciation
    await _tts.setSpeechRate(0.35);
    _isSpeaking = true;
    await _tts.speak(word);
  }

  /// Speak a meaning or short phrase at normal pace.
  Future<void> speakMeaning(String meaning) async {
    await init();
    await stop();
    await _tts.setSpeechRate(0.45);
    _isSpeaking = true;
    await _tts.speak(meaning);
  }

  /// Speak the memory key story at a comfortable listening pace.
  Future<void> speakMemoryKey(String memoryKey) async {
    await init();
    await stop();
    await _tts.setSpeechRate(0.4);
    _isSpeaking = true;
    await _tts.speak(memoryKey);
  }

  /// Speak a sentence (usage example) at normal pace.
  Future<void> speakSentence(String sentence) async {
    await init();
    await stop();
    await _tts.setSpeechRate(0.45);
    _isSpeaking = true;
    await _tts.speak(sentence);
  }

  /// Speak a full word card: word, then meaning, then memory key.
  Future<void> speakWordCard(WordEntry word) async {
    await init();
    await stop();

    // Speak the word slowly
    await _tts.setSpeechRate(0.35);
    _isSpeaking = true;
    await _tts.speak(word.word);

    // Brief pause then meaning
    await Future.delayed(const Duration(milliseconds: 800));
    if (!_isSpeaking) return; // stopped externally

    await _tts.setSpeechRate(0.45);
    await _tts.speak(word.kidsMeaning);
  }

  /// Stop any current speech.
  Future<void> stop() async {
    _isSpeaking = false;
    await _tts.stop();
  }

  /// Clean up resources.
  Future<void> dispose() async {
    await stop();
  }
}
