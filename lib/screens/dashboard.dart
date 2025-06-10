// Path: lib/screens/dashboard.dart
import 'dart:async';
import 'package:echo_trail/screens/setting.dart';
import 'package:flutter/material.dart';
import 'package:echo_trail/services/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:provider/provider.dart';
import 'package:echo_trail/services/app_state.dart';
import '../../main.dart';

Future<void> requestPermissions() async {
  await [
    Permission.camera,
    Permission.microphone,
    Permission.location,
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.speech,
    Permission.scheduleExactAlarm,
  ].request();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const Color lightBlueBackground = Color(0xFFE3F2FD);
  static const Color darkBlueCard = Color(0xFF10164D);
  static const Color whiteText = Colors.white;
  static const Color redDot = Colors.red;
  static const Color tealAccent = Color(0xFF64FFDA);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String? _userName;
  late String _formattedDate;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _setFormattedDate();
    _startVoiceRecognition();
  }

  void _setFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    _formattedDate = '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Future<void> _loadUserName() async {
    try {
      final name = await _authService.getUserNameForDashboard();
      setState(() {
        _userName = name;
      });
    } catch (e) {
      print("Error loading user name: $e");
      setState(() {
        _userName = 'User';
      });
    }
  }

  Future<void> _startVoiceRecognition() async {
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      debugPrint('❌ Microphone permission denied');
      return;
    }

    try {
      await voiceService.init();
      voiceService.startVoiceRecognition();
    } catch (e) {
      debugPrint("❌ Failed to start voice recognition: $e");
    }
  }

  @override
  void dispose() {
    voiceService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeScreen.lightBlueBackground,
      body: SafeArea(
        child: _userName == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              HeaderCard(name: _userName!, date: _formattedDate),
              const SizedBox(height: 16.0),
              NavigationCard(),
              const SizedBox(height: 16.0),
              BeltTrackingCard(),
              const SizedBox(height: 16.0),
              const AlarmCard(),
              const SizedBox(height: 16.0),
              const BatteryCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderCard extends StatelessWidget {
  final String name;
  final String date;

  const HeaderCard({super.key, required this.name, required this.date});

  static const Color darkBlueCard = Color(0xFF10164D);
  static const Color whiteText = Colors.white;
  static const Color tealAccent = Color(0xFF64FFDA);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
        decoration: BoxDecoration(
          color: darkBlueCard,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 120,
                    height: 130,
                    child: CustomPaint(
                      size: Size(70, 60),
                      painter: ConcentricArcPainter(),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Hello, $name',
                  style: const TextStyle(
                    color: whiteText,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        color: whiteText.withOpacity(0.8),
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
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
                      },
                      icon: Icon(
                        Icons.settings_outlined,
                        color: whiteText.withOpacity(0.8),
                        size: 20.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? status;
  final Color statusColor;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.status,
    this.statusColor = Colors.white,
  });

  static const Color darkBlueCard = Color(0xFF10164D);
  static const Color whiteText = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: darkBlueCard,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            color: whiteText,
            size: 40.0,
          ),
          const SizedBox(width: 20.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: whiteText,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (status != null) ...[
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      if (statusColor == Colors.red)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                          margin: const EdgeInsets.only(right: 4.0),
                        ),
                      Text(
                        status!,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8.0),
                Text(
                  description,
                  style: TextStyle(
                    color: whiteText.withOpacity(0.8),
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConcentricArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Color outerArcColor = Color(0xFFaab1c9);
    final Color innerArcColor = Color(0xFF4e8c97);
    final double strokeWidth = 15.0;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double outerRadius = size.width * 0.46;
    final double innerRadius = size.width * 0.27;
    final Paint outerPaint = Paint()
      ..color = outerArcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    final Paint innerPaint = Paint()
      ..color = innerArcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    final double sweepAngle = 4.7;

    final Rect outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final Rect innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    canvas.drawArc(outerRect, -4.9, sweepAngle, false, outerPaint);
    canvas.drawArc(innerRect, -3.3, 3.1, false, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NavigationCard extends StatelessWidget {
  final Color cardBackgroundColor = const Color(0xFF10164D);
  final String iconPath = 'assets/images/navigation.png';

  const NavigationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(iconPath),
              const SizedBox(width: 45.0),
              Expanded(
                child: Text(
                  'Navigation and\nObstacle\nGuidance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          Center(
            child: Text(
              textAlign: TextAlign.center,
              'Allowing users to navigate their path freely',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BeltTrackingCard extends StatelessWidget {
  final Color cardBackgroundColor = const Color(0xFF10164D);
  final Color statusDotColor = Colors.red;
  final String iconPath = 'assets/images/seat-belt.png';

  const BeltTrackingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(iconPath, color: Colors.white),
              const SizedBox(width: 45.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Belt Tracking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 12.0,
                          height: 12.0,
                          decoration: BoxDecoration(
                            color: statusDotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'Disconnected',
                          style: TextStyle(
                            color: statusDotColor.withOpacity(0.9),
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          Center(
            child: Text(
              'Belt tracking for users to track their navigation belt',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14.0,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AlarmCard extends StatefulWidget {
  const AlarmCard({super.key});

  @override
  State<AlarmCard> createState() => _AlarmCardState();
}

class _AlarmCardState extends State<AlarmCard> {
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final alarmTimes = appState.alarmTimes;

    final String displayText = alarmTimes.isEmpty
        ? "No alarms set"
        : alarmTimes.join(", ");

    print("🔔 AlarmCard updated: $displayText");

    return FeatureCard(
      icon: Icons.alarm,
      title: 'Set and Shut Alarm',
      description: 'Allowing users to set and shut their alarm via voice guidance',
      status: displayText,
      statusColor: Colors.white,
    );
  }
}

class BatteryCard extends StatefulWidget {
  const BatteryCard({super.key});

  @override
  State<BatteryCard> createState() => _BatteryCardState();
}

class _BatteryCardState extends State<BatteryCard> {
  final FlutterTts _tts = FlutterTts();
  final Battery _battery = Battery();
  bool _isMonitoring = false;
  bool _isListening = false;
  Timer? _monitoringTimer;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _startMonitoring();
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _listenForThreshold() async {
    setState(() => _isListening = true);
    try {
      await _tts.speak("What percentage would you like to set for battery threshold?");
      await Future.delayed(const Duration(seconds: 2));
      await voiceService.startCommandListener();
    } catch (e) {
      setState(() => _isListening = false);
      await _tts.speak("Failed to start listening for threshold. Please try again.");
      debugPrint("❌ Failed to start command listener: $e");
    } finally {
      setState(() => _isListening = false);
    }
  }

  void _startMonitoring() {
    _monitoringTimer?.cancel();
    _isMonitoring = true;
    final appState = Provider.of<AppState>(context, listen: false);

    _monitoringTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      int level = await _battery.batteryLevel;

      if (level <= appState.batteryThreshold && _isMonitoring) {
        await _tts.speak("Your battery is below ${appState.batteryThreshold} percent. Please charge your device.");
        _isMonitoring = false;
        await Future.delayed(const Duration(minutes: 5));
        _isMonitoring = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final threshold = appState.batteryThreshold;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF10164D),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.battery_alert,
            color: Colors.white,
            size: 40.0,
          ),
          const SizedBox(width: 20.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Battery Threshold',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      margin: const EdgeInsets.only(right: 4.0),
                    ),
                    Text(
                      "$threshold%",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Get a warning when battery is low.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic_none : Icons.mic,
              color: Colors.white,
            ),
            onPressed: _isListening ? null : _listenForThreshold,
          ),
        ],
      ),
    );
  }
}