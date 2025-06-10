// lib/services/voice_service.dart
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'app_state.dart';
import 'package:permission_handler/permission_handler.dart';
import '../screens/navigation_live.dart';
import '../screens/setting.dart';
import 'package:flutter/material.dart';

class VoiceService {
  final FlutterTts _tts = FlutterTts();
  final MethodChannel _channel = const MethodChannel('com.echo_trail/voice_service');
  final EventChannel _eventChannel = const EventChannel('com.echo_trail/voice_stream');
  bool _isInitialized = false;
  bool _isProcessingCommand = false;
  bool _awaitingCommand = false;

  Future<void> init() async {
    if (_isInitialized) return;

    print("🔊 Initializing Voice Service");
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _channel.setMethodCallHandler(_handleMethodCall);

      await _tts.speak("Voice service ready. Say Echo to activate.");

      listenForWakeWordEvents();
      await _channel.invokeMethod('startVoiceRecognition');

      _isInitialized = true;
    } catch (e) {
      print("❌ Failed to initialize voice service: $e");
      await _tts.speak("Failed to initialize voice service. Please restart the app.");
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    print("📡 Method call received: ${call.method}");
    switch (call.method) {
      case 'onWakeWordDetected':
        print("🌟 Wake word detected!");
        await _tts.speak("I'm listening");
        _awaitingCommand = true;
        await startCommandListener();
        break;

      case 'onCommandDetected':
        final command = call.arguments as String;
        print("🎯 Command detected: $command");
        _awaitingCommand = false;
        await _processCommand(command);
        break;

      case 'onError':
        print("❌ Error: ${call.arguments}");
        await _tts.speak("Speech recognition error. Retrying...");
        await Future.delayed(Duration(seconds: 2));

        if (!_awaitingCommand && !_isProcessingCommand) {
          await _channel.invokeMethod('startVoiceRecognition');
        }
        break;

      default:
        print("⚠️ Unknown method call: ${call.method}");
    }
    return null;
  }

  void listenForWakeWordEvents() {
    _eventChannel.receiveBroadcastStream().listen((event) async {
      final text = event.toString().toLowerCase();

      if (text == 'wake_word') {
        print("🌟 Wake word detected from stream");
        await _tts.speak("I'm listening");
        _awaitingCommand = true;
        await startCommandListener();
      } else if (text.isNotEmpty) {
        print("🎯 Command detected from stream: $text");
        _awaitingCommand = false;
        await _processCommand(text);
      }
    }, onError: (e) {
      print("❌ Error in event stream: $e");
    });
  }

  Future<void> startCommandListener() async {
    if (_isProcessingCommand || _awaitingCommand) {
      print("🚫 Command listener skipped: processing=$_isProcessingCommand, awaiting=$_awaitingCommand");
      return;
    }

    print("👂 Starting command listener");
    try {
      await _channel.invokeMethod('startCommandListener');
      _awaitingCommand = true;
    } catch (e) {
      print("❌ Failed to start command listener: $e");
      await _tts.speak("Failed to start listening. Please try again.");
    }
  }

  void startVoiceRecognition() {
    if (!_isInitialized) {
      print("⚠️ startVoiceRecognition() called before init()");
      return;
    }

    if (_isProcessingCommand || _awaitingCommand) {
      print("🚫 Voice recognition skipped: processing=$_isProcessingCommand, awaiting=$_awaitingCommand");
      return;
    }

    _channel.invokeMethod('startVoiceRecognition');
  }

  void stop() {
    if (!_isInitialized) {
      print("⚠️ stop() called before init()");
      return;
    }

    _channel.invokeMethod('stopVoiceRecognition');
    _awaitingCommand = false;
    _isProcessingCommand = false;
    print("🛑 Stopped voice recognition");
  }

  Future<void> _processCommand(String spokenText) async {
    if (_isProcessingCommand) {
      print("🚫 Command processing skipped: already processing");
      return;
    }

    final context = navigatorKey.currentContext;
    if (context == null) {
      print("⚠️ No context available for processing command.");
      await _tts.speak("Context not ready. Please try again.");
      return;
    }

    _isProcessingCommand = true;
    final appState = Provider.of<AppState>(context, listen: false);
    final lowerText = spokenText.toLowerCase();

    print("🔄 Processing command: $lowerText");

    try {
      // Navigation Commands
      if (lowerText.contains('open navigation') || lowerText.contains('start navigation') || lowerText.contains('navigation')) {
        await _handleOpenNavigation(context);
      }
      
      else if (lowerText.contains('exit navigation') || lowerText.contains('close navigation') || lowerText.contains('stop navigation')) {
        await _handleCloseNavigation(context);
      }
      
      // Settings Commands
      else if (lowerText.contains('open settings') || lowerText.contains('open setting') || lowerText.contains('settings') || lowerText.contains('setting')) {
        await _handleOpenSettings(context);
      }
      
      else if (lowerText.contains('close settings') || lowerText.contains('exit settings') || lowerText.contains('back to dashboard')) {
        await _handleBackToDashboard(context);
      }

      // Battery Commands
      else if (lowerText.contains('battery') && lowerText.contains(RegExp(r'threshold|limit|level'))) {
        await _handleBatteryThreshold(lowerText, appState);
      }

      // Alarm Commands
      else if (lowerText.contains('alarm for') || lowerText.contains('set alarm') || lowerText.contains('alarm at')) {
        await _handleSetAlarm(lowerText, appState);
      }

      else if (lowerText.contains('delete') && lowerText.contains('alarm')) {
        await _handleDeleteAlarm(appState);
      }

      else if (lowerText.contains('snooze')) {
        await _handleSnoozeAlarm(lowerText);
      }

      else if (lowerText.contains('dismiss')) {
        await _handleDismissAlarm();
      }

      else {
        await _tts.speak("Sorry, I didn't understand that. Try saying open navigation, open settings, set alarm, or set battery threshold.");
      }
    } catch (e) {
      print("❌ Error in _processCommand: $e");
      await _tts.speak("Something went wrong. Please try again.");
    } finally {
      _isProcessingCommand = false;

      if (!_awaitingCommand) {
        await Future.delayed(Duration(milliseconds: 500));
        await _channel.invokeMethod('startVoiceRecognition');
      }
    }
  }

  Future<void> _handleOpenNavigation(BuildContext context) async {
    await _tts.speak("Opening navigation, please wait.");

    // Request camera and microphone permissions
    final camStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (camStatus.isGranted && micStatus.isGranted) {
      // Navigate to navigation screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => NavigationLiveScreen())
      );
      await _tts.speak("Navigation is now active. Point your camera forward for guidance.");
    } else {
      await _tts.speak("Camera or microphone permission denied. Please grant permissions to use navigation.");
    }
  }

  Future<void> _handleCloseNavigation(BuildContext context) async {
    await _tts.speak("Closing navigation, returning to dashboard.");
    
    // Pop back to dashboard (first route)
    Navigator.of(context).popUntil((route) => route.isFirst);
    
    // Small delay to allow navigation to complete
    await Future.delayed(Duration(milliseconds: 500));
    await _tts.speak("Returned to dashboard.");
  }

  Future<void> _handleOpenSettings(BuildContext context) async {
    await _tts.speak("Opening settings.");
    
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 900),
        pageBuilder: (context, animation, secondaryAnimation) => SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
    
    await Future.delayed(Duration(milliseconds: 1000));
    await _tts.speak("Settings opened. You can manage your preferences here.");
  }

  Future<void> _handleBackToDashboard(BuildContext context) async {
    await _tts.speak("Going back to dashboard.");
    
    // Pop back to dashboard
    Navigator.of(context).popUntil((route) => route.isFirst);
    
    await Future.delayed(Duration(milliseconds: 500));
    await _tts.speak("Back to dashboard.");
  }

  Future<void> _handleBatteryThreshold(String lowerText, AppState appState) async {
    final match = RegExp(r'(\d{1,3})\s*(percent|%)').firstMatch(lowerText);
    if (match != null) {
      final int value = int.parse(match.group(1)!);
      if (value >= 1 && value <= 100) {
        await MethodChannel('com.echo_trail/battery').invokeMethod('setThreshold', {'threshold': value});
        appState.setBatteryThreshold(value);
        await _tts.speak("Battery threshold set to $value percent.");
      } else {
        await _tts.speak("Please specify a battery threshold between 1 and 100 percent.");
      }
    } else {
      await _tts.speak("Please specify a battery threshold percentage. For example, say set battery threshold to 20 percent.");
    }
  }

  Future<void> _handleSetAlarm(String spokenText, AppState appState) async {
    final timeRegex = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm|a\.m\.?|p\.m\.?)', caseSensitive: false);
    final match = timeRegex.firstMatch(spokenText);
    
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = match.group(2) != null ? int.parse(match.group(2)!) : 0;
      final period = match.group(3)!.replaceAll('.', '').toLowerCase();

      if (period == 'pm' && hour < 12) hour += 12;
      if (period == 'am' && hour == 12) hour = 0;

      final displayTime = "${(hour % 12 == 0 ? 12 : hour % 12)}:${minute.toString().padLeft(2, '0')} ${period.toUpperCase()}";
      final isNewAlarm = spokenText.toLowerCase().contains("new alarm");

      await MethodChannel('com.echo_trail/alarm').invokeMethod('setAlarm', {'hour': hour, 'minute': minute, 'new': isNewAlarm});
      await MethodChannel('com.echo_trail/alarm').invokeMethod('showToast', {'message': "Alarm set for $displayTime"});

      appState.clearAlarms();
      appState.addAlarmTime(displayTime);

      await _tts.speak("Alarm set for $displayTime.");
    } else {
      await _tts.speak("Please specify a time for the alarm. For example, say set alarm for 7 AM.");
    }
  }

  Future<void> _handleDeleteAlarm(AppState appState) async {
    await MethodChannel('com.echo_trail/alarm').invokeMethod('deleteAlarm');
    appState.clearAlarms();
    await _tts.speak("All alarms deleted.");
  }

  Future<void> _handleSnoozeAlarm(String lowerText) async {
    final match = RegExp(r'snooze\s*(for)?\s*(\d{1,2})\s*(minute|minutes)?').firstMatch(lowerText);
    final snoozeMinutes = match != null ? int.parse(match.group(2)!) : 5;

    await MethodChannel('com.echo_trail/alarm').invokeMethod('snoozeAlarm', {'minutes': snoozeMinutes});
    await _tts.speak("Alarm snoozed for $snoozeMinutes minutes.");
  }

  Future<void> _handleDismissAlarm() async {
    await MethodChannel('com.echo_trail/alarm').invokeMethod('dismissAlarm');
    await _tts.speak("Alarm dismissed.");
  }
}