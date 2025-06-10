/* // lib/screens/fullscreen_alarm.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'package:echo_trail/utils/platform_alarm.dart'

class FullScreenAlarm extends StatefulWidget {
  const FullScreenAlarm({super.key});

  @override
  State<FullScreenAlarm> createState() => _FullScreenAlarmState();
}

class _FullScreenAlarmState extends State<FullScreenAlarm> {
  final FlutterTts _tts = FlutterTts();
  Timer? _repeatTimer;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _announceAlarm();
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  void _announceAlarm() {
    // Announce the alarm immediately
    _tts.speak("Your alarm is ringing. Time to wake up.");

    // Repeat the announcement every 15 seconds until dismissed
    _repeatTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _tts.speak("Your alarm is still ringing. Please wake up.");
    });
  }

  void _dismiss() {
    _repeatTimer?.cancel();
    _tts.speak("Alarm dismissed");
    Navigator.pop(context);
  }

  ?.cancel();
   void _snooze() {
       _repeatTimer _tts.speak("Alarm snoozed for 5 minutes");

    // Schedule a delayed navigation back to this page after 5 minutes
    // You could enhance this to use the platform-specific alarm for more reliability
    Future.delayed(const Duration(minutes: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FullScreenAlarm()),
        );
      }
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/alarm_clock.png',
                height: 120,
                width: 120,
                color: Colors.white,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.alarm,
                  size: 120,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                '⏰ Alarm Ringing',
                style: TextStyle(fontSize: 28, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Time to wake up!',
                style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.8)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _dismiss,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text('Dismiss', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _snooze,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text('Snooze 5 min', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
