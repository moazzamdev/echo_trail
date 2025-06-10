// lib\screens\speech_text.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../main.dart'; // to get the global `voiceService`


class WakeWordScreen extends StatefulWidget {
  const WakeWordScreen({super.key});

  @override
  State<WakeWordScreen> createState() => _WakeWordScreenState();
}

class _WakeWordScreenState extends State<WakeWordScreen> {
  late FlutterTts _tts;
  bool _isListening = false;
  final String _lastSpoken = "";
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _initializeTts();
    _startVoiceRecognition();
  }

  Future<void> _initializeTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.speak("Say Echo to activate voice commands.");
    } catch (e) {
      debugPrint('❌ Failed to initialize TTS: $e');
      setState(() => _errorMessage = 'Failed to initialize text-to-speech');
    }
  }

  Future<void> _startVoiceRecognition() async {
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      debugPrint('❌ Microphone permission denied');
      setState(() => _errorMessage = 'Microphone permission denied');
      await _tts.speak('Microphone permission denied. Please grant permission in settings.');
      return;
    }

    try {
      await voiceService.init(); // ✅ Init first — ensures `_initialized = true`
      voiceService.startVoiceRecognition(); // ✅ Start listening
      setState(() {
        _isListening = true;
        _errorMessage = "";
      });
    } catch (e) {
      debugPrint("❌ Failed to start voice recognition: $e");
      setState(() => _errorMessage = 'Failed to start voice recognition');
      await _tts.speak('Failed to start voice recognition. Please try again.');
    }
  }


  @override
  void dispose() {
    voiceService.stop(); // ✅ Changed from stopListening to stop
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : _lastSpoken.isEmpty
                  ? 'Say "echo" to activate...'
                  : 'You said: $_lastSpoken',
              style: TextStyle(
                color: _errorMessage.isNotEmpty
                    ? Colors.redAccent
                    : _isListening
                    ? Colors.greenAccent
                    : Colors.white,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: _isListening ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: const Text(
                "Listening for command...",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedOpacity(
              opacity: _isListening ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: const CircularProgressIndicator(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
