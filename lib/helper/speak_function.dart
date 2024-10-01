import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  // Create a single instance of FlutterTts to avoid re-initialization
  final FlutterTts flutterTts = FlutterTts();

  // Initialization can happen in a constructor or at the app start.
  SpeechService() {
    _initializeTts();
  }

  // This method initializes the TTS settings
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
    try {
      await flutterTts.speak(text);
    } catch (e) {
      print("Error during speak: $e");
    }
  }

  // Optionally stop the TTS if needed
  Future<void> stop() async {
    try {
      await flutterTts.stop();
    } catch (e) {
      print("Error stopping TTS: $e");
    }
  }
}
