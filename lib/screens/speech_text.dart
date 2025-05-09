import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class WakeWordScreen extends StatefulWidget {
  @override
  _WakeWordScreenState createState() => _WakeWordScreenState();
}

class _WakeWordScreenState extends State<WakeWordScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final List<String> wakeWords = ['hello', 'echo'];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await Permission.microphone.request();
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(
      onStatus: _statusListener,
      onError: (error) => print('Speech error: $error'),
    );
    if (available) _startWakeWordListening();
  }

  void _statusListener(String status) {
    if (status == 'done' || status == 'notListening') {
      Future.delayed(Duration(milliseconds: 500), () {
        if (!_speech.isListening) _startWakeWordListening();
      });
    }
  }

  void _startWakeWordListening() {
    if (_isListening) return;
    _isListening = true;

    _speech.listen(
      onResult: (result) {
        String spokenText = result.recognizedWords.toLowerCase();
        print('Heard: $spokenText');
        if (wakeWords.any((word) => spokenText.contains(word))) {
          _showWakePopup(spokenText);
        }
      },
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      cancelOnError: false,
      pauseFor: Duration(seconds: 5),
    );
  }

  void _showWakePopup(String text) {
    _speech.stop();
    _isListening = false;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Wake word detected!'),
            content: Text('You said: $text'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startWakeWordListening();
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Say "hello" or "echo" to activate...',
          style: TextStyle(color: Colors.white, fontSize: 22),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
