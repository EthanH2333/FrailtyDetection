import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final FlutterTts flutterTts = FlutterTts();
  String? _currentTextBeingSpoken;

  SpeechService() {
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(1.0);
      await flutterTts.setPitch(1.0);
    } catch (e) {
      print("Error initializing TTS: $e");
    }
  }

  // Function to speak the provided text
  Future<void> speak(String text) async {
    if (_currentTextBeingSpoken == text) {
      // If the same text is clicked again, stop speaking
      await stop();
      _currentTextBeingSpoken = null;
    } else {
      // Stop current speech and speak new text
      await stop();
      _currentTextBeingSpoken = text;
      try {
        await flutterTts.speak(text);
      } catch (e) {
        print("Error during speak: $e");
      }
    }
  }

  // Stop speaking
  Future<void> stop() async {
    try {
      await flutterTts.stop();
    } catch (e) {
      print("Error stopping TTS: $e");
    }
  }
}
