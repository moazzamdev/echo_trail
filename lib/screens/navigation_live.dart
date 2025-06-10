// screens/navigation_live

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';

class NavigationLiveScreen extends StatefulWidget {
  const NavigationLiveScreen({super.key});

  @override
  _NavigationLiveScreenState createState() => _NavigationLiveScreenState();
}

class _NavigationLiveScreenState extends State<NavigationLiveScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  Timer? _frameTimer;
  final FlutterTts _tts = FlutterTts();
  bool _isSending = false;
  List<dynamic> _detectedObjects = [];
  static int lastErrorTime = 0; // Moved to class level
  String _lastSpokenEnv = ""; // 🔧 Tracks last environment spoken
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initializeTts();
  }

  Future<void> _speak(String message) async {
    if (_isSpeaking || message.isEmpty) return;
    _isSpeaking = true;
    await _tts.speak(message);
    _isSpeaking = false;
  }

  Future<void> _initializeTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![0], ResolutionPreset.high);
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
        _startFrameSending();
      }
    }
  }

  void _startFrameSending() {
    _frameTimer = Timer.periodic(Duration(seconds: 1), (_) => _captureAndSend());
  }

  Future<void> _captureAndSend() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isSending) return;
    _isSending = true;

    try {
      final tempDir = await getTemporaryDirectory();
      final imagePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _cameraController!.takePicture().then((file) async {
        final imageFile = File(file.path);
        await _sendImageToBackend(imageFile);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      });
    } catch (e) {
      print("❌ Error capturing/sending image: $e");
    }

    _isSending = false;
  }

  Future<void> _sendImageToBackend(File imageFile) async {
    final uri = Uri.parse("http://192.168.1.9:8000/api/obstacle-detect/");

    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(resStr);
      final message = jsonResponse['message'] ?? "";
      final objects = jsonResponse['objects'] ?? [];
      final environment = jsonResponse['environment'] ?? "unknown";
      print("🔁 Backend response message: $message");
      print("📦 Backend detected objects: ${jsonEncode(objects)}");


      if (mounted) {
        setState(() {
          _detectedObjects = objects;
        });
      }

      if (message.isNotEmpty) {
        print("🗣️ $message");
        await _speak(message);

      }

      // 🔊 Speak environment change if needed
      if (_lastSpokenEnv != environment) {
        _lastSpokenEnv = environment;
        if (environment == "indoor") {
          await _speak("You are indoors");
        } else if (environment == "street") {
          await _speak("You are outdoors");
        }
      }

    } else if (currentTime - lastErrorTime > 5000) {
      await _speak("Unable to detect. Try again.");
      lastErrorTime = currentTime;
    }
  }


  @override
  void dispose() {
    _frameTimer?.cancel();
    _cameraController?.dispose();
    _tts.stop();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Live Navigation"), backgroundColor: Colors.blue[900]),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          CustomPaint(
            painter: BoundingBoxPainter(_detectedObjects, _cameraController!.value.previewSize!),
            child: Container(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Point your phone forward and wait for guidance...",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<dynamic> objects;
  final Size previewSize;

  BoundingBoxPainter(this.objects, this.previewSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Swap preview dimensions if needed (rotation adjustment)
    final previewWidth = previewSize.height;
    final previewHeight = previewSize.width;

    final scaleX = size.width / previewWidth;
    final scaleY = size.height / previewHeight;


    for (var obj in objects) {
      final box = obj['box'];
      final label = obj['label'];
      final distance = obj['distance'];

      // Scale and rotate coordinates (camera preview is typically rotated 90°)
      final x1 = (box['y1'] * scaleX).clamp(0.0, size.width);
      final y1 = ((previewHeight - box['x2']) * scaleY).clamp(0.0, size.height);
      final x2 = (box['y2'] * scaleX).clamp(0.0, size.width);
      final y2 = ((previewHeight - box['x1']) * scaleY).clamp(0.0, size.height);


      // Draw bounding box
      canvas.drawRect(
        Rect.fromLTRB(x1, y1, x2, y2),
        paint,
      );

      // Draw label and distance
      final textSpan = TextSpan(
        text: '$label (${distance}cm)',
        style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
      );
      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(canvas, Offset(x1, y1 - 20));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}